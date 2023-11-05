local M = {}

---Parse user options, or set the defaults.
function M.set(opts)
  M.grace_period = opts.grace_period or (60*15) -- seconds
  M.excluded_languages = opts.excluded_languages or {}
  M.only_visible_buffers = opts.only_visible_buffers or false
end

return M

