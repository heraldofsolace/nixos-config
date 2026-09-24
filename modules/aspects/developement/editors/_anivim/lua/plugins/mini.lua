if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

-- mini.nvim is a single nix package containing every mini.* module.
-- Each module gets its own config file under plugins/mini/<name>.lua
-- (not a real lazy spec, just a plain table with a setup() function),
-- and they are all wired up here so lazy only tracks one real plugin.
local modules = {
    'base16',
    'ai',
    'align',
    'bracketed',
    'bufremove',
    'comment',
    'cursorword',
    'diff',
    'icons',
    'indentscope',
    'input',
    'map',
    'pairs',
    'sessions',
    'splitjoin',
    'starter',
    -- 'statusline' left out on purpose: lualine.nvim is back in charge of
    -- the statusline (see plugins/lualine.lua). The module stays installed
    -- and configured in plugins/mini/statusline.lua, just never require()'d,
    -- so it's disabled rather than uninstalled.
    'surround',
    'tabline',
    'trailspace',
    'files',
    'move',
    'pick',
    'extra',
    'visits',
    'hipatterns',
    'clue'
}

return {
    'nvim-mini/mini.nvim',
    version = false,
    config = function()
        for _, name in ipairs(modules) do
            require('plugins.mini.' .. name).setup()
        end
    end
}
