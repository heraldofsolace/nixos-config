if not require('nixCatsUtils').enableForCategory('dev.ruby') then
    return {}
end

return {'tpope/vim-rails'}
