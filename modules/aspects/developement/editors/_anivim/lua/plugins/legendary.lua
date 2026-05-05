if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    'mrjones2014/legendary.nvim',
    dependencies = 'kkharji/sqlite.lua',
    priority = 500,
    opts = {extensions = {lazy_nvim = true, which_key = {auto_register = true}}}
}

