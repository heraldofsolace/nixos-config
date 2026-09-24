-- Replaces stevearc/oil.nvim (which had no keybind of its own; "-" is
-- mini.files' own documented convention for opening at the current file).
return {
    setup = function()
        require('mini.files').setup {}
        vim.keymap.set('n', '-', function()
            require('mini.files').open(vim.api.nvim_buf_get_name(0), false)
        end, {desc = 'Open file explorer'})
    end
}
