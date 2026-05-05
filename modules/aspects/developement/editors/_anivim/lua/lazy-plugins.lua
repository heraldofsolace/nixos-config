--[[ ------------------------------------- ]] --[[ This is our lazy wrapper. First we    ]] --[[ combine our plugin names into 1 list  ]] --[[ or table, then we override any that   ]] --[[ have a different name when loaded via ]] --[[ nix. Then we also get the lazy path   ]] --[[ ------------------------------------- ]] local 
    pluginList = nil
local nixLazyPath = nil
if require('nixCatsUtils').isNixCats then
    nixLazyPath = require("nixCats").pawsible({"allPlugins", "start", "lazy.nvim" })
end

--[[ ------------------------------------------- ]]
--[[ this is just the options set that is passed ]]
--[[ in as the second argument to the normal     ]]
--[[ require('lazy').setup({},{}) function.      ]]
--[[ ------------------------------------------- ]]
-- NOTE: nixCats: You might want to move the lazy-lock.json file
local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and type(nixCats.settings.unwrappedCfgPath) == 'string' then
    return nixCats.settings.unwrappedCfgPath .. '/lazy-lock.json'
  else
    return vim.fn.stdpath 'config' .. '/lazy-lock.json'
  end
end
local lazyOptions = {
  lockfile = getlockfilepath(),
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}


--[[ ------------------------------------------- ]]
--[[ and now we call our wrapper, passing it our ]]
--[[ plugin name list(or table),                 ]]
--[[ and our lazypath when loaded via nix.       ]]
--[[ after that we just pass in the normal 2     ]]
--[[ remaining arguments to the lazy setup()     ]]
--[[ ------------------------------------------- ]]
require('nixCatsUtils.lazyCat').setup(nixLazyPath, {
    {import = "plugins"}
}, lazyOptions)
