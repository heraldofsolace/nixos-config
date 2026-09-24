-- Replaces the core of nvim-telescope/telescope.nvim
return {
    setup = function()
        require('mini.pick').setup {
            window = {config = {border = 'rounded'}}
        }

        local pick = require('mini.pick').builtin
        local keymaps = {
            {
                '<leader>ff',
                pick.files,
                description = 'Pick search files',
                opts = {noremap = true}
            }, {
                '<leader>fg',
                pick.grep_live,
                description = 'Pick live grep',
                opts = {noremap = true}
            }, {
                '<leader>fb',
                pick.buffers,
                description = 'Pick buffer',
                opts = {noremap = true}
            }, {
                '<leader>fh',
                pick.help,
                description = 'Pick help tags',
                opts = {noremap = true}
            }
        }

        require('legendary').keymaps(keymaps)
    end
}
