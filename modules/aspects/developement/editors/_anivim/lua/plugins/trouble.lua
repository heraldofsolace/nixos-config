if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    "folke/trouble.nvim",
    opts = {},
    lazy = true,
    cmd = "TroubleToggle"
}
