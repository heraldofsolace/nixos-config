-- Session save/restore, picked interactively via vim.ui.select (styled by
-- dressing.nvim, which is still installed).
return {
    setup = function()
        require('mini.sessions').setup {}
        local sessions = require('mini.sessions')
        vim.keymap.set('n', '<leader>Ss', function() sessions.select('write') end,
                        {desc = 'Save session'})
        vim.keymap.set('n', '<leader>Sl', function() sessions.select('read') end,
                        {desc = 'Load session'})
        vim.keymap.set('n', '<leader>Sd', function() sessions.select('delete') end,
                        {desc = 'Delete session'})
    end
}
