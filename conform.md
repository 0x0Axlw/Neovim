# ⚔️ NvChad — Mahoraga Build

A heavily customized **NvChad / Neovim IDE configuration** designed for broad language and tooling coverage.

The goal is simple:

> Throw almost any project at Neovim and let it adapt to the language, tooling, and workflow instead of maintaining a separate editor for every stack.

This config is primarily developed and tested on **Arch Linux**.

---

## ✨ What This Config Is

This setup is built around:

- **NvChad**
- **Neovim**
- **LSP**
- **Treesitter**
- **Conform.nvim**
- **nvim-lint**
- **Trouble.nvim**
- **LazyGit**
- **Matugen / WallSync**
- **Cord.nvim**
- broad language/server support

The configuration intentionally separates responsibilities:

```text
LSP
│
├── completion
├── definitions
├── references
├── symbols
├── diagnostics
└── code intelligence

Conform
│
└── formatting

nvim-lint
│
└── linting

Treesitter
│
└── syntax / parsing

LazyGit / Git integrations
│
└── version control

DAP
│
└── debugging

Matugen / WallSync
│
└── dynamic theme generation
