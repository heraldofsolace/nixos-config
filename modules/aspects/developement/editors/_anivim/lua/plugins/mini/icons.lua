-- Icon provider for the mini.* family (files/pick/tabline/starter).
-- Replaces nvim-web-devicons, which nothing but trouble.nvim depended on;
-- mock_nvim_web_devicons() shims that API so trouble.nvim keeps working
-- without the actual nvim-web-devicons plugin installed.
return {
    setup = function()
        require('mini.icons').setup {}
        require('mini.icons').mock_nvim_web_devicons()
    end
}
