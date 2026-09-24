-- Replaces lewis6991/gitsigns.nvim. mini.diff diffs the buffer against the
-- git index, so "apply hunk" plays the role of gitsigns' "stage hunk" and
-- "reset hunk" discards back to the index, same as before.
-- Not every gitsigns action has a mini.diff equivalent (line blame,
-- diffthis against HEAD/last commit, undo-stage) since mini.diff has no
-- concept of them; those keybinds are dropped rather than faked.
return {
    setup = function()
        local diff = require('mini.diff')
        diff.setup {
            mappings = {
                apply = '<leader>hs',
                reset = '<leader>hr',
                textobject = 'ih',
                goto_prev = '[c',
                goto_next = ']c'
            }
        }

        vim.keymap.set('n', '<leader>hS', function() diff.do_hunks(0, 'apply') end,
                        {desc = 'git Stage buffer'})
        vim.keymap.set('n', '<leader>hR', function() diff.do_hunks(0, 'reset') end,
                        {desc = 'git Reset buffer'})
        vim.keymap.set('n', '<leader>hp', diff.toggle_overlay,
                        {desc = 'preview git hunk'})
        vim.keymap.set('n', '<leader>td', diff.toggle_overlay,
                        {desc = 'toggle git show deleted'})
    end
}
