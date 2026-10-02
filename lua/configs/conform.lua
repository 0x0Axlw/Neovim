local function formatter_available(name, bufnr)
  return require("conform").get_formatter_info(name, bufnr).available
end

local function first_available(bufnr, candidates, fallback)
  for _, name in ipairs(candidates) do
    if formatter_available(name, bufnr) then
      return { name }
    end
  end

  return fallback or { lsp_format = "fallback" }
end

local function python_formatters(bufnr)
  if formatter_available("ruff_organize_imports", bufnr)
      and formatter_available("ruff_format", bufnr) then
    return {
      "ruff_organize_imports",
      "ruff_format",
    }
  end

  if formatter_available("ruff_format", bufnr) then
    return { "ruff_format" }
  end

  return { "black", lsp_format = "fallback" }
end

local function javascript_formatters(bufnr)
  local root = vim.fs.root(bufnr, {
    "biome.json",
    "biome.jsonc",
  })

  if root and formatter_available("biome", bufnr) then
    return { "biome" }
  end

  local deno_root = vim.fs.root(bufnr, {
    "deno.json",
    "deno.jsonc",
  })

  if deno_root and formatter_available("deno_fmt", bufnr) then
    return { "deno_fmt" }
  end

  return first_available(bufnr, { "prettier", "prettierd" })
end

local function yaml_formatters(bufnr)
  return first_available(
    bufnr,
    { "yamlfmt", "yamlfix", "prettier", "prettierd" }
  )
end

local function nix_formatters(bufnr)
  return first_available(
    bufnr,
    { "alejandra", "nixfmt", "nixpkgs_fmt" }
  )
end

local function sql_formatters(bufnr)
  return first_available(
    bufnr,
    { "sqruff", "sqlfluff", "sql_formatter", "sqlfmt" }
  )
end

local function terraform_formatters(bufnr)
  if formatter_available("terraform_fmt", bufnr) then
    return { "terraform_fmt" }
  end

  if formatter_available("tofu_fmt", bufnr) then
    return { "tofu_fmt" }
  end

  return { lsp_format = "fallback" }
end

local function web_formatters(bufnr)
  return javascript_formatters(bufnr)
end

