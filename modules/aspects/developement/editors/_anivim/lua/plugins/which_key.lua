if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {'folke/which-key.nvim', opts = {}}
