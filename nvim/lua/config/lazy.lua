local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(path) then
    local output = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", path,
    })
    if vim.v.shell_error ~= 0 then
        error("Could not install lazy.nvim. Check network access and Git.\n" .. output)
    end
end
vim.opt.rtp:prepend(path)
require("lazy").setup(require("config.plugins"), {
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    checker = { enabled = false },
    change_detection = { notify = false },
    install = { colorscheme = { "gruvbox", "habamax" } },
})
