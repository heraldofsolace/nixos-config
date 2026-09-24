-- Replaces zirrostig/vim-schlepp. Primary bindings are Alt + this config's
-- own home-row direction keys (core/keys.lua's global `keys` table and the
-- '%' string-interpolation trick, so this tracks vim.g.keyboard_layout the
-- same way core/keys.lua's own bindings do), covering both visual-mode
-- selection move (Schlepp's job) and normal-mode single-line move (which
-- Schlepp never had). The original arrow-key visual bindings are kept
-- working too via a couple of extra manual mappings. Schlepp's "duplicate
-- and move" (Dk/Dj/Dh/Dl) has no mini.move equivalent, so it stays dropped.
return {
    setup = function()
        require('mini.move').setup {
            mappings = {
                left = '<M-${left}>' % keys,
                right = '<M-${right}>' % keys,
                down = '<M-${down}>' % keys,
                up = '<M-${up}>' % keys,
                line_left = '<M-${left}>' % keys,
                line_right = '<M-${right}>' % keys,
                line_down = '<M-${down}>' % keys,
                line_up = '<M-${up}>' % keys
            }
        }

        local move = require('mini.move')
        vim.keymap.set('x', '<Left>', function() move.move_selection('left') end)
        vim.keymap.set('x', '<Right>', function() move.move_selection('right') end)
        vim.keymap.set('x', '<Down>', function() move.move_selection('down') end)
        vim.keymap.set('x', '<Up>', function() move.move_selection('up') end)
    end
}
