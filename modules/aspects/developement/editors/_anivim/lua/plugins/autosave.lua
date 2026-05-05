if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    "okuuva/auto-save.nvim",
    event = {"InsertLeave", "TextChanged"},
    config = function()
        vim.g.auto_save = 1
        vim.g.auto_save_in_insert_mode = 0
        vim.g.auto_save_no_updatetime = 1
    end
}

