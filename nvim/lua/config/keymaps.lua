local map = vim.keymap.set
-- Match the old two-character insertion shortcuts without automatic pairing.
for _, pair in ipairs({ '""', "''", "()", "[]", "<>", "{}" }) do
    map("i", pair, pair .. "<Left>", { desc = "Insert " .. pair .. " and move inside" })
end
map("x", '<localleader>"', 'sa"', { remap = true, desc = "Surround selection with quotes" })
map("n", "<localleader>sv", function() require("config.reload")() end,
    { desc = "Save configuration edit and reload" })
for _, key in ipairs({ "<Left>", "<Right>", "<Up>", "<Down>" }) do
    map({ "n", "x", "s", "o", "i" }, key, "<Nop>", { desc = "Arrow key disabled" })
end
map({ "i", "x" }, "<C-[>", "<Nop>", { desc = "Use jk to leave this mode" })
-- Escape shifts left; return to the insertion position after leaving insert mode.
map("i", "jk", "<Esc>`^", { desc = "Leave insert mode without moving cursor" })
map("x", "jk", "<Esc>", { desc = "Leave visual mode" })
map("i", "<C-c>", "<Esc>")
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
map({ "n", "x" }, "H", "^", { desc = "First nonblank character" })
map({ "n", "x" }, "L", "$", { desc = "End of line" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<localleader>hl", "<cmd>nohlsearch<cr>")
map("n", "<localleader>u", "viwUe", { desc = "Uppercase word" })
map("i", "<localleader>u", "<Esc>viwUea", { desc = "Uppercase word" })
map("n", "<localleader>ev", function()
    vim.cmd.vsplit(vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
end, { desc = "Edit keymaps" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>confirm quit<cr>", { desc = "Quit window" })
for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
    map("n", "<C-" .. key .. ">", "<C-w>" .. direction, { desc = "Move to window" })
end
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", function() require("mini.bufremove").delete() end, { desc = "Delete buffer" })
map("n", "<leader>ff", function() require("mini.pick").builtin.files() end, { desc = "Find files" })
map("n", "<leader>fg", function()
    if vim.fn.executable("rg") == 0 then
        vim.notify("Live grep requires ripgrep (rg)", vim.log.levels.WARN)
        return
    end
    require("mini.pick").builtin.grep_live()
end, { desc = "Search text" })
map("n", "<leader>fb", function() require("mini.pick").builtin.buffers() end, { desc = "Find buffers" })
map("n", "<leader>fh", function() require("mini.pick").builtin.help() end, { desc = "Find help" })
map("n", "<C-n>", function() require("mini.files").open(vim.api.nvim_buf_get_name(0), false) end,
    { desc = "File explorer" })
map("n", "<leader>e", function() require("mini.files").open() end, { desc = "File explorer" })
map("n", "<leader>ss", function()
    vim.ui.input({ prompt = "Session name: " }, function(name)
        if name and name:match("^[%w_.-]+$") then require("mini.sessions").write(name) end
    end)
end, { desc = "Save named session" })
map("n", "<leader>sr", function() require("mini.sessions").select("read") end, { desc = "Restore session" })
map("n", "<leader>sd", function() require("mini.sessions").select("delete") end, { desc = "Delete session" })
map("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Language servers" })
map("n", "<leader>pl", "<cmd>Lazy<cr>", { desc = "Plugins" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })
