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
-- BufEnter:    This is a extra, non core feature.
--              Stop all LSP clients except the current buffer.
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


--- Entry point of the program
function M.setup(opts)
  config.set(opts)
  vim.g.garbage_day_config = config

  -- Focus lost?
  vim.api.nvim_create_autocmd({ "FocusLost" }, {
    callback = function()
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
  vim.api.nvim_create_autocmd({ "FocusGained" }, {
    callback = function()
      -- Start LSP
      if lsp_has_been_stopped then
        vim.defer_fn(function() vim.cmd(":LspStart") end, 120)
        vim.defer_fn(function() pcall(function() require("null-ls").enable({}) end) end, 200)
        if config.notifications then utils.notify("lsp_has_started") end
      end

      -- Reset state
      start_time = os.time()
      current_time = 0
      elapsed_time = 0
      grace_period_exceeded = false
      lsp_has_been_stopped = false
    end
  })

  -- Buffer entered?
  vim.api.nvim_create_autocmd({ "BufEnter"}, {
    callback = function()
      if config.aggressive_mode then
        vim.defer_fn(function()
          utils.stop_lsp()
          utils.start_lsp()
        if config.notifications then utils.notify("lsp_has_stopped") end
        end, 100)
      end
    end
  })
end

return M
