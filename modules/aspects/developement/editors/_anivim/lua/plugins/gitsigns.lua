if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    -- Kept only for git blame and diff-against-commit, which mini.diff
    -- (see plugins/mini/diff.lua) has no equivalent for. Hunk stage/reset,
    -- navigation, and the gutter signs stay on mini.diff, so gitsigns'
    -- own sign rendering is turned off to avoid a duplicate gutter.
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup {
            signcolumn = false,
            numhl = false,
            linehl = false,
            word_diff = false,
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                map('n', '<leader>hb', function() gs.blame_line {full = false} end,
                    {desc = 'git blame line'})
                map('n', '<leader>hd', gs.diffthis,
                    {desc = 'git diff against index'})
                map('n', '<leader>hD', function() gs.diffthis '~' end,
                    {desc = 'git diff against last commit'})
                map('n', '<leader>tb', gs.toggle_current_line_blame,
                    {desc = 'toggle git blame line'})
            end
        }
    end
}
