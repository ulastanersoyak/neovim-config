-- Editor quality-of-life plugins
return {
  -- Fuzzy finder: files, grep, symbols, diagnostics
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local b = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", "<leader>sf", b.find_files, { desc = "Search files" })
      map("n", "<leader>sg", b.live_grep, { desc = "Grep in project" })
      map("n", "<leader>sw", b.grep_string, { desc = "Grep word under cursor" })
      map("n", "<leader>sb", b.buffers, { desc = "Search buffers" })
      map("n", "<leader>sd", b.diagnostics, { desc = "Search diagnostics" })
      map("n", "<leader>ss", b.lsp_dynamic_workspace_symbols, { desc = "Search symbols" })
      map("n", "<leader>sh", b.help_tags, { desc = "Search help" })
      map("n", "<leader>sr", b.resume, { desc = "Resume last search" })
      map("n", "<leader>s.", b.oldfiles, { desc = "Recent files" })
    end,
  },

  -- File manager: edit the filesystem like a buffer
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { view_options = { show_hidden = true } },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
    },
  },

  -- Git integration in the gutter + hunk actions
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        bmap("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
        bmap("n", "[h", function() gs.nav_hunk("prev") end, "Previous git hunk")
        bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- Auto-detect indentation of files you open (kernel tabs vs ns-3 spaces "just works")
  { "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } },

  -- Auto-close brackets/quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Popup showing available keybindings as you type
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      spec = {
        { "<leader>s", group = "Search" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>t", group = "Toggle" },
        { "<leader>c", group = "Code" },
        { "<leader>b", group = "Buffer" },
      },
    },
  },

  -- TODO/FIXME/HACK highlighting and search
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
