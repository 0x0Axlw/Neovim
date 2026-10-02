return {
  "mfussenegger/nvim-lint",

  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local lint = require "lint"
    local uv = vim.uv or vim.loop

    -- =========================================================================
    -- MAHORAGA LINT ENGINE
    -- =========================================================================
    --
    -- Philosophy:
    --
    --   Fast linters:
    --     Run after InsertLeave / buffer entry when stdin is supported.
    --
    --   Deep linters:
    --     Run after save.
    --
    --   Security linters:
    --     Run on save, but throttled.
    --
    --   Missing tools:
    --     silently skipped.
    --
    --   Project configuration:
    --     linter runs from detected project root.
    --
    --   Duplicate diagnostics:
    --     prefer one strong external linter per role instead of
    --     stacking five tools that all complain about the same thing.
    --
    -- =========================================================================

    local root_markers = {
      ".git",

      -- Language projects
      "pyproject.toml",
      "ruff.toml",
      "setup.py",
      "requirements.txt",

      "Cargo.toml",

      "go.mod",
      "go.work",

      "package.json",
      "pnpm-workspace.yaml",
      "yarn.lock",
      "bun.lock",
      "bun.lockb",

      "build.zig",

      "pom.xml",
      "build.gradle",
      "build.gradle.kts",

      "Gemfile",
      "mix.exs",
      "stack.yaml",
      "cabal.project",

      -- Web / tooling
      "deno.json",
      "deno.jsonc",
      "biome.json",
      "biome.jsonc",

      -- DevOps
      "terraform.tf",
      "terraform.tfvars",
      ".terraform",
      "terragrunt.hcl",

      "Dockerfile",
      "compose.yaml",
      "docker-compose.yml",

      -- Nix
      "flake.nix",
      "shell.nix",

      -- Generic project config
      ".editorconfig",
    }

    local function project_root(bufnr)
      return vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    end

    -- -------------------------------------------------------------------------
    -- Resolve a linter definition without actually running it.
    -- This lets us silently ignore tools that aren't installed.
    -- -------------------------------------------------------------------------

    local function resolve_linter(name)
      local definition = lint.linters[name]

      if not definition then
        return nil
      end

      if type(definition) == "function" then
        local ok, resolved = pcall(definition)

        if not ok then
          return nil
        end

        definition = resolved
      end

      if type(definition) ~= "table" then
        return nil
      end

      definition.name = definition.name or name

      return definition
    end

    local function executable_exists(command)
      if type(command) ~= "string" or command == "" then
        return false
      end

      -- Absolute / relative executable.
      if command:find("/", 1, true) then
        return uv.fs_stat(command) ~= nil
      end

      return vim.fn.executable(command) == 1
    end

    local function linter_available(name)
      local linter = resolve_linter(name)

      if not linter then
        return false
      end

      local command = linter.cmd

      if type(command) == "function" then
        local ok, resolved = pcall(command)

        if not ok then
          return false
        end

        command = resolved
      end

      if type(command) == "table" then
        command = command[1]
      end

      return executable_exists(command)
    end

    local function first_available(candidates)
      for _, name in ipairs(candidates) do
        if linter_available(name) then
          return { name }
        end
      end

      return {}
    end

    local function available(names)
      local result = {}

      for _, name in ipairs(names) do
        if linter_available(name) then
          result[#result + 1] = name
        end
      end

      return result
    end

    -- =========================================================================
    -- FAST / LIGHTWEIGHT ANALYSIS
    -- =========================================================================

    local fast = {

      -- -----------------------------------------------------------------------
      -- Lua
      -- -----------------------------------------------------------------------
      lua = function()
        return first_available {
          "luacheck",
          "selene",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Python
      -- -----------------------------------------------------------------------
      python = function()
        return first_available {
          "ruff",
        }
      end,

      -- -----------------------------------------------------------------------
      -- JavaScript / TypeScript
      -- -----------------------------------------------------------------------
      javascript = function()
        return first_available {
          "eslint_d",
          "eslint",
          "biomejs",
          "oxlint",
          "quick-lint-js",
        }
      end,

      javascriptreact = function()
        return first_available {
          "eslint_d",
          "eslint",
          "biomejs",
          "oxlint",
          "quick-lint-js",
        }
      end,

      typescript = function()
        return first_available {
          "eslint_d",
          "eslint",
          "biomejs",
          "oxlint",
        }
      end,

      typescriptreact = function()
        return first_available {
          "eslint_d",
          "eslint",
          "biomejs",
          "oxlint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- C / C++
      --
      -- clang-tidy is deeper analysis, so save-only below.
      -- cppcheck is also deeper.
      -- -----------------------------------------------------------------------

      -- -----------------------------------------------------------------------
      -- Go
      -- -----------------------------------------------------------------------
      go = function()
        return first_available {
          "golangcilint",
          "revive",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Rust
      --
      -- Rust-analyzer already gives excellent diagnostics.
      -- Clippy is reserved for save/deep analysis.
      -- -----------------------------------------------------------------------

      -- -----------------------------------------------------------------------
      -- Shell
      -- -----------------------------------------------------------------------
      sh = function()
        return first_available {
          "shellcheck",
          "bash",
        }
      end,

      bash = function()
        return first_available {
          "shellcheck",
          "bash",
        }
      end,

      zsh = function()
        return first_available {
          "zsh",
        }
      end,

      fish = function()
        return first_available {
          "fish",
        }
      end,

      -- -----------------------------------------------------------------------
      -- YAML
      -- -----------------------------------------------------------------------
      yaml = function()
        return first_available {
          "yamllint",
        }
      end,

      yml = function()
        return first_available {
          "yamllint",
        }
      end,

      ["yaml.ghaction"] = function()
        return first_available {
          "actionlint",
        }
      end,

      ["yaml.github"] = function()
        return first_available {
          "actionlint",
        }
      end,

      ["yaml.ansible"] = function()
        return first_available {
          "ansible_lint",
          "yamllint",
        }
      end,

      ansible = function()
        return first_available {
          "ansible_lint",
          "yamllint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- JSON
      -- -----------------------------------------------------------------------
      json = function()
        return first_available {
          "jsonlint",
          "json_tool",
        }
      end,

      jsonc = function()
        return first_available {
          "jsonlint",
          "json_tool",
        }
      end,

      -- -----------------------------------------------------------------------
      -- TOML
      -- -----------------------------------------------------------------------
      toml = function()
        return first_available {
          "tombi",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Docker
      -- -----------------------------------------------------------------------
      dockerfile = function()
        return first_available {
          "hadolint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Terraform
      -- -----------------------------------------------------------------------
      terraform = function()
        return first_available {
          "tflint",
        }
      end,

      ["terraform-vars"] = function()
        return first_available {
          "tflint",
        }
      end,

      hcl = function()
        return first_available {
          "tflint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Nix
      -- -----------------------------------------------------------------------
      nix = function()
        return first_available {
          "statix",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Markdown
      -- -----------------------------------------------------------------------
      markdown = function()
        return first_available {
          "markdownlint-cli2",
          "markdownlint",
        }
      end,

      ["markdown.mdx"] = function()
        return first_available {
          "markdownlint-cli2",
        }
      end,

      -- -----------------------------------------------------------------------
      -- HTML
      -- -----------------------------------------------------------------------
      html = function()
        return first_available {
          "htmlhint",
          "markuplint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- CSS
      -- -----------------------------------------------------------------------
      css = function()
        return first_available {
          "stylelint",
        }
      end,

      scss = function()
        return first_available {
          "stylelint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- SQL
      -- -----------------------------------------------------------------------
      sql = function()
        return first_available {
          "sqruff",
          "sqlfluff",
        }
      end,

      -- -----------------------------------------------------------------------
      -- QML
      -- -----------------------------------------------------------------------
      qml = function()
        return first_available {
          "qmllint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- CMake
      -- -----------------------------------------------------------------------
      cmake = function()
        return first_available {
          "cmake_lint",
          "cmakelint",
        }
      end,

      -- -----------------------------------------------------------------------
      -- Protocol Buffers
      -- -----------------------------------------------------------------------
      proto = function()
        return first_available {
          "buf_lint",
          "protolint",
        }
      end,
    }

    -- =========================================================================
    -- DEEP ANALYSIS
    -- =========================================================================

    local deep = {

      -- Python: security analysis
      python = {
        "bandit",
      },

      -- Rust: compiler-grade linting
      rust = {
        "clippy",
      },

      -- C / C++
      c = {
        "clangtidy",
        "cppcheck",
      },

      cpp = {
        "clangtidy",
        "cppcheck",
      },

      -- Go
      go = {
        "golangcilint",
      },

      -- Java
      java = {
        "checkstyle",
      },

      -- Kotlin
      kotlin = {
        "detekt",
        "ktlint",
      },

      -- Ruby
      ruby = {
        "rubocop",
      },

      -- PHP
      php = {
        "phpstan",
        "phpcs",
      },

      -- Elixir
      elixir = {
        "credo",
      },

      -- Haskell
      haskell = {
        "hlint",
      },

      -- Clojure
      clojure = {
        "clj-kondo",
      },

      -- Shell security / correctness
      sh = {
        "shellcheck",
      },

      bash = {
        "shellcheck",
        "checkbashisms",
      },

      -- Docker security
      dockerfile = {
        "hadolint",
      },

      -- Terraform / IaC
      terraform = {
        "tflint",
        "tfsec",
        "trivy_iac",
      },

      ["terraform-vars"] = {
        "tflint",
      },

      hcl = {
        "tflint",
      },

      -- Nix
      nix = {
        "statix",
        "deadnix",
      },

      -- Markdown quality
      markdown = {
        "markdownlint-cli2",
        "cspell",
        "vale",
      },

      -- HTML / CSS
      html = {
        "htmlhint",
        "markuplint",
      },

      css = {
        "stylelint",
      },

      scss = {
        "stylelint",
      },

      -- SQL security / quality
      sql = {
        "sqlfluff",
        "sqruff",
      },

      -- YAML
      yaml = {
        "yamllint",
      },

      -- QML
      qml = {
        "qmllint",
      },

      -- Protobuf
      proto = {
        "buf_lint",
        "protolint",
      },
    }

    -- =========================================================================
    -- FILETYPE ALIASES
    -- =========================================================================

    fast.yaml_ghaction = fast["yaml.ghaction"]
    fast["yaml.github"] = fast["yaml.ghaction"]

    deep["yaml.ghaction"] = {
      "actionlint",
      "zizmor",
    }

    deep["yaml.github"] = deep["yaml.ghaction"]

    deep["yaml.ansible"] = {
      "ansible_lint",
      "yamllint",
    }

    -- =========================================================================
    -- SECURITY ANALYSIS
    -- =========================================================================
    --
    -- Gitleaks checks the CURRENT BUFFER rather than scanning the entire
    -- repository, which keeps save-time behavior predictable.
    --
    -- We deliberately do not run expensive whole-repository secret/IaC scans
    -- every time you move your cursor.
    --
    local security_linters = {
      "gitleaks",
    }

    local security_cooldown_seconds = 8
    local last_security_run = {}

    -- =========================================================================
    -- BUFFER STATE
    -- =========================================================================

    local fast_timers = {}

    -- =========================================================================
    -- RESOLVE LINTERS FOR A BUFFER
    -- =========================================================================

    local function resolve_fast_linters(bufnr)
      local ft = vim.bo[bufnr].filetype
      local resolver = fast[ft]

      if not resolver then
        -- Compound filetypes:
        -- e.g. yaml.ghaction
        for component in vim.gsplit(ft, ".", { plain = true }) do
          if fast[component] then
            resolver = fast[component]
            break
          end
        end
      end

      if not resolver then
        return {}
      end

      local ok, result = pcall(resolver, bufnr)

      if not ok or type(result) ~= "table" then
        return {}
      end

      return result
    end

    local function resolve_deep_linters(bufnr)
      local ft = vim.bo[bufnr].filetype
      local result = deep[ft]

      if result then
        return result
      end

      for component in vim.gsplit(ft, ".", { plain = true }) do
        if deep[component] then
          return deep[component]
        end
      end

      return {}
    end

    -- =========================================================================
    -- RUN FAST LINT
    -- =========================================================================

    local function run_fast(bufnr, stdin_only)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      if not vim.bo[bufnr].modifiable then
        return
      end

      local names = resolve_fast_linters(bufnr)

      if #names == 0 then
        return
      end

      lint.try_lint(names, {
        cwd = project_root(bufnr),
        ignore_errors = true,

        filter = function(linter)
          if not linter_available(linter.name) then
            return false
          end

          if stdin_only then
            return linter.stdin == true
          end

          return true
        end,
      })
    end

    -- =========================================================================
    -- RUN DEEP LINT
    -- =========================================================================

    local function run_deep(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local names = resolve_deep_linters(bufnr)

      if #names == 0 then
        return
      end

      lint.try_lint(names, {
        cwd = project_root(bufnr),
        ignore_errors = true,

        filter = function(linter)
          return linter_available(linter.name)
        end,
      })
    end

    -- =========================================================================
    -- RUN SECURITY
    -- =========================================================================

    local function run_security(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local filename = vim.api.nvim_buf_get_name(bufnr)

      if filename == "" then
        return
      end

      local size = vim.fn.getfsize(filename)

      -- Don't security-scan giant/generated files on every save.
      if size > 2 * 1024 * 1024 then
        return
      end

      local now = uv.hrtime() / 1e9
      local previous = last_security_run[bufnr] or 0

      if now - previous < security_cooldown_seconds then
        return
      end

      last_security_run[bufnr] = now

      local names = available(security_linters)

      if #names == 0 then
        return
      end

      lint.try_lint(names, {
        cwd = project_root(bufnr),
        ignore_errors = true,
      })
    end

    -- =========================================================================
    -- DEBOUNCE FAST LINT
    -- =========================================================================

    local function schedule_fast(bufnr, stdin_only)
      if fast_timers[bufnr] then
        fast_timers[bufnr]:stop()
        fast_timers[bufnr]:close()
        fast_timers[bufnr] = nil
      end

      local timer = uv.new_timer()

      if not timer then
        run_fast(bufnr, stdin_only)
        return
      end

      fast_timers[bufnr] = timer

      timer:start(450, 0, function()
        timer:stop()
        timer:close()

        fast_timers[bufnr] = nil

        vim.schedule(function()
          run_fast(bufnr, stdin_only)
        end)
      end)
    end

    -- =========================================================================
    -- AUTOMATIC LINTING
    -- =========================================================================

    local group = vim.api.nvim_create_augroup("MahoragaLint", {
      clear = true,
    })

    -- Entering insert mode ends:
    -- run ONLY stdin-capable fast linters.
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,

      callback = function(args)
        schedule_fast(args.buf, true)
      end,
    })

    -- Opening a buffer:
    -- run lightweight diagnostics after a short delay.
    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,

      callback = function(args)
        schedule_fast(args.buf, true)
      end,
    })

    -- Save:
    --
    -- 1. fast lint
    -- 2. deep/project lint
    -- 3. throttled security scan
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,

      callback = function(args)
        schedule_fast(args.buf, false)

        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            run_deep(args.buf)
            run_security(args.buf)
          end
        end, 150)
      end,
    })

    -- =========================================================================
    -- MANUAL COMMANDS
    -- =========================================================================

    vim.api.nvim_create_user_command("Lint", function()
      local bufnr = vim.api.nvim_get_current_buf()

      run_fast(bufnr, false)
      run_deep(bufnr)
    end, {
      desc = "Run fast + deep linting",
    })

    vim.api.nvim_create_user_command("LintSecurity", function()
      local bufnr = vim.api.nvim_get_current_buf()
      run_security(bufnr)
    end, {
      desc = "Run security linting",
    })

    vim.api.nvim_create_user_command("LintInfo", function()
      local bufnr = vim.api.nvim_get_current_buf()

      local ft = vim.bo[bufnr].filetype
      local root = project_root(bufnr)
      local fast_names = resolve_fast_linters(bufnr)
      local deep_names = resolve_deep_linters(bufnr)

      local lines = {
        "=== Mahoraga Lint ===",
        "",
        "Filetype: " .. ft,
        "Project root: " .. root,
        "",
        "Fast:",
      }

      if #fast_names == 0 then
        table.insert(lines, "  none")
      else
        for _, name in ipairs(fast_names) do
          table.insert(
            lines,
            string.format(
              "  %s [%s]",
              name,
              linter_available(name) and "ready" or "missing"
            )
          )
        end
      end

      table.insert(lines, "")
      table.insert(lines, "Deep:")

      if #deep_names == 0 then
        table.insert(lines, "  none")
      else
        for _, name in ipairs(deep_names) do
          table.insert(
            lines,
            string.format(
              "  %s [%s]",
              name,
              linter_available(name) and "ready" or "missing"
            )
          )
        end
      end

      table.insert(lines, "")
      table.insert(lines, "Security:")

      for _, name in ipairs(security_linters) do
        table.insert(
          lines,
          string.format(
            "  %s [%s]",
            name,
            linter_available(name) and "ready" or "missing"
          )
        )
      end

      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
        title = "Mahoraga Lint",
      })
    end, {
      desc = "Show active linting strategy",
    })

    -- =========================================================================
    -- DIAGNOSTIC PRESENTATION
    -- =========================================================================

    -- Keep lint diagnostics useful without duplicating giant inline messages
    -- from every external tool.
    --
    -- Trouble still sees the full diagnostics.
    for _, name in ipairs {
      "ruff",
      "luacheck",
      "selene",
      "eslint",
      "eslint_d",
      "biomejs",
      "golangcilint",
      "revive",
      "shellcheck",
      "bash",
      "yamllint",
      "actionlint",
      "ansible_lint",
      "hadolint",
      "tflint",
      "tfsec",
      "trivy_iac",
      "statix",
      "deadnix",
      "markdownlint",
      "markdownlint-cli2",
      "cspell",
      "vale",
      "stylelint",
      "sqruff",
      "sqlfluff",
      "qmllint",
      "clangtidy",
      "cppcheck",
      "clippy",
      "bandit",
      "gitleaks",
      "checkstyle",
      "detekt",
      "rubocop",
      "phpstan",
      "phpcs",
      "credo",
      "hlint",
      "clj-kondo",
      "buf_lint",
      "protolint",
    } do
      local ok = pcall(function()
        vim.diagnostic.config({
          virtual_text = false,
          underline = true,
          signs = true,
          severity_sort = true,
        }, lint.get_namespace(name))
      end)

      if not ok then
        -- Namespace doesn't matter until the linter is actually used.
      end
    end

    -- =========================================================================
    -- INITIAL SETUP
    -- =========================================================================

    lint.linters_by_ft = {}

    -- Fast map is intentionally resolved dynamically rather than stuffing
    -- every possible linter into linters_by_ft.
    --
    -- This keeps missing tools silent and prevents duplicate linters.
  end,
}
