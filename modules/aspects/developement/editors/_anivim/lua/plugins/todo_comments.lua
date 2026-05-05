if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end
return {
    "folke/todo-comments.nvim",
    event = {"BufNewFile", "BufReadPost"},
    dependencies = {"nvim-lua/plenary.nvim", lazy = true},
    opts = {}
}
