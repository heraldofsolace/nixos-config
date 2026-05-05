if not require('nixCatsUtils').enableForCategory('markdown') then
    return {}
end

return {
    "ellisonleao/glow.nvim",
    init = function()
        require('legendary').keymap({
            '<leader>pg',
            ':Glow<cr>',
            description = "Glow",
            opts = {noremap = true}
        })

    end,
    ft = "markdown",
    cmd = "Glow",
    config = true
}
