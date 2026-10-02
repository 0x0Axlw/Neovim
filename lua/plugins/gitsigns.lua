return {
    "lewis6991/gitsigns.nvim",

    event = { "BufReadPre", "BufNewFile" },

    opts = {
        signs = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "▁" },
            topdelete = { text = "▔" },
            changedelete = { text = "▎" },
            untracked = { text = "▎" },
        },

        signcolumn = true,
        numhl = false,
        linehl = false,

        current_line_blame = false,

        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 500,
            ignore_whitespace = false,
        },

        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

        update_debounce = 100,

        preview_config = {
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },

        on_attach = function(bufnr)
            local gs = require("gitsigns")

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = bufnr,
                    silent = true,
                    desc = desc,
                })
            end

            -- ============================================================
            -- HUNK NAVIGATION
            -- ============================================================

            map("n", "]c", function()
                if vim.wo.diff then
                    return "]c"
                end

                vim.schedule(function()
                    gs.next_hunk()
                end)

                return "<Ignore>"
            end, "Next Git hunk")

            map("n", "[c", function()
                if vim.wo.diff then
                    return "[c"
                end

                vim.schedule(function()
                    gs.prev_hunk()
                end)

                return "<Ignore>"
            end, "Previous Git hunk")

            -- ============================================================
            -- HUNK OPERATIONS
            -- ============================================================

            map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
            map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")

            map("v", "<leader>hs", function()
                gs.stage_hunk({
                    vim.fn.line("."),
                    vim.fn.line("v"),
                })
            end, "Stage selected hunk")

            map("v", "<leader>hr", function()
                gs.reset_hunk({
                    vim.fn.line("."),
                    vim.fn.line("v"),
                })
            end, "Reset selected hunk")

            map("n", "<leader>hS", gs.stage_buffer, "Stage entire buffer")
            map("n", "<leader>hR", gs.reset_buffer, "Reset entire buffer")
            map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

            -- ============================================================
            -- PREVIEW / DIFF
            -- ============================================================

            map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
            map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk inline")

            map("n", "<leader>hd", gs.diffthis, "Diff against index")

            map("n", "<leader>hD", function()
                gs.diffthis("HEAD")
            end, "Diff against HEAD")

            -- ============================================================
            -- BLAME
            -- ============================================================

            map("n", "<leader>hb", gs.blame_line, "Blame line")

            map("n", "<leader>hB", function()
                gs.blame_line({
                    full = true,
                })
            end, "Full blame line")

            map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle inline blame")

            -- ============================================================
            -- DISPLAY
            -- ============================================================

            map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted lines")
            map("n", "<leader>tw", gs.toggle_word_diff, "Toggle word diff")

            -- ============================================================
            -- TEXT OBJECT
            -- ============================================================

            vim.keymap.set({ "o", "x" }, "ih", gs.select_hunk, {
                buffer = bufnr,
                silent = true,
                desc = "Inside Git hunk",
            })
        end,
    },

    -- ==============================================================
    -- LAZYGIT
    -- ==============================================================

    keys = {
        {
            "<leader>gg",
            function()
                local git_root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
                local config = vim.fn.stdpath("config") .. "/.lazygit.yml"

                local cmd = { "lazygit" }

                if vim.uv.fs_stat(config) then
                    cmd[#cmd + 1] = "--use-config-file=" .. config
                end

                vim.cmd("tabnew")

                local bufnr = vim.api.nvim_get_current_buf()

                vim.fn.termopen(cmd, {
                    cwd = git_root,

                    on_exit = function()
                        vim.schedule(function()
                            if not vim.api.nvim_buf_is_valid(bufnr) then
                                return
                            end

                            if vim.api.nvim_get_current_buf() == bufnr then
                                pcall(vim.cmd, "tabclose")
                            else
                                pcall(vim.api.nvim_buf_delete, bufnr, {
                                    force = true,
                                })
                            end
                        end)
                    end,
                })

                vim.cmd("startinsert")
            end,
            mode = "n",
            desc = "Open LazyGit",
        },
    },
}
