local M = {}


-- CORE UTILS
-- ----------------------------------------------------------------------------

---Stop all lsp clients, including the ones in other tabs.
---@param excluded_languages table Languages where we don't want to stop LSP.
---@return table stopped_lsp_clients So we can start them again on FocusGaind.
function M.stop_lsp(excluded_languages)
  local stopped_lsp_clients = {}

  -- Iterate all buffers.
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    local is_lang_excluded = vim.tbl_contains(excluded_languages, filetype)

    if not is_lang_excluded then
      -- For each lsp client attached to the buffer.
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.attached_buffers and client.attached_buffers[buf] then
          -- Save the lsp client before stopping it - so we can resume it later.
          stopped_lsp_clients[buf] = stopped_lsp_clients[buf] or {}
          table.insert(stopped_lsp_clients[buf], client)

          -- Stop lsp client
          vim.lsp.stop_client(client.id)
          client.rpc.terminate()
        end
      end
    end
  end

  return stopped_lsp_clients
end

---Stop all lsp clients, including the ones in other tabs.
---@param stopped_lsp_clients table A table like { { buf, client }, .. }
function M.start_lsp(stopped_lsp_clients)
  -- For each buffer, check its attached clients.
  for buf, clients in pairs(stopped_lsp_clients) do
    for _, client in ipairs(clients) do
      -- Client already running? Don't run it again, just attach.
      local existing_clients = vim.lsp.get_clients()
      local is_client_running = false
      for _, existing_client in ipairs(existing_clients) do
        if existing_client.config.name == client.config.name then
          is_client_running = true
          vim.lsp.buf_attach_client(buf, existing_client.id)
          break -- No need to check further, found the running client
        end
      end

      -- Client not running? Run and attach
      if not is_client_running then
        local new_client_id = vim.lsp.start_client(client.config)
        vim.lsp.buf_attach_client(buf, new_client_id)
      end
    end
  end
end

-- NON CORE EXTRA FEATURE
-----------------------------------------------------------------------------

---Stop all lsp clients, including the ones in other tabs.
--Except the ones currently asociated to a nvim window in the current tab.
---@param excluded_languages table Languages where we don't want to stop LSP.
---@return table stopped_lsp_clients So we can start them again on BufEnter.
function M.stop_invisible(excluded_languages)
  local stopped_lsp_clients = {}
  local visible_filetypes = {}

  -- Get all visible filetypes in the current tab
  local visible_buffers = {}
  local current_tab = vim.api.nvim_get_current_tabpage()
  local visible_windows = vim.api.nvim_tabpage_list_wins(current_tab)
  for _, win in ipairs(visible_windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })

    table.insert(visible_buffers, buf)
    visible_filetypes[filetype] = true
  end

  -- Stop LSP clients that are associated with invisible buffers
  -- and don't match visible filetypes.
  for _, client in pairs(vim.lsp.get_clients()) do
    for buf, _ in pairs(client.attached_buffers) do
      if not vim.tbl_contains(visible_buffers, buf) then
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
        local is_lang_excluded = vim.tbl_contains(excluded_languages, filetype)
        if not visible_filetypes[filetype] and
           not is_lang_excluded
        then

          -- Save the lsp client before stopping it - so we can resume it later.
          stopped_lsp_clients[buf] = stopped_lsp_clients[buf] or {}
          table.insert(stopped_lsp_clients[buf], client)

          -- Stop lsp client
          vim.lsp.stop_client(client.id)
          client.rpc.terminate()

        end
      end
    end
  end

  return stopped_lsp_clients
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
