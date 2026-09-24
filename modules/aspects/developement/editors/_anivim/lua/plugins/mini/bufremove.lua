-- Close a buffer without wrecking the window layout. Binds <leader>bd,
-- which used to be a hand-rolled :Bclose/:tabclose vimscript mapping in
-- core/keys.lua (now removed as dead code).
return {
    setup = function()
        require('mini.bufremove').setup {}
        vim.keymap.set('n', '<leader>bd', function()
            require('mini.bufremove').delete(0, false)
        end, {desc = 'Delete buffer, keep window layout'})
    end
}
