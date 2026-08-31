-- Markdown: pretty in-buffer rendering + live browser preview
return {
	-- Renders markdown inside the buffer: styled headings, tables,
	-- checkboxes, bullet glyphs, code-block backgrounds, links.
	-- Active in normal mode; drops back to plain text while you edit a line.
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			completions = { blink = { enabled = true } }, -- checkbox/callout completions
			code = { border = "thick" },
			heading = { position = "inline" },
		},
		keys = {
			{ "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering" },
		},
	},

	-- Live preview in the browser, scroll-synced. :MarkdownPreviewToggle
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_auto_close = 0 -- keep the tab open when switching buffers
			vim.g.mkdp_combine_preview = 1 -- reuse one browser tab across files
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown preview in browser" },
		},
	},
}
