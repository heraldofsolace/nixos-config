-- Highlights trailing whitespace; <leader>tw trims it from the buffer
return {
    setup = function()
        require('mini.trailspace').setup {}
        vim.keymap.set('n', '<leader>tw', function()
            require('mini.trailspace').trim()
        end, {desc = 'Trim trailing whitespace'})
    end
}
