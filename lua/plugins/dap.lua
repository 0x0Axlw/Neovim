return {
    {
        "mfussenegger/nvim-dap",

        dependencies = {
            "nvim-neotest/nvim-nio",

            -- ==============================================================
            -- DEBUG UI
            -- ==============================================================

            {
                "rcarriga/nvim-dap-ui",

                config = function()
                    require("dapui").setup({
                        layouts = {
                            {
                                elements = {
                                    { id = "scopes",      size = 0.30 },
                                    { id = "breakpoints", size = 0.20 },
                                    { id = "stacks",      size = 0.25 },
                                    { id = "watches",     size = 0.25 },
                                },
                                size = 42,
                                position = "left",
                            },

                            {
                                elements = {
                                    { id = "repl",    size = 0.50 },
                                    { id = "console", size = 0.50 },
                                },
                                size = 12,
                                position = "bottom",
                            },
                        },

                        controls = {
                            enabled = true,
                            element = "repl",

                            icons = {
                                pause = "",
                                play = "",
                                step_into = "",
                                step_over = "",
                                step_out = "",
                                step_back = "",
                                run_last = "",
                                terminate = "",
                                disconnect = "",
                            },
                        },

                        floating = {
                            border = "rounded",
                        },

                        windows = {
                            indent = 1,
                        },
                    })
                end,
            },

            -- ==============================================================
            -- MASON DAP
            -- ==============================================================

            {
                "jay-babu/mason-nvim-dap.nvim",

                dependencies = {
                    "williamboman/mason.nvim",
                },

                opts = {
                    ensure_installed = {
                        -- Native
                        "codelldb",

                        -- Python
                        "python",

                        -- Go
                        "delve",

                        -- JavaScript / Node
                        "node2",

                        -- Shell
                        "bash",

                        -- PHP
                        "php",

                        -- C#
                        "coreclr",

                        -- JVM
                        "javadbg",
                        "javatest",

                        -- Kotlin
                        "kotlin",

                        -- Dart
                        "dart",

                        -- Elixir
                        "elixir",

                    },

                    automatic_installation = false,

                    handlers = {
                        function(config)
                            require("mason-nvim-dap").default_setup(config)
                        end,
                    },
                },
            },
        },

        -- ================================================================
        -- KEYMAPS
        -- ================================================================

        keys = {
            {
                "<F5>",
                function()
                    require("dap").continue()
                end,
                desc = "Debug: Smart Continue",
            },

            {
                "<F9>",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Debug: Toggle Breakpoint",
            },

            {
                "<F10>",
                function()
                    require("dap").step_over()
                end,
                desc = "Debug: Step Over",
            },

            {
                "<F11>",
                function()
                    require("dap").step_into()
                end,
                desc = "Debug: Step Into",
            },

            {
                "<S-F11>",
                function()
                    require("dap").step_out()
                end,
                desc = "Debug: Step Out",
            },

            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "Debug: Terminate",
            },

            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "Debug: Toggle UI",
            },

            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                mode = { "n", "v" },
                desc = "Debug: Evaluate",
            },

            {
                "<leader>dw",
                function()
                    require("dapui").float_element("watches")
                end,
                desc = "Debug: Watches",
            },

            {
                "<leader>ds",
                function()
                    require("dapui").float_element("scopes")
                end,
                desc = "Debug: Scopes",
            },

            {
                "<leader>dR",
                function()
                    require("dapui").float_element("repl")
                end,
                desc = "Debug: REPL",
            },
        },

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- ============================================================
            -- HELPERS
            -- ============================================================

            local function project_root()
                return vim.fs.root(0, {
                    ".git",
                    "pyproject.toml",
                    "Cargo.toml",
                    "go.mod",
                    "package.json",
                    "Makefile",
                    "CMakeLists.txt",
                }) or vim.fn.getcwd()
            end

            local function python_path()
                -- ----------------------------------------------------------
                -- Activated venv
                -- ----------------------------------------------------------

                if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                    local python = vim.env.VIRTUAL_ENV .. "/bin/python"

                    if vim.fn.executable(python) == 1 then
                        return python
                    end
                end

                -- ----------------------------------------------------------
                -- Conda
                -- ----------------------------------------------------------

                if vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX ~= "" then
                    local python = vim.env.CONDA_PREFIX .. "/bin/python"

                    if vim.fn.executable(python) == 1 then
                        return python
                    end
                end

                -- ----------------------------------------------------------
                -- Project environments
                -- ----------------------------------------------------------

                local root = project_root()

                for _, directory in ipairs({
                    ".venv",
                    "venv",
                    "env",
                    ".env",
                }) do
                    local python = root .. "/" .. directory .. "/bin/python"

                    if vim.fn.executable(python) == 1 then
                        return python
                    end
                end

                -- ----------------------------------------------------------
                -- System fallback
                -- ----------------------------------------------------------

                return vim.fn.exepath("python3")
                    or vim.fn.exepath("python")
                    or "python3"
            end

            local function current_file()
                return vim.fn.expand("%:p")
            end

            -- ============================================================
            -- SMART LAUNCHER REGISTRY
            --
            -- ONE DEFAULT LAUNCH CONFIG PER LANGUAGE.
            --
            -- No configuration picker for these languages.
            -- ============================================================

            local launchers = {}

            -- ------------------------------------------------------------
            -- Python
            -- ------------------------------------------------------------

            launchers.python = {
                type = "python",
                request = "launch",
                name = "Smart Python",
                program = "${file}",
                cwd = "${fileDirname}",
                pythonPath = python_path,
                console = "integratedTerminal",
                justMyCode = false,
            }

            -- ------------------------------------------------------------
            -- Bash
            -- ------------------------------------------------------------

            launchers.sh = {
                type = "bash",
                request = "launch",
                name = "Smart Bash",
                program = "${file}",
                cwd = "${fileDirname}",
                terminalKind = "integrated",
            }

            launchers.bash = launchers.sh

            -- ------------------------------------------------------------
            -- Go
            -- ------------------------------------------------------------

            launchers.go = {
                type = "delve",
                request = "launch",
                name = "Smart Go",
                program = "${workspaceFolder}",
                cwd = "${workspaceFolder}",
            }

            -- ------------------------------------------------------------
            -- Rust
            --
            -- CodeLLDB has native Cargo support, so we do NOT ask you
            -- where the executable is.
            -- ------------------------------------------------------------

            launchers.rust = {
                type = "codelldb",
                request = "launch",
                name = "Smart Rust",
                cargo = {
                    "run",
                },
                cwd = "${workspaceFolder}",
                sourceLanguages = {
                    "rust",
                },
            }

            -- ------------------------------------------------------------
            -- JavaScript / Node
            --
            -- node2 is provided by Mason's DAP integration.
            -- ------------------------------------------------------------

            launchers.javascript = {
                type = "node2",
                request = "launch",
                name = "Smart JavaScript",
                program = "${file}",
                cwd = "${workspaceFolder}",
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal",
            }

            launchers.typescript = launchers.javascript

            launchers.javascriptreact = launchers.javascript
            launchers.typescriptreact = launchers.javascript

            -- ============================================================
            -- INSTALL SMART CONFIGS
            --
            -- These replace the noisy multi-choice defaults for languages
            -- where we have a deterministic launch strategy.
            -- ============================================================

            for filetype, config in pairs(launchers) do
                dap.configurations[filetype] = {
                    config,
                }
            end

            -- ============================================================
            -- SMART CONTINUE
            --
            -- If there is already a debug session:
            --     continue it.
            --
            -- Otherwise:
            --     use our deterministic current-language configuration.
            --
            -- If we don't have a deterministic launcher for the language,
            -- fall back to nvim-dap's normal configuration provider. This
            -- allows project-level .vscode/launch.json configurations to
            -- work without us reinventing them.
            -- ============================================================

            local original_continue = dap.continue

            dap.continue = function(...)
                local session = dap.session()

                if session then
                    return original_continue(...)
                end

                local filetype = vim.bo.filetype
                local config = launchers[filetype]

                if config then
                    return dap.run(config)
                end

                return original_continue(...)
            end

            -- ============================================================
            -- SIGNS
            -- ============================================================

            vim.fn.sign_define("DapBreakpoint", {
                text = "●",
                texthl = "DiagnosticSignError",
            })

            vim.fn.sign_define("DapBreakpointCondition", {
                text = "◆",
                texthl = "DiagnosticSignWarn",
            })

            vim.fn.sign_define("DapStopped", {
                text = "▶",
                texthl = "DiagnosticSignInfo",
                linehl = "Visual",
            })

            -- ============================================================
            -- AUTOMATIC UI
            -- ============================================================

            dap.listeners.before.attach.dapui_auto_open = function()
                dapui.open()
            end

            dap.listeners.before.launch.dapui_auto_open = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated.dapui_auto_close = function()
                dapui.close()
            end

            dap.listeners.before.event_exited.dapui_auto_close = function()
                dapui.close()
            end
        end,
    },
}
