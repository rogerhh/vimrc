return function()
    local config = vim.fn.stdpath("config")
    local config_root = vim.uv.fs_realpath(config) or config
    local file = vim.api.nvim_buf_get_name(0)
    local real_file = vim.uv.fs_realpath(file) or file
    if real_file:sub(1, #config_root + 1) == config_root .. "/" and vim.bo.modified then
        vim.cmd.write()
    end

    -- lazy.nvim is initialized once; reload the editable core modules instead.
    for _, name in ipairs({ "options", "keymaps", "autocmds" }) do
        package.loaded["config." .. name] = nil
    end
    package.loaded["config.reload"] = nil
    dofile(config .. "/init.lua")
    vim.cmd.nohlsearch()
    vim.notify("Configuration reloaded. Restart Neovim for plugin changes.")
end
