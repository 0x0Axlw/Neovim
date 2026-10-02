return {
  {
    "nvim-neotest/neotest",

    dependencies = {
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",

      -- ============================================================
      -- PYTHON
      -- pytest / unittest
      -- ============================================================

      {
        "nvim-neotest/neotest-python",
      },

      -- ============================================================
      -- GO
      -- ============================================================

      {
        "nvim-neotest/neotest-go",
      },

      -- ============================================================
      -- RUST
      -- ============================================================

      {
        "rouge8/neotest-rust",
      },

      -- ============================================================
      -- JAVASCRIPT / TYPESCRIPT
      -- ============================================================

      {
        "marilari88/neotest-vitest",
      },

      {
        "nvim-neotest/neotest-jest",
      },

      -- ============================================================
      -- BASH
      -- ============================================================

      {
        "rcasia/neotest-bash",
      },

      -- ============================================================
      -- DART / FLUTTER
      -- ============================================================

      {
        "sidlatau/neotest-dart",
      },

      -- ============================================================
      -- JAVA
      -- ============================================================

      {
        "rcasia/neotest-java",
      },

      -- ============================================================
      -- KOTLIN
      -- ============================================================

      {
        "codymikol/neotest-kotlin",
      },

      -- ============================================================
      -- PHP
      -- ============================================================

      {
        "olimorris/neotest-phpunit",
      },

      -- ============================================================
      -- ELIXIR
      -- ============================================================

      {
        "jfpedroza/neotest-elixir",
      },
    },

    event = {
      "BufReadPost",
      "BufNewFile",
    },

    config = function()
      local neotest = require "neotest"

      local adapters = {}

      -- ------------------------------------------------------------
      -- Python
      -- ------------------------------------------------------------

      local ok, python = pcall(require, "neotest-python")

      if ok then
        adapters[#adapters + 1] = python {
          dap = {
            justMyCode = false,
          },

          -- Prefer pytest when available.
          runner = "pytest",

          -- Let the adapter discover the project's Python environment.
          python = function()
            local root = vim.fs.root(0, {
              "pyproject.toml",
              "pytest.ini",
              "setup.cfg",
              "setup.py",
              ".git",
            }) or vim.fn.getcwd()

            local candidates = {
              root .. "/.venv/bin/python",
              root .. "/venv/bin/python",
              root .. "/env/bin/python",
              root .. "/.env/bin/python",
            }

            for _, python_path in ipairs(candidates) do
              if vim.fn.executable(python_path) == 1 then
                return python_path
              end
            end

            if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
              local python_path = vim.env.VIRTUAL_ENV .. "/bin/python"

              if vim.fn.executable(python_path) == 1 then
                return python_path
              end
            end

            return vim.fn.exepath "python3"
          end,
        }
      end

      -- ------------------------------------------------------------
      -- Go
      -- ------------------------------------------------------------

      local ok_go, go = pcall(require, "neotest-go")

      if ok_go then
        adapters[#adapters + 1] = go {
          recursive_run = true,
        }
      end

      -- ------------------------------------------------------------
      -- Rust
      -- ------------------------------------------------------------

      local ok_rust, rust = pcall(require, "neotest-rust")

      if ok_rust then
        adapters[#adapters + 1] = rust {}
      end

      -- ------------------------------------------------------------
      -- Vitest
      -- ------------------------------------------------------------

      local ok_vitest, vitest = pcall(require, "neotest-vitest")

      if ok_vitest then
        adapters[#adapters + 1] = vitest {
          filter_dir = function(name)
            return name ~= "node_modules"
          end,
        }
      end

      -- ------------------------------------------------------------
      -- Jest
      -- ------------------------------------------------------------

      local ok_jest, jest = pcall(require, "neotest-jest")

      if ok_jest then
        adapters[#adapters + 1] = jest({})
      end

      -- ------------------------------------------------------------
      -- Bash
      -- ------------------------------------------------------------

      local ok_bash, bash = pcall(require, "neotest-bash")

      if ok_bash then
        adapters[#adapters + 1] = bash {}
      end

      -- ------------------------------------------------------------
      -- Dart / Flutter
      -- ------------------------------------------------------------

      local ok_dart, dart = pcall(require, "neotest-dart")

      if ok_dart then
        adapters[#adapters + 1] = dart {}
      end

      -- ------------------------------------------------------------
      -- Java
      -- ------------------------------------------------------------

      local ok_java, java = pcall(require, "neotest-java")

      if ok_java then
        adapters[#adapters + 1] = java {}
      end

      -- ------------------------------------------------------------
      -- Kotlin
      -- ------------------------------------------------------------


      local ok_kotlin, kotlin = pcall(require, "neotest-kotlin")

      if ok_kotlin then
        adapters[#adapters + 1] = kotlin
      end

      -- ------------------------------------------------------------
      -- PHP
      -- ------------------------------------------------------------

      local ok_php, php = pcall(require, "neotest-phpunit")

      if ok_php then
        adapters[#adapters + 1] = php {}
      end

      -- ------------------------------------------------------------
      -- Elixir
      -- ------------------------------------------------------------

      local ok_elixir, elixir = pcall(require, "neotest-elixir")

      if ok_elixir then
        adapters[#adapters + 1] = elixir {}
      end

      -- ============================================================
      -- NEOTEST
      -- ============================================================

      neotest.setup {
        adapters = adapters,

        discovery = {
          enabled = true,
        },

        running = {
          concurrent = true,
        },

        summary = {
          animated = true,
          follow = true,
          expand_errors = true,
        },

        output = {
          enabled = true,
          open_on_run = false,
        },

        status = {
          enabled = true,
          signs = true,
          virtual_text = false,
        },

        quickfix = {
          enabled = true,
          open = false,
        },
      }

      -- ============================================================
      -- COMMANDS
      -- ============================================================

      vim.api.nvim_create_user_command("TestNearest", function()
        neotest.run.run()
      end, {
        desc = "Run nearest test",
      })

      vim.api.nvim_create_user_command("TestFile", function()
        neotest.run.run(vim.fn.expand "%")
      end, {
        desc = "Run current test file",
      })

      vim.api.nvim_create_user_command("TestProject", function()
        neotest.run.run(vim.fn.getcwd())
      end, {
        desc = "Run project tests",
      })

      vim.api.nvim_create_user_command("TestDebug", function()
        neotest.run.run {
          strategy = "dap",
        }
      end, {
        desc = "Debug nearest test",
      })

      vim.api.nvim_create_user_command("TestStop", function()
        neotest.run.stop()
      end, {
        desc = "Stop running test",
      })

      vim.api.nvim_create_user_command("TestSummary", function()
        neotest.summary.toggle()
      end, {
        desc = "Toggle test summary",
      })

      vim.api.nvim_create_user_command("TestOutput", function()
        neotest.output.open {
          enter = true,
        }
      end, {
        desc = "Open test output",
      })

      vim.api.nvim_create_user_command("TestOutputPanel", function()
        neotest.output_panel.toggle()
      end, {
        desc = "Toggle test output panel",
      })

      -- ============================================================
      -- KEYMAPS
      -- ============================================================

      local map = vim.keymap.set

      map("n", "<leader>tn", function()
        neotest.run.run()
      end, {
        desc = "Test: Nearest",
      })

      map("n", "<leader>tf", function()
        neotest.run.run(vim.fn.expand "%")
      end, {
        desc = "Test: File",
      })

      map("n", "<leader>ta", function()
        neotest.run.run(vim.fn.getcwd())
      end, {
        desc = "Test: Project",
      })

      map("n", "<leader>td", function()
        neotest.run.run {
          strategy = "dap",
        }
      end, {
        desc = "Test: Debug nearest",
      })

      map("n", "<leader>tx", function()
        neotest.run.stop()
      end, {
        desc = "Test: Stop",
      })

      map("n", "<leader>ts", function()
        neotest.summary.toggle()
      end, {
        desc = "Test: Summary",
      })

      map("n", "<leader>to", function()
        neotest.output.open {
          enter = true,
        }
      end, {
        desc = "Test: Output",
      })

      map("n", "<leader>tO", function()
        neotest.output_panel.toggle()
      end, {
        desc = "Test: Output Panel",
      })
    end,
  },
}
