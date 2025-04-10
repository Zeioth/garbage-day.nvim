local M = {}

-- CORE UTILS
-- ----------------------------------------------------------------------------

---Stop all LSP clients, including the ones in other tabs.
function M.stop_lsp()
  local config = vim.g.garbage_day_config
  for _, client in pairs(vim.lsp.get_clients()) do
    local is_lsp_client_excluded =
      vim.tbl_contains(config.excluded_lsp_clients, client.name)

    -- Stop lsp client
    if not is_lsp_client_excluded then client.stop() end
  end
end

---Start LSP clients for the current buffer.
---It will retry for a configurable amount of times.
function M.start_lsp()
  local config = vim.g.garbage_day_config
  local total_retries = config.retries
  local duration = config.timeout

  local timer = vim.uv.new_timer()
  local elapsed_retries = 0

  local timer_callback
  timer_callback = vim.schedule_wrap(function()
    -- Check if the desired number of retries has been met
    if elapsed_retries >= total_retries then
      timer:stop()
      timer:close()
      return
    end

    -- Start LSP
    local ok, _ = pcall(require, "rustaceanvim")
    if vim.bo.filetype == "rust" and ok then
      vim.cmd(":RustAnalyzer start")
    else
      vim.cmd(":LspStart")
    end

    -- Start null-ls
    local is_null_ls_excluded =
      vim.tbl_contains(config.excluded_lsp_clients, "null-ls")
    if not is_null_ls_excluded then
      pcall(function() require("null-ls").enable({}) end)
    end

    elapsed_retries = elapsed_retries + 1

    -- Schedule the next trigger
    timer:start(duration, 0, timer_callback)
  end)

  -- Start the timer for the first trigger
  timer:start(duration, 0, timer_callback)
end

-- MISC UTILS
-- ----------------------------------------------------------------------------

---Sends a notification.
---@param kind string Accepted values are:
---{ "lsp_has_started", "lsp_has_stopped" }
function M.notify(kind)
  if kind == "lsp_has_started" then
    vim.notify(
      "Focus recovered. Starting LSP clients.",
      vim.log.levels.INFO,
      { title = "garbage-day.nvim" }
    )
  elseif kind == "lsp_has_stopped" then
    vim.notify(
      "Inactive LSP clients have been stopped to save resources.",
      vim.log.levels.INFO,
      { title = "garbage-day.nvim" }
    )
  end
end

return M
