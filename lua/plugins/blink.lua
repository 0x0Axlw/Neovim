return {
  -- NvChad's official Blink integration.
  {
    import = "nvchad.blink.lazyspec",
  },

  -- Our overrides.
  {
    "saghen/blink.cmp",

    opts = function(_, opts)
      opts.keymap = {
        preset = "default",

        ["<CR>"] = {
          "accept",
          "fallback",
        },

        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },

        ["<C-Space>"] = {
          "show",
          "show_documentation",
          "hide_documentation",
        },

        ["<C-e>"] = {
          "hide",
        },

        ["<C-k>"] = {
          "scroll_documentation_up",
          "fallback",
        },

        ["<C-j>"] = {
          "scroll_documentation_down",
          "fallback",
        },

        ["<Up>"] = {
          "select_prev",
          "fallback",
        },

        ["<Down>"] = {
          "select_next",
          "fallback",
        },
      }

      opts.completion = opts.completion or {}

      opts.completion.documentation = {
        auto_show = true,
        auto_show_delay_ms = 150,

        window = {
          border = "single",
          scrollbar = false,
        },
      }

      opts.completion.ghost_text = {
        enabled = true,
      }

      opts.completion.menu = {
        border = "single",
        draw = {
          treesitter = { "lsp" },
        },
      }

      opts.sources = opts.sources or {}

      -- Keep NvChad's core sources, but make the priority explicit.
      opts.sources.default = {
        "lsp",
        "snippets",
        "path",
        "buffer",
      }

      opts.sources.providers = opts.sources.providers or {}

      opts.cmdline = {
        enabled = true,
      }

      opts.signature = {
        enabled = true,
      }

      opts.fuzzy = {
        implementation = "prefer_rust",
      }

      opts.snippets = {
        preset = "luasnip",
      }

      return opts
    end,
  },
}
