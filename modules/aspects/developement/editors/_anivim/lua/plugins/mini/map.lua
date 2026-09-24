-- Minimap sidebar, toggled with <leader>mm
return {
    setup = function()
        require('mini.map').setup {}
        vim.keymap.set('n', '<leader>mm', function() require('mini.map').toggle() end,
                        {desc = 'Toggle minimap'})
    end
}
