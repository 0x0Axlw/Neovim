return {
  "stevearc/conform.nvim",

  event = { "BufReadPre", "BufNewFile" },

  opts = require "configs.conform",

  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({
          async = true,
          lsp_format = "fallback",
        })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },

  init = function()
    vim.api.nvim_create_user_command("FormatInfo", function()
      require("conform").formatters_info()
    end, {
      desc = "Show formatter information",
    })
  end,
}
