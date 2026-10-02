return {
  {
    "stevearc/overseer.nvim",

    opts = {
      strategy = "terminal",

      templates = {
        "builtin",
        "user",
      },

      component_aliases = {
        default = {
          "on_output_summarize",
          "on_exit_set_status",
        },

        diagnostics = {
          "on_output_quickfix",
          "on_result_diagnostics",
          "on_exit_set_status",
        },
      },

      task_list = {
        direction = "bottom",
        min_height = 12,
        max_height = 20,
        default_detail = 1,
      },
    },

    config = function(_, opts)
      local overseer = require("overseer")

      overseer.setup(opts)

      -- =========================================================================
      -- HELPERS
      -- =========================================================================

      local function root_dir()
        return vim.fs.root(0, {
          ".git",
          "Cargo.toml",
          "go.mod",
          "package.json",
          "CMakeLists.txt",
          "Makefile",
          "Justfile",
          "pyproject.toml",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "pubspec.yaml",
          "mix.exs",
          "composer.json",
        }) or vim.fn.getcwd()
      end

      local function current_file()
        return vim.fn.expand("%:p")
      end

      local function filetype()
        return vim.bo.filetype
      end

      local function executable(name)
        return vim.fn.executable(name) == 1
      end

      local function exists(path)
        return vim.uv.fs_stat(path) ~= nil
      end

      local function package_manager(root)
        if exists(root .. "/pnpm-lock.yaml") and executable("pnpm") then
          return "pnpm"
        end

        if exists(root .. "/yarn.lock") and executable("yarn") then
          return "yarn"
        end

        if executable("npm") then
          return "npm"
        end

        return nil
      end

      local function task_output()
        return {
          "default",
          {
            "on_output_quickfix",
            open = false,
          },
        }
      end

      local function unsupported(action)
        vim.notify(
          "No automatic " .. action .. " strategy for filetype: " .. filetype(),
          vim.log.levels.WARN
        )
      end

      local function fallback_task(action, root)
        return {
          cmd = {
            "sh",
            "-lc",
            'printf "%s\\n" "No automatic ' .. action .. " strategy for " .. filetype() .. '"',
          },
          cwd = root,
          components = task_output(),
        }
      end

      -- =========================================================================
      -- BUILD
      -- =========================================================================

      overseer.register_template({
        name = "Build",
        tags = { overseer.TAG.BUILD },

        builder = function()
          local root = root_dir()
          local ft = filetype()
          local file = current_file()

          -- Rust
          if exists(root .. "/Cargo.toml") and executable("cargo") then
            return {
              cmd = { "cargo", "build" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Go
          if exists(root .. "/go.mod") and executable("go") then
            return {
              cmd = { "go", "build", "./..." },
              cwd = root,
              components = task_output(),
            }
          end

          -- C / C++ with CMake
          if
              (ft == "c" or ft == "cpp")
              and exists(root .. "/CMakeLists.txt")
              and executable("cmake")
          then
            return {
              cmd = {
                "cmake",
                "--build",
                "build",
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Make
          if exists(root .. "/Makefile") and executable("make") then
            return {
              cmd = { "make" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Just
          if exists(root .. "/Justfile") and executable("just") then
            return {
              cmd = { "just" },
              cwd = root,
              components = task_output(),
            }
          end

          -- JavaScript / TypeScript / Node
          if exists(root .. "/package.json") then
            local manager = package_manager(root)

            if manager then
              return {
                cmd = {
                  manager,
                  "run",
                  "build",
                },
                cwd = root,
                components = task_output(),
              }
            end
          end

          -- Python
          if ft == "python" and executable("python3") then
            return {
              cmd = {
                "python3",
                "-m",
                "py_compile",
                file,
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Maven
          if exists(root .. "/pom.xml") and executable("mvn") then
            return {
              cmd = { "mvn", "compile" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Gradle wrapper
          if exists(root .. "/gradlew") then
            return {
              cmd = { "./gradlew", "build" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Gradle
          if
              (
                exists(root .. "/build.gradle")
                or exists(root .. "/build.gradle.kts")
              )
              and executable("gradle")
          then
            return {
              cmd = { "gradle", "build" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Dart
          if
              (ft == "dart" or exists(root .. "/pubspec.yaml"))
              and executable("dart")
          then
            return {
              cmd = { "dart", "analyze" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Flutter
          if
              exists(root .. "/pubspec.yaml")
              and executable("flutter")
          then
            return {
              cmd = { "flutter", "analyze" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Elixir
          if
              exists(root .. "/mix.exs")
              and executable("mix")
          then
            return {
              cmd = { "mix", "compile" },
              cwd = root,
              components = task_output(),
            }
          end

          -- Terraform
          if
              (ft == "terraform" or ft == "terraform-vars")
              and executable("terraform")
          then
            return {
              cmd = { "terraform", "validate" },
              cwd = root,
              components = task_output(),
            }
          end

          unsupported("build")
          return fallback_task("build", root)
        end,
      })

      -- =========================================================================
      -- RUN
      -- =========================================================================

      overseer.register_template({
        name = "Run",
        tags = { overseer.TAG.RUN },

        builder = function()
          local root = root_dir()
          local ft = filetype()
          local file = current_file()
          local file_dir = vim.fn.expand("%:p:h")

          -- Python
          if ft == "python" and executable("python3") then
            return {
              cmd = {
                "python3",
                file,
              },
              cwd = file_dir,
              components = task_output(),
            }
          end

          -- Lua
          if ft == "lua" and executable("lua") then
            return {
              cmd = {
                "lua",
                file,
              },
              cwd = file_dir,
              components = task_output(),
            }
          end

          -- Bash / Shell
          if
              (ft == "sh" or ft == "bash")
              and executable("bash")
          then
            return {
              cmd = {
                "bash",
                file,
              },
              cwd = file_dir,
              components = task_output(),
            }
          end

          -- Rust
          if
              exists(root .. "/Cargo.toml")
              and executable("cargo")
          then
            return {
              cmd = {
                "cargo",
                "run",
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Go
          if
              exists(root .. "/go.mod")
              and executable("go")
          then
            return {
              cmd = {
                "go",
                "run",
                ".",
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- JavaScript
          if
              ft == "javascript"
              and executable("node")
          then
            return {
              cmd = {
                "node",
                file,
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- TypeScript
          if ft == "typescript" then
            if executable("tsx") then
              return {
                cmd = {
                  "tsx",
                  file,
                },
                cwd = root,
                components = task_output(),
              }
            end

            if executable("bun") then
              return {
                cmd = {
                  "bun",
                  file,
                },
                cwd = root,
                components = task_output(),
              }
            end

            if executable("npx") then
              return {
                cmd = {
                  "npx",
                  "tsx",
                  file,
                },
                cwd = root,
                components = task_output(),
              }
            end
          end

          -- Dart
          if
              ft == "dart"
              and executable("dart")
          then
            return {
              cmd = {
                "dart",
                file,
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Flutter
          if
              exists(root .. "/pubspec.yaml")
              and executable("flutter")
          then
            return {
              cmd = {
                "flutter",
                "run",
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Ruby
          if
              ft == "ruby"
              and executable("ruby")
          then
            return {
              cmd = {
                "ruby",
                file,
              },
              cwd = file_dir,
              components = task_output(),
            }
          end

          -- PHP
          if
              ft == "php"
              and executable("php")
          then
            return {
              cmd = {
                "php",
                file,
              },
              cwd = file_dir,
              components = task_output(),
            }
          end

          -- Elixir
          if
              exists(root .. "/mix.exs")
              and executable("mix")
          then
            return {
              cmd = {
                "mix",
                "run",
              },
              cwd = root,
              components = task_output(),
            }
          end

          -- Terraform
          if
              (ft == "terraform" or ft == "terraform-vars")
              and executable("terraform")
          then
            return {
              cmd = {
                "terraform",
                "plan",
              },
              cwd = root,
              components = task_output(),
            }
          end

          unsupported("run")
          return fallback_task("run", root)
        end,
      })

      -- =========================================================================
      -- COMMANDS
      -- =========================================================================

      vim.api.nvim_create_user_command("Build", function()
        overseer.run_task({
          name = "Build",
          first = true,
        })
      end, {
        desc = "Build current project or file",
      })

      vim.api.nvim_create_user_command("Run", function()
        overseer.run_task({
          name = "Run",
          first = true,
        })
      end, {
        desc = "Run current project or file",
      })

      vim.api.nvim_create_user_command("Tasks", function()
        vim.cmd("OverseerToggle")
      end, {
        desc = "Open task list",
      })

      vim.api.nvim_create_user_command("Task", function()
        vim.cmd("OverseerRun")
      end, {
        desc = "Choose a task",
      })

      vim.api.nvim_create_user_command("TaskAction", function()
        vim.cmd("OverseerTaskAction")
      end, {
        desc = "Choose a task action",
      })

      -- =========================================================================
      -- KEYMAPS
      -- =========================================================================

      vim.keymap.set("n", "<F6>", function()
        overseer.run_task({
          name = "Run",
          first = true,
        })
      end, {
        desc = "Run",
      })

      vim.keymap.set("n", "<F7>", function()
        overseer.run_task({
          name = "Build",
          first = true,
        })
      end, {
        desc = "Build",
      })

      vim.keymap.set("n", "<F8>", function()
        vim.cmd("OverseerRun")
      end, {
        desc = "Choose task",
      })

      vim.keymap.set("n", "<leader>ot", function()
        vim.cmd("OverseerToggle")
      end, {
        desc = "Task list",
      })

      vim.keymap.set("n", "<leader>or", function()
        vim.cmd("OverseerRun")
      end, {
        desc = "Run task",
      })

      vim.keymap.set("n", "<leader>oa", function()
        vim.cmd("OverseerTaskAction")
      end, {
        desc = "Task action",
      })
    end,
  },
}
