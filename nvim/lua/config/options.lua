local opt = vim.opt
opt.number = true
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.undofile = true
opt.undolevels = 10000
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 5
opt.updatetime = 250
opt.timeoutlen = 400
opt.wrap = true
-- Keep the insertion position when jk exits just past the last character.
opt.virtualedit:append("onemore")
opt.completeopt = "menu,menuone,noselect"
opt.autoread = true
opt.confirm = true
opt.list = true
opt.listchars = { tab = "> ", trail = "·", nbsp = "+" }
vim.diagnostic.config({
    severity_sort = true,
    virtual_text = { spacing = 2, source = "if_many" },
    float = { border = "rounded", source = true },
    update_in_insert = false,
})
