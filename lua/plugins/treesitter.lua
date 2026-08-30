-- Treesitter (main branch): highlighting/indentation for everything you'll
-- touch, including bitbake recipes, device trees, and Kconfig.
-- NOTE: the main branch needs the tree-sitter CLI to compile grammars:
--   sudo dnf install tree-sitter-cli   (or: sudo npm install -g tree-sitter-cli)
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"c",
				"cpp",
				"python",
				"bitbake", -- .bb / .bbappend / .bbclass
				"devicetree", -- .dts / .dtsi
				"kconfig",
				"make",
				"cmake",
				"bash",
				"lua",
				"vim",
				"vimdoc",
				"diff",
				"gitcommit",
				"git_rebase",
				"markdown",
				"markdown_inline",
				"json",
				"yaml",
				"toml",
				"doxygen", -- ns-3 uses doxygen comments heavily
			})

			-- Enable highlighting (and indent) per buffer when a parser exists.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("my_treesitter", { clear = true }),
				callback = function(args)
					local buf = args.buf
					local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
					if not lang then
						return
					end
					local ok = pcall(vim.treesitter.start, buf, lang)
					-- Treesitter indent for most languages; C keeps cindent
					-- (treesitter's C indent fights kernel style).
					if ok and vim.bo[buf].filetype ~= "c" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
}
