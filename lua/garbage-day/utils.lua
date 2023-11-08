local M = {}
local uv = vim.uv or vim.loop


-- CORE UTILS
-- ----------------------------------------------------------------------------

---Stop all lsp clients, including the ones in other tabs.
function M.stop_lsp()
  local config = vim.g.garbage_day_config
  for _, client in pairs(vim.lsp.get_active_clients()) do
    local is_lsp_client_excluded =
        vim.tbl_contains(config.excluded_lsp_clients, client.config.name)

    -- If all conditions pass
    if not is_lsp_client_excluded then
      -- Stop lsp client
      vim.lsp.stop_client(client.id)
      client.rpc.terminate()
    end

  end
end

---Start lsp clients for the current buffer.
--Clients will try to start once per second for n retries.
function M.start_lsp()
  local config = vim.g.garbage_day_config
  local timer = uv.new_timer() -- Can store ~29377 years
  local start_time = os.time()
  local retries = config.retries -- seconds
  local grace_period_exceeded = false

  local timer_callback
  timer_callback = vim.schedule_wrap(function()
    local current_time = os.time()
    local elapsed_time = current_time - start_time
    grace_period_exceeded = elapsed_time >= retries

    -- Start LSP
    vim.cmd(":LspStart")
    pcall(function() require("null-ls").enable({}) end)

    if grace_period_exceeded then
      timer:stop()
      timer:close()
    else
      timer:start(1000, 1000, timer_callback)
    end
  end)
  timer:start(1000, 1000, timer_callback)
end


-- MISC UTILS
-- ----------------------------------------------------------------------------

---Sends a notification.
---@param kind string Accepted values are:
---{ "lsp_has_started", "lsp_has_stopped" }
function M.notify(kind)
  if kind == "lsp_has_started" then
    vim.notify("Re-starting LSP clients on focus recovered.", vim.log.levels.INFO, {
      title = "garbage-day.nvim"
    })
  elseif kind == "lsp_has_stopped" then
    vim.notify("Inactive LSP clients have been stopped to save resources.", vim.log.levels.INFO, {
      title = "garbage-day.nvim"
    })
  end
end


return M

