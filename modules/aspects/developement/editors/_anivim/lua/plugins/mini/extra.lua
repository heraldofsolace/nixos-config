-- Extra pickers used alongside plugins/mini/pick.lua, replacing the rest
-- of telescope.nvim's keymaps plus telescope-frecency/smart-open.nvim
-- (frecency now comes from mini.visits, see plugins/mini/visits.lua).
return {
    setup = function()
        require('mini.extra').setup {}

        local pickers = require('mini.extra').pickers
        local function bufcommits()
            pickers.git_commits({path = vim.api.nvim_buf_get_name(0)})
        end
        local function smart_open() pickers.visit_paths() end

        local keymaps = {
            {
                '<leader>fo',
                pickers.oldfiles,
                description = 'Pick old files',
                opts = {noremap = true}
            }, {
                '<leader>fr',
                pickers.registers,
                description = 'Pick registers',
                opts = {noremap = true}
            }, {
                '<leader>fk',
                pickers.keymaps,
                description = 'Pick keymaps',
                opts = {noremap = true}
            }, {
                '<leader>fc',
                pickers.commands,
                description = 'Pick commands',
                opts = {noremap = true}
            }, {
                '<leader>fgc',
                pickers.git_commits,
                description = 'Pick git commits',
                opts = {noremap = true}
            }, {
                '<leader>fgb',
                bufcommits,
                description = 'Pick git buffer commits',
                opts = {noremap = true}
            }, {
                '<leader>fcf',
                function() pickers.buf_lines({scope = 'current'}) end,
                description = 'Pick current buffer fuzzy find',
                opts = {noremap = true}
            }, {
                '<leader>fbm',
                pickers.marks,
                description = 'Pick marks',
                opts = {noremap = true}
            }, {
                '<leader>ccs',
                pickers.colorschemes,
                description = 'Pick colorscheme',
                opts = {noremap = true}
            }, {
                '<leader>frc',
                smart_open,
                description = 'Pick by frecency',
                opts = {noremap = true}
            }, {
                '<leader><leader>',
                smart_open,
                description = 'Toggle smart open',
                opts = {noremap = true, silent = true}
            }
        }

        require('legendary').keymaps(keymaps)
    end
}
