if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
        modes = {
            char = {
                keys = { "f", "F", ["t"] = "L", ["T"] = "H", ";", "," },
            }
        }
        
    },
    keys = {
        {
            "<leader>fj",
            mode = {"n", "x", "o"},
            function() require("flash").jump() end,
            desc = "Flash"
        }, {
            "<leader>fjt",
            mode = {"n", "x", "o"},
            function() require("flash").treesitter() end,
            desc = "Flash Treesitter"
        }, {
            "r",
            mode = "o",
            function() require("flash").remote() end,
            desc = "Remote Flash"
        }, {
            "R",
            mode = {"o", "x"},
            function() require("flash").treesitter_search() end,
            desc = "Treesitter Search"
        }, {
            "<c-s>",
            mode = {"c"},
            function() require("flash").toggle() end,
            desc = "Toggle Flash Search"
        }
    }
}
