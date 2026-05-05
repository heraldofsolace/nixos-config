if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = {"nvim-tree/nvim-web-devicons"}
}
