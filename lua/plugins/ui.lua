-- Colorscheme + statusline
return {
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_background = "medium" -- "hard" | "medium" | "soft"
			vim.g.gruvbox_material_transparent_background = 2
			vim.g.gruvbox_material_better_performance = 1
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				theme = "gruvbox-material",
				component_separators = "",
				section_separators = "",
			},
			sections = {
				lualine_c = { { "filename", path = 1 } }, -- relative path
				lualine_x = { "diagnostics", "lsp_status", "filetype" },
			},
		},
	},
}
