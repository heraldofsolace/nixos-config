if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end


return {
    'akinsho/bufferline.nvim',
    version = "v4.9.1",
    dependencies = 'nvim-tree/nvim-web-devicons'
}
