if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {},
    lazy = true,
    cmd = "TroubleToggle"
}