local options = {
  -- ===========================================================================
  -- FORMATTERS BY FILETYPE
  -- ===========================================================================

  formatters_by_ft = {

    -- -------------------------------------------------------------------------
    -- Lua
    -- -------------------------------------------------------------------------
    lua = { "stylua" },

    -- -------------------------------------------------------------------------
    -- Python
    -- -------------------------------------------------------------------------
    python = python_formatters,

    -- -------------------------------------------------------------------------
    -- Rust
    -- -------------------------------------------------------------------------
    rust = { "rustfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- C / C++ / Objective-C / CUDA
    -- -------------------------------------------------------------------------
    c = { "clang_format", lsp_format = "fallback" },
    cpp = { "clang_format", lsp_format = "fallback" },
    objc = { "clang_format", lsp_format = "fallback" },
    objcpp = { "clang_format", lsp_format = "fallback" },
    cuda = { "clang_format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Go
    -- -------------------------------------------------------------------------
    go = { "goimports", "gofmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Zig
    -- -------------------------------------------------------------------------
    zig = { "zigfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Java
    -- -------------------------------------------------------------------------
    java = { "google-java-format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Kotlin
    -- -------------------------------------------------------------------------
    kotlin = { "ktlint", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Scala
    -- -------------------------------------------------------------------------
    scala = { "scalafmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Swift
    -- -------------------------------------------------------------------------
    swift = { "swiftformat", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Dart
    -- -------------------------------------------------------------------------
    dart = { "dart_format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- C#
    -- -------------------------------------------------------------------------
    cs = { "csharpier", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- F#
    -- -------------------------------------------------------------------------
    fsharp = { "fantomas", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Ruby
    -- -------------------------------------------------------------------------
    ruby = { "rubocop", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- PHP
    -- -------------------------------------------------------------------------
    php = { "php_cs_fixer", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Elixir
    -- -------------------------------------------------------------------------
    elixir = { "mix", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Erlang
    -- -------------------------------------------------------------------------
    erlang = { "erlfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Haskell
    -- -------------------------------------------------------------------------
    haskell = { "fourmolu", "ormolu", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- OCaml
    -- -------------------------------------------------------------------------
    ocaml = { "ocamlformat", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Clojure
    -- -------------------------------------------------------------------------
    clojure = { "cljfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Crystal
    -- -------------------------------------------------------------------------
    crystal = { "crystal", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Nim
    -- -------------------------------------------------------------------------
    nim = { "nimpretty", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Elm
    -- -------------------------------------------------------------------------
    elm = { "elm_format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Gleam
    -- -------------------------------------------------------------------------
    gleam = { "gleam_fmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- ReScript
    -- -------------------------------------------------------------------------
    rescript = { "rescript_format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Racket / Prolog / Perl / Tcl
    -- -------------------------------------------------------------------------
    racket = { "racketfmt", lsp_format = "fallback" },
    prolog = { "prolog", lsp_format = "fallback" },
    perl = { "perltidy", lsp_format = "fallback" },
    tcl = { "tclfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Assembly / HDL
    -- -------------------------------------------------------------------------
    asm = { "asmfmt", lsp_format = "fallback" },
    nasm = { "asmfmt", lsp_format = "fallback" },
    verilog = { "verible", lsp_format = "fallback" },
    systemverilog = { "verible", lsp_format = "fallback" },
    vhdl = { "ghdl", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Fortran
    -- -------------------------------------------------------------------------
    fortran = { "fprettify", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- R
    -- -------------------------------------------------------------------------
    r = { "styler", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- V
    -- -------------------------------------------------------------------------
    v = { "v", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- JavaScript / TypeScript
    -- -------------------------------------------------------------------------
    javascript = web_formatters,
    javascriptreact = web_formatters,
    typescript = web_formatters,
    typescriptreact = web_formatters,

    -- -------------------------------------------------------------------------
    -- Web frameworks
    -- -------------------------------------------------------------------------
    vue = { "prettier", "prettierd", lsp_format = "fallback" },
    svelte = { "prettier", "prettierd", lsp_format = "fallback" },
    astro = { "prettier", "prettierd", lsp_format = "fallback" },
    mdx = { "prettier", "prettierd", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- HTML / CSS
    -- -------------------------------------------------------------------------
    html = { "prettier", "prettierd", lsp_format = "fallback" },
    css = { "prettier", "prettierd", lsp_format = "fallback" },
    scss = { "prettier", "prettierd", lsp_format = "fallback" },
    less = { "prettier", "prettierd", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- GraphQL
    -- -------------------------------------------------------------------------
    graphql = { "prettier", "prettierd", lsp_format = "fallback" },
    gql = { "prettier", "prettierd", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- QML
    -- -------------------------------------------------------------------------
    qml = { "qmlformat", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Shell
    -- -------------------------------------------------------------------------
    sh = { "shfmt", lsp_format = "fallback" },
    bash = { "shfmt", lsp_format = "fallback" },
    zsh = { "shfmt", lsp_format = "fallback" },
    fish = { "fish_indent", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Docker
    -- -------------------------------------------------------------------------
    dockerfile = { "dockerfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- YAML
    -- -------------------------------------------------------------------------
    yaml = yaml_formatters,
    yml = yaml_formatters,

    -- Common YAML ecosystem filetypes
    ansible = yaml_formatters,
    yaml_ansible = yaml_formatters,
    helm = { lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- JSON
    -- -------------------------------------------------------------------------
    json = { "prettier", "prettierd", lsp_format = "fallback" },
    jsonc = { "prettier", "prettierd", lsp_format = "fallback" },
    json5 = { "prettier", "prettierd", lsp_format = "fallback" },
    jsonnet = { "jsonnetfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- TOML
    -- -------------------------------------------------------------------------
    toml = { "taplo", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- XML
    -- -------------------------------------------------------------------------
    xml = { "xmlformatter", "xmlformat", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- SQL
    -- -------------------------------------------------------------------------
    sql = sql_formatters,
    mysql = sql_formatters,
    plsql = sql_formatters,

    -- -------------------------------------------------------------------------
    -- Terraform / OpenTofu / HCL
    -- -------------------------------------------------------------------------
    terraform = terraform_formatters,
    ["terraform-vars"] = terraform_formatters,
    hcl = { "hcl", lsp_format = "fallback" },
    terragrunt = { "terragrunt_hclfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Nix
    -- -------------------------------------------------------------------------
    nix = nix_formatters,

    -- -------------------------------------------------------------------------
    -- Kubernetes / Cloud / CI
    -- -------------------------------------------------------------------------
    --
    -- Most Kubernetes / CloudFormation / GitHub Actions / GitLab CI manifests
    -- are YAML, so they automatically use the YAML dispatcher above.
    --
    ["yaml.github"] = yaml_formatters,
    ["yaml.gitlab"] = yaml_formatters,

    -- -------------------------------------------------------------------------
    -- Bicep
    -- -------------------------------------------------------------------------
    bicep = { "bicep", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Cue
    -- -------------------------------------------------------------------------
    cue = { "cue_fmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- KCL
    -- -------------------------------------------------------------------------
    kcl = { "kcl", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Bazel / Starlark
    -- -------------------------------------------------------------------------
    bzl = { "buildifier", lsp_format = "fallback" },
    starlark = { "buildifier", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- CMake / Meson / Just
    -- -------------------------------------------------------------------------
    cmake = { "cmake_format", lsp_format = "fallback" },
    meson = { "meson", lsp_format = "fallback" },
    just = { "just", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Protobuf / OpenAPI
    -- -------------------------------------------------------------------------
    proto = { "buf", lsp_format = "fallback" },
    proto3 = { "buf", lsp_format = "fallback" },
    openapi = { "openapi_format", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Nginx
    -- -------------------------------------------------------------------------
    nginx = { "nginxfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Nomad
    -- -------------------------------------------------------------------------
    nomad = { "nomad_fmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Markdown / Documentation
    -- -------------------------------------------------------------------------
    markdown = { "mdformat", lsp_format = "fallback" },
    ["markdown.pandoc"] = { "mdformat", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- reStructuredText
    -- -------------------------------------------------------------------------
    rst = { "rstfmt", "docstrfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Typst
    -- -------------------------------------------------------------------------
    typst = { "typstfmt", "typstyle", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- TeX / LaTeX
    -- -------------------------------------------------------------------------
    tex = { "latexindent", lsp_format = "fallback" },
    plaintex = { "latexindent", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- BibTeX
    -- -------------------------------------------------------------------------
    bib = { "bibtex-tidy", lsp_format = "fallback" },
    bibtex = { "bibtex-tidy", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Git commit messages
    -- -------------------------------------------------------------------------
    gitcommit = { "commitmsgfmt", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Misc / DSLs
    -- -------------------------------------------------------------------------
    d2 = { "d2", lsp_format = "fallback" },
    kdl = { "kdlfmt", lsp_format = "fallback" },
    ledger = { "hledger-fmt", lsp_format = "fallback" },
    hurl = { "hurlfmt", lsp_format = "fallback" },
    typstyle = { "typstyle", lsp_format = "fallback" },

    -- -------------------------------------------------------------------------
    -- Universal fallback
    -- -------------------------------------------------------------------------
    --
    -- Anything not explicitly mapped above gets LSP formatting if the active
    -- language server supports it.
    --
    ["_"] = { lsp_format = "fallback" },
  },

  -- ===========================================================================
  -- FORMAT DEFAULTS
  -- ===========================================================================

  default_format_opts = {
    lsp_format = "fallback",
  },

  -- ===========================================================================
  -- FORMAT ON SAVE
  -- ===========================================================================
  --
  -- We want :w to save first, then format asynchronously.
  -- This keeps the editor responsive instead of blocking the save.
  --
  format_after_save = function(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    if not vim.bo[bufnr].modifiable then
      return
    end

    local name = vim.api.nvim_buf_get_name(bufnr)

    if name ~= "" then
      local size = vim.fn.getfsize(name)

      -- Don't automatically format gigantic/generated files.
      if size > 2 * 1024 * 1024 then
        return
      end
    end

    return {
      timeout_ms = 1000,
      lsp_format = "fallback",
    }
  end,

  -- ===========================================================================
  -- ERRORS / NOTIFICATIONS
  -- ===========================================================================

  notify_on_error = true,

  -- Unknown/uninstalled formatters shouldn't spam you on every save.
  notify_no_formatters = false,

  log_level = vim.log.levels.ERROR,
}

return options
