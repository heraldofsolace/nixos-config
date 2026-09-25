if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    {'tpope/vim-sleuth'}, {'tpope/vim-fugitive'}, {'tpope/vim-rhubarb'},
    {'tpope/vim-repeat'}, {'tpope/vim-dadbod'}, {
        'kristijanhusak/vim-dadbod-ui',
        config = function()
            require('legendary').keymap({
                '<leader>Db',
                ':DBUI<cr>',
                description = 'Open DBUI',
                opts = {silent = true, noremap = true}
            })
        end

    }, {'tpope/vim-eunuch'}, {'tpope/vim-projectionist'},
    {'tpope/vim-speeddating'}, {'gcmt/wildfire.vim'},
    {'gpanders/editorconfig.nvim'}, {'rktjmp/lush.nvim'},
    {"christoomey/vim-tmux-navigator"}, {'direnv/direnv.vim'},
    {'junegunn/vim-peekaboo'}, {
        "m4xshen/hardtime.nvim",
        dependencies = {"MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim"},
        opts = {}
    }
}
