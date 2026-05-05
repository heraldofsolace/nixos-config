if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
        exclude = {
            filetypes = {
                "help", "terminal", "alpha", "packer", "lspinfo",
                "TelescopePrompt", "TelescopeResults", "nvchad_cheatsheet", ""
            },
            buftypes = {"terminal"}
        }
    }
}
