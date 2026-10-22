return {
    {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {},
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({ contrast = "medium" })
            vim.cmd.colorscheme("gruvbox")
        end,
    },
    {
        "nvim-mini/mini.nvim",
        branch = "stable",
        lazy = false,
        config = function()
            require("mini.icons").setup({ style = "ascii" })
            require("mini.statusline").setup({ use_icons = false })
            require("mini.pick").setup()
            require("mini.files").setup()
            require("mini.pairs").setup({ modes = { insert = false } })
            require("mini.surround").setup()
            require("mini.ai").setup()
            require("mini.bufremove").setup()
            require("mini.diff").setup()
            require("mini.sessions").setup({ autoread = false, autowrite = false })
            require("mini.completion").setup()
            vim.keymap.set("i", "<CR>", function()
                if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
                    return "\25"
                end
                return require("mini.pairs").cr()
            end, { expr = true, desc = "Accept completion or newline" })
            vim.keymap.set("n", "<localleader>c", "gcc", { remap = true, desc = "Toggle comment" })
            vim.keymap.set("x", "<localleader>c", "gc", { remap = true, desc = "Toggle comments" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-mini/mini.nvim", "mason-org/mason.nvim" },
        config = function()
            local capabilities = require("mini.completion").get_lsp_capabilities()
            vim.lsp.config("*", { capabilities = capabilities })
            vim.lsp.config("clangd", { cmd = { "clangd", "--background-index", "--clang-tidy" } })
            -- Support a user-local ICU installation on minimal Linux systems.
            local icu_lib = vim.fn.expand("~/.local/opt/icu/lib")
            if vim.fn.isdirectory(icu_lib) == 1 then
                local inherited = vim.env.LD_LIBRARY_PATH
                vim.lsp.config("marksman", {
                    cmd_env = { LD_LIBRARY_PATH = icu_lib .. (inherited and ":" .. inherited or "") },
                })
            end
            vim.lsp.config("lua_ls", {
                settings = { Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
                    telemetry = { enable = false },
                } },
            })
            -- Enable only installed executables: no surprise downloads on startup.
            for server, executable in pairs({
                clangd = "clangd",
                pyright = "pyright-langserver",
                lua_ls = "lua-language-server",
                starpls = "starpls",
                bazelrc_lsp = "bazelrc-lsp",
                neocmake = "neocmakelsp",
                marksman = "marksman",
                taplo = "taplo",
            }) do
                if vim.fn.executable(executable) == 1 then vim.lsp.enable(server) end
            end
        end,
    },
    -- Copilot is deliberately absent: no plugin, completion source, or setup call.
}
