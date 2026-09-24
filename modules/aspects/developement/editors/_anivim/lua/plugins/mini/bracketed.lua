-- Generic [x / ]x navigation (buffers, diagnostics, files, jumps, treesitter
-- nodes, yank, etc). The 'comment' and 'indent' targets default to the same
-- [c/]c and [i/]i keys already claimed by mini.diff (git hunks) and
-- mini.indentscope (scope top/bottom) respectively, so both are disabled
-- here rather than fought over.
return {
    setup = function()
        require('mini.bracketed').setup {
            comment = {suffix = ''},
            indent = {suffix = ''}
        }
    end
}
