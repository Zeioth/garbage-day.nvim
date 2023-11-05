local M = {}

---Parse user options, or set the defaults.
function M.set(opts)
 local defaults = {
    grace_period = 60*15, -- seconds
    excluded_languages = {},
    only_visible_buffers = true
  }

  -- Apply user opts, or defaults
  M.grace_period = opts.grace_period or defaults.grace_period
  M.excluded_languages = opts.excluded_languages or defaults.excluded_languages
  M.only_visible_buffers = opts.only_visible_buffers or defaults.only_visible_buffers
end

return M

