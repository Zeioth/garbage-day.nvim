local M = {}

---Parse user options, or set the defaults.
function M.set(opts)
  M.grace_period = opts.grace_period or (60*15) -- seconds
  M.excluded_lsp_clients = opts.excluded_lsp_clients or { "jdtls" }
  M.aggressive_mode = opts.aggressive_mode or false
  M.notifications = opts.notifications or false
  M.retries = opts.retries or 3
end

return M

