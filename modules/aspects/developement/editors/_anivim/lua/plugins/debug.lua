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
            {
                "mfussenegger/nvim-dap",
                lazy = true,
                keys = {
                    {
                        "<leader>dB",
                        function() require("dap").toggle_breakpoint() end,
                        desc = "Toggle Breakpoint"
                    }, {
                        "<leader>dc",
                        function() require("dap").continue() end,
                        desc = "Continue"
                    }, {
                        "<leader>di",
                        function() require("dap").step_into() end,
                        desc = "Step Into"
                    }, {
                        "<leader>do",
                        function() require("dap").step_over() end,
                        desc = "Step Over"
                    }, {
                        "<leader>dO",
                        function() require("dap").step_out() end,
                        desc = "Step Out"
                    }, {
                        "<leader>dt",
                        function() require("dap").terminate() end,
                        desc = "Terminate"
                    }
                }
            },
            {"nvim-neotest/nvim-nio", lazy = true}, {
                "theHamsta/nvim-dap-virtual-text",
                dependencies = {'nvim-treesitter/nvim-treesitter'},
                opts = {commented = true},
                lazy = true
            }
        }
    }
}
