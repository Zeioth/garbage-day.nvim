local M = {}

---Stop all lsp clients, including the ones in other tabs.
---@param excluded_languages table Languages where we don't want to stop LSP.
---@return table stopped_lsp_clients So we can start them again on FocusGaind.
function M.stop_lsp(excluded_languages)
  local stopped_lsp_clients = {}

  -- Iterate all buffers.
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    local filetype = vim.api.nvim_get_option_value("filetype", {buf})
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
          break  -- No need to check further, found the running client
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

-- Experimental, do not use yet. See init.lua BufEnter autocmd.
function M.stop_invisible()
    local stopped_lsp_clients = {}

    -- Get all visible buffers
    local visible_buffers = {}
    local visible_windows = vim.api.nvim_list_wins()

    for _, win in ipairs(visible_windows) do
      local win_config = vim.api.nvim_win_get_config(win)
      if not win_config.relative or win_config.relative == '' then
        local buf = vim.api.nvim_win_get_buf(win)
        table.insert(visible_buffers, buf)
      end
    end


    for _, buf in ipairs(visible_buffers) do
      local filetype = vim.api.nvim_get_option_value("filetype", {buf})
      local is_lang_excluded = vim.tbl_contains(excluded_languages, filetype)

      if not is_lang_excluded and not vim.tbl_contains(visible_buffers, buf) then

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

     print(vim.inspect(stopped_lsp_clients))
    return stopped_lsp_clients
end


return M
