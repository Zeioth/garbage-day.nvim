local M = {}

---Parse user options, or set the defaults.
function M.set(opts)
  M.aggressive_mode = opts.aggressive_mode or false
  M.aggresive_mode_ignore = opts.aggresive_mode_ignore or {
    filetype = { "", "markdown", "text", "org", "tex", "asciidoc", "rst" },
    buftype = { "nofile" }
  }
  M.excluded_lsp_clients = opts.excluded_lsp_clients or { "null-ls", "jdtls" }
  M.grace_period = opts.grace_period or (60 * 15) -- seconds
  M.notifications = opts.notifications or false
  M.retries = opts.retries or 3 -- times
  M.timeout = opts.timeout or 1000 -- ms
  M.wakeup_delay = opts.wakeup_delay or 0 -- ms
end

return M
