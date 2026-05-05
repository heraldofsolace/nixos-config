if not require('nixCatsUtils').enableForCategory('debug') then return {} end
return {
    {
        "rcarriga/nvim-dap-ui",
        opts = {},
        keys = {
            {
                "<leader>dui",
                function() require("dapui").toggle() end,
                desc = "Toggle DAP-UI"
            }
        },
        dependencies = {
            {"mfussenegger/nvim-dap", lazy = true},
            {"nvim-neotest/nvim-nio", lazy = true}, {
                "theHamsta/nvim-dap-virtual-text",
                dependencies = {'nvim-treesitter/nvim-treesitter'},
                opts = {commented = true},
                lazy = true
            }
        }
    }
}
