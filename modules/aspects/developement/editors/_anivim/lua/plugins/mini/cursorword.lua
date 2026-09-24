-- Underlines other occurrences of the word under the cursor. Overlaps a bit
-- with the LSP document_highlight autocmd in plugins/nvim_lsp.lua, but that
-- one only fires in LSP-attached buffers, so this still covers plain text.
return {
    setup = function() require('mini.cursorword').setup {} end
}
