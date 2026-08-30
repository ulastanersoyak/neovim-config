-- Autocommands
local aug = function(name) return vim.api.nvim_create_augroup("my_" .. name, { clear = true }) end

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug("yank"),
  callback = function() vim.hl.on_yank() end,
})

-- Linux kernel tree detection:
-- When editing C files inside a kernel source tree, switch to kernel style
-- (tabs, width 8, 100-col guide) and disable format-on-save so clang-format
-- never mangles code you'll send through checkpatch.pl.
-- (The kernel also ships .editorconfig these days; this is a belt-and-braces fallback.)
vim.api.nvim_create_autocmd("FileType", {
  group = aug("kernel_style"),
  pattern = { "c", "cpp" },
  callback = function(args)
    local root = vim.fs.root(args.buf, { "Kbuild", "Kconfig" })
    if root and (vim.uv or vim.loop).fs_stat(root .. "/MAINTAINERS") then
      local bo = vim.bo[args.buf]
      bo.expandtab = false
      bo.tabstop = 8
      bo.shiftwidth = 8
      bo.softtabstop = 8
      vim.wo.colorcolumn = "100"
      vim.b[args.buf].disable_autoformat = true -- manual <leader>f still works
    end
  end,
})

-- BitBake files: 4-space indentation (Yocto style guide)
vim.api.nvim_create_autocmd("FileType", {
  group = aug("bitbake"),
  pattern = "bitbake",
  callback = function(args)
    local bo = vim.bo[args.buf]
    bo.expandtab = true
    bo.tabstop = 4
    bo.shiftwidth = 4
  end,
})

-- Device tree / Kconfig / Makefiles want real tabs
vim.api.nvim_create_autocmd("FileType", {
  group = aug("tabs"),
  pattern = { "make", "kconfig", "dts" },
  callback = function(args)
    vim.bo[args.buf].expandtab = false
    vim.bo[args.buf].tabstop = 8
    vim.bo[args.buf].shiftwidth = 8
  end,
})

-- Jump to last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug("last_pos"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
