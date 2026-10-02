require("nvchad.mappings")

local map = vim.keymap.set

-- ============================================================================
-- BASIC MAPPINGS
-- ============================================================================

map("n", ";", ":", {
    desc = "CMD enter command mode",
})

map("i", "jk", "<ESC>", {
    desc = "Exit insert mode",
})

-- ============================================================================
-- SAFE KEYMAP REGISTRATION
--
-- Refuses to overwrite an existing mapping.
-- ============================================================================

local function safe_map(mode, lhs, rhs, opts)
    opts = opts or {}

    local existing = vim.fn.maparg(lhs, mode, false, true)

    if existing and existing.lhs and existing.lhs ~= "" then
        vim.schedule(function()
            vim.notify(
                string.format(
                    "Keymap collision: %s [%s] already belongs to %s",
                    lhs,
                    mode,
                    existing.desc ~= "" and existing.desc or existing.rhs
                ),
                vim.log.levels.WARN,
                { title = "Keymap" }
            )
        end)

        return false
    end

    map(mode, lhs, rhs, opts)
    return true
end

-- ============================================================================
-- RESERVED KEYMAPS
-- ============================================================================

vim.g.user_keymap_space = {
    debug = {
        "<F5>",
        "<F9>",
        "<F10>",
        "<F11>",
        "<S-F11>",
        "<leader>db",
        "<leader>dB",
        "<leader>dc",
        "<leader>de",
        "<leader>di",
        "<leader>do",
        "<leader>dO",
        "<leader>dp",
        "<leader>dr",
        "<leader>dR",
        "<leader>ds",
        "<leader>dt",
        "<leader>du",
        "<leader>dw",
    },

    build_run = {
        "<F6>",
        "<F7>",
        "<F8>",
        "<leader>oa",
        "<leader>or",
        "<leader>ot",
    },

    testing = {
        "<leader>ta",
        "<leader>td",
        "<leader>tf",
        "<leader>tn",
        "<leader>to",
        "<leader>tO",
        "<leader>ts",
        "<leader>tx",
    },
}

-- ============================================================================
-- KEYMAP AUDIT
-- ============================================================================

vim.api.nvim_create_user_command("KeyCheck", function()
    local spaces = vim.g.user_keymap_space

    local function audit(group, keys)
        print("")
        print("[" .. group .. "]")

        for _, lhs in ipairs(keys) do
            local mapping = vim.fn.maparg(lhs, "n", false, true)

            if mapping and mapping.lhs and mapping.lhs ~= "" then
                print(
                    string.format(
                        "  ❌ %-14s %s",
                        lhs,
                        mapping.desc ~= "" and mapping.desc or mapping.rhs
                    )
                )
            else
                print(string.format("  ✅ %-14s FREE", lhs))
            end
        end
    end

    audit("DEBUG", spaces.debug)
    audit("BUILD / RUN", spaces.build_run)
    audit("TEST", spaces.testing)
end, {
    desc = "Check reserved keymaps",
})

-- ============================================================================
-- PREFIX AUDIT
-- ============================================================================

vim.api.nvim_create_user_command("KeyPrefixes", function()
    local maps = vim.api.nvim_get_keymap("n")
    local seen = {}

    for _, m in ipairs(maps) do
        if m.lhs and m.lhs ~= "" then
            seen[m.lhs] = m
        end
    end

    local ours = {}

    for _, group in pairs(vim.g.user_keymap_space) do
        for _, lhs in ipairs(group) do
            ours[lhs] = true
        end
    end

    local found = false

    print("KEY PREFIX AUDIT")
    print("")

    for ours_lhs in pairs(ours) do
        for other_lhs in pairs(seen) do
            if ours_lhs ~= other_lhs then
                if vim.startswith(ours_lhs, other_lhs) then
                    print(
                        string.format(
                            "⚠️  %s is a prefix of existing %s",
                            other_lhs,
                            ours_lhs
                        )
                    )

                    found = true
                elseif vim.startswith(other_lhs, ours_lhs) then
                    print(
                        string.format(
                            "⚠️  %s is a prefix of existing %s",
                            ours_lhs,
                            other_lhs
                        )
                    )

                    found = true
                end
            end
        end
    end

    if not found then
        print("✅ No prefix collisions found.")
    end

    print("")
    print("Done.")
end, {
    desc = "Check keymap prefixes",
})
