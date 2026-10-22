local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = group,
    command = "checktime",
})
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "lua", "html", "css", "javascript", "typescript", "json", "yaml" },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
    end,
})
vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(event)
        local function map(key, action, desc)
            vim.keymap.set("n", key, action, { buffer = event.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gr", vim.lsp.buf.references, "Find references")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<F2>", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>la", vim.lsp.buf.code_action, "Code action")
        map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
    end,
})
