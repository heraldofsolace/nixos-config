if not require('nixCatsUtils').enableForCategory('format') then return
    {} end

return {'stevearc/conform.nvim', opts = {}, event = "BufWritePre"}
