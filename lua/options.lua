-- Core editor options
local o = vim.opt

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.showmode = false          -- statusline shows the mode
o.winborder = "rounded"     -- rounded borders for floats (0.11+)

-- Editing
o.expandtab = true          -- default: spaces (overridden per-project/ft, see autocmds)
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.breakindent = true
o.undofile = true           -- persistent undo across sessions
o.updatetime = 250
o.timeoutlen = 400

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"      -- live preview for :s

-- Whitespace visibility (handy for kernel patches / bitbake)
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- System clipboard
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- Better diffs
o.diffopt:append("linematch:60")
