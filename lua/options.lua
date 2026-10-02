require "nvchad.options"

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    severity_sort = true,

    update_in_insert = false,

    float = {
        border = "rounded",
        source = true,
    },
})
