local M = {}

---Parse user options, or set the defaults.
---After running this function, opts will live in `vim.g.garbage_day_config`.
function M.set(opts)
  M.aggressive_mode = opts.aggressive_mode or false
  M.aggresive_mode_ignore = opts.aggresive_mode_ignore or {
    filetype = { "", "markdown", "text", "org", "tex", "asciidoc", "rst" },
    buftype = { "nofile" }
  }
  M.excluded_lsp_clients = opts.excluded_lsp_clients or {
    "null-ls", "jdtls", "marksman"
  }
  M.grace_period = opts.grace_period or (60 * 15) -- seconds
  M.notifications = opts.notifications or false
  M.retries = opts.retries or 3                   -- times
  M.timeout = opts.timeout or 1000                -- ms
  M.wakeup_delay = opts.wakeup_delay or 0         -- ms
  M.notification_engine = opts.notification_engine or "default"

  -- Expose globally
  vim.g.garbage_day_config = M
end

return M
