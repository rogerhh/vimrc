-- Neovim 0.11.3+; all paths are relative to this configuration.
if vim.fn.has("nvim-0.11.3") == 0 then
    error("This configuration requires Neovim 0.11.3 or newer")
end
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- Explicitly disable any previously installed Vimscript Copilot plugin.
vim.g.copilot_enabled = false
vim.filetype.add({
    extension = { cu = "cuda", cuh = "cuda", bzl = "bzl", bazel = "bzl" },
    filename = {
        BUILD = "bzl",
        WORKSPACE = "bzl",
        [".bazelrc"] = "bazelrc",
    },
    pattern = { [".*%.bazelrc"] = "bazelrc" },
})
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
