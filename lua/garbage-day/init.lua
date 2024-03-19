--- Plugin to stop LSP clients when inactive.

-- HOW IT WORKS
-- This plugin has 3 autocmds:
-- ----------------------------------------------------------------------------
-- FocusLost:   When the mouse leaves neovim, stop all LSP clients
--              after a grace period.
--
-- FocusGained: When the mouse enters neovim, start all LSP
--              for the current buffer.
--
-- BufEnter:    Manages the feature aggressive_mode.
--              When the mouse enters a buffer, stop all LSP clients
--              If the new buffer filetype is different from the previous one.
--              Always try to start LSP. Even if aggressive_mode is disabled.
-- ----------------------------------------------------------------------------


local M = {}
local uv = vim.uv or vim.loop
local utils = require("garbage-day.utils")
local config = require("garbage-day.config")

local timer = uv.new_timer() -- Can store ~29377 years
local start_time = os.time()
local current_time = 0
local elapsed_time = 0

local grace_period_exceeded = false
local lsp_has_been_stopped = false
local wakeup_delay_counting = false


--- Entry point of the program
function M.setup(opts)
  config.set(opts)
  vim.g.garbage_day_config = config

  -- Focus lost?
  vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
      wakeup_delay_counting = false -- reset wakeup_delay state

      -- Start counting
      timer:start(1000, 1000, vim.schedule_wrap(function()
        -- Update timer state
        current_time = os.time()
        elapsed_time = current_time - start_time
        grace_period_exceeded = elapsed_time >= config.grace_period
        -- Grace period exceeded? Stop LSP
        if grace_period_exceeded and not lsp_has_been_stopped then
          timer:stop()
          utils.stop_lsp()
          if config.notifications then utils.notify("lsp_has_stopped") end
          lsp_has_been_stopped = true
        end
      end))

    end
  })

  -- Focus gained?
  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
      wakeup_delay_counting = true
      vim.defer_fn(function()
        -- if the mouse leave nvim before wakeup_delay ends, don't awake.
        if wakeup_delay_counting then
          -- Start LSP
          if lsp_has_been_stopped then
            utils.start_lsp()
            if config.notifications then utils.notify("lsp_has_started") end
          end

          -- Reset state
          start_time = os.time()
          current_time = 0
          elapsed_time = 0
          grace_period_exceeded = false
          lsp_has_been_stopped = false
        end
      end, config.wakeup_delay)
    end
  })

  -- Buffer entered?
  local current_filetype = ""
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      local new_filetype = vim.bo.filetype
      local new_buftype = vim.bo.buftype

      vim.defer_fn(function()
        if new_buftype == "nofile" then return end
        if new_filetype ~= current_filetype then
          -- Run aggressive_mode
          if config.aggressive_mode then
            utils.stop_lsp()
            utils.start_lsp()
            if config.notifications then utils.notify "lsp_has_stopped" end
          end
        end
        current_filetype = new_filetype
      end, 100)
    end,
  })

end

return M
