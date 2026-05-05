if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    "folke/zen-mode.nvim",
    lazy = true,
    cmd = "ZenMode",
    config = function()
        require("zen-mode").setup {}
        require('legendary').keymaps({
            {
                '<leader>ze',
                ':ZenMode<cr>',
                description = "Toggle Zen mode",
                opts = {silent = true, noremap = true}
            }
        })
    end
}

