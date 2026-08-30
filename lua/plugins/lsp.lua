-- LSP: clangd (C/C++), basedpyright + ruff (Python), lua_ls (this config)
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      { "j-hui/fidget.nvim", opts = {} }, -- LSP progress messages
      { "folke/lazydev.nvim", ft = "lua", opts = {} }, -- lua_ls knows the nvim API
    },
    config = function()
      ----------------------------------------------------------------------
      -- Diagnostics UI
      ----------------------------------------------------------------------
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { source = "if_many" },
        float = { border = "rounded", source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
      })

      ----------------------------------------------------------------------
      -- Keymaps on attach
      ----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
          bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          bmap("n", "grr", vim.lsp.buf.references, "References")
          bmap("n", "gri", vim.lsp.buf.implementation, "Implementations")
          bmap("n", "grt", vim.lsp.buf.type_definition, "Type definition")
          bmap("n", "grn", vim.lsp.buf.rename, "Rename symbol")
          bmap({ "n", "x" }, "gra", vim.lsp.buf.code_action, "Code action")
          bmap("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover docs")
          bmap("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")

          -- Inlay hints toggle (clangd/basedpyright support these)
          if client and client:supports_method("textDocument/inlayHint") then
            bmap("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end

          -- clangd: jump between .c/.cpp and headers
          if client and client.name == "clangd" then
            bmap("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch source/header")
          end
        end,
      })

      ----------------------------------------------------------------------
      -- Server configs
      ----------------------------------------------------------------------
      -- Completion capabilities from blink.cmp for every server
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",                    -- static analysis inline
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--function-arg-placeholders=false",
          "--fallback-style=llvm",
          -- Let clangd interrogate cross-compilers for correct sysroot/includes.
          -- Covers host gcc/clang plus Yocto/Buildroot/kernel cross toolchains
          -- (e.g. aarch64-poky-linux-gcc, arm-buildroot-linux-gnueabihf-g++).
          "--query-driver=/usr/bin/gcc,/usr/bin/g++,/usr/bin/clang,/usr/bin/clang++,**/*-gcc,**/*-g++,**/*-clang,**/*-clang++",
        },
        -- Recognize project roots even without compile_commands.json
        root_markers = {
          "compile_commands.json", "compile_flags.txt", ".clangd",
          ".clang-format", "configure.ac", ".git",
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            -- ruff handles import organization
            disableOrganizeImports = true,
            analysis = {
              typeCheckingMode = "standard", -- "basic" | "standard" | "strict"
              autoImportCompletions = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        -- Linting + import sorting; hover/completion left to basedpyright
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = { completion = { callSnippet = "Replace" } },
        },
      })

      ----------------------------------------------------------------------
      -- Install & enable
      ----------------------------------------------------------------------
      require("mason-tool-installer").setup({
        ensure_installed = {
          "clangd",
          "clang-format",
          "basedpyright",
          "ruff",
          "lua-language-server",
          "stylua",
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "basedpyright", "ruff", "lua_ls" },
        automatic_enable = true,
      })
    end,
  },
}
