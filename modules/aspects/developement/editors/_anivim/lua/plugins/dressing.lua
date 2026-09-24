if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

-- vim.ui.input() is handled by mini.input (see plugins/mini/input.lua);
-- dressing only owns vim.ui.select() now, so the two don't fight over input.
return {'stevearc/dressing.nvim', opts = {input = {enabled = false}}}
