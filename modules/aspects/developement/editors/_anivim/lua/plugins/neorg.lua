if not require('nixCatsUtils').enableForCategory('org') then return {} end

return {
    "nvim-neorg/neorg",
    dependencies = {
        "nvim-lua/plenary.nvim", "nvim-neorg/lua-utils.nvim",
        'MunifTanjim/nui.nvim', "nvim-neotest/nvim-nio", "pysan3/pathlib.nvim"
    },
    config = function()
        require('neorg').setup {
            -- Tell Neorg what modules to load
            load = {
                ["core.defaults"] = {}, -- Load all the default modules
                ["core.concealer"] = {}, -- Allows for use of icons
                ["core.dirman"] = { -- Manage your directories with Neorg
                    config = {workspaces = {my_workspace = "~/neorg"}}
                }
            }
        }
    end
}

