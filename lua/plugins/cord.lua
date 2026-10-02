return {
  "vyfor/cord.nvim",
  event = "VeryLazy",
  opts = {
    editor = {
      client = "neovim",
    },
    display = {
      theme = "catppuccin",
      flavor = "accent",
      view = "full",
      swap_icons = false,
      swap_fields = false,
    },
    idle = {
      enabled = true,
      timeout = 300000,
      show_status = true,
      ignore_focus = true,
      unidle_on_focus = true,
      smart_idle = true,

      details = "Recharging",
      state = "Standing by",
      tooltip = "💤",
    },
    buttons = {
      {
        label = function(opts)
          if opts.repo_url then
            return "Repository"
          end

          return "GitHub Profile"
        end,

        url = function(opts)
          if opts.repo_url then
            return opts.repo_url
          end

          return "https://github.com/0x0Axlw"
        end,
      },
    },
    text = {
      default = nil,
      workspace = function(opts)
        return "Battleground"
      end,
      viewing = function(opts)
        return "Stalking"
      end,
      editing = function(opts)
        return "Forging"
      end,
      file_browser = function(opts)
        return "Scavenging"
      end,
      plugin_manager = function(opts)
        return "Equipping"
      end,
      lsp = function(opts)
        return "Scanning"
      end,
      docs = function(opts)
        return "Studying"
      end,
      vcs = function(opts)
        return "Binding"
      end,
      notes = function(opts)
        return "Inscribing"
      end,
      debug = function(opts)
        return "Hunting bugs"
      end,
      test = function(opts)
        return "Test-firing"
      end,
      diagnostics = function(opts)
        return "Inspecting"
      end,
      terminal = function(opts)
        return "Broadcasting"
      end,
      dashboard = "Standing by",
    },
    advanced = {
      discord = {
        reconnect = {
          enabled = true,
        },
      },
    },
  },
}
