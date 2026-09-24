-- Nicer vim.ui.input() prompts. Only covers input(); dressing.nvim stays
-- installed for vim.ui.select(), which has no mini.nvim equivalent.
return {
    setup = function() require('mini.input').setup {} end
}
