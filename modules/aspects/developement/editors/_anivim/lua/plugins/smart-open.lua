if not require('nixCatsUtils').enableForCategory('telescope') then
    return {}
end

return {
    "danielfalk/smart-open.nvim",
    branch = "0.3.x",
    config = function() require("telescope").load_extension("smart_open") end,
    dependencies = {"kkharji/sqlite.lua"},
    keys = {
        {
            "<leader><leader>",
            function()
                require("telescope").extensions.smart_open.smart_open({
                    match_algorithm = "fzf"
                })
            end,
            desc = "Toggle smart open",
            noremap = true,
            silent = true
        }
    }
}
