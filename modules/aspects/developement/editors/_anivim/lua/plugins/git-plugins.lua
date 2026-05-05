if not require('nixCatsUtils').enableForCategory('gitPlugins') then
    return {}
end

return {
    {
        'm-demare/hlargs.nvim',
        enabled = require('nixCatsUtils').enableForCategory('gitPlugins'),
        name = 'hlargs'
    }, {
        "kdheepak/lazygit.nvim",
        enabled = require('nixCatsUtils').enableForCategory('gitPlugins'),
        dependencies = {"nvim-lua/plenary.nvim"}
    }
}
