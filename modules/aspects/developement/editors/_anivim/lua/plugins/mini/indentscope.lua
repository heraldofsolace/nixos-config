-- Replaces lukas-reineke/indent-blankline.nvim
return {
    setup = function()
        require('mini.indentscope').setup {}

        local disabled_ft = {
            help = true,
            terminal = true,
            ministarter = true,
            lspinfo = true,
            minipick = true,
            minifiles = true,
            [''] = true
        }
        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function()
                if disabled_ft[vim.bo.filetype] or vim.bo.buftype == 'terminal' then
                    vim.b.miniindentscope_disable = true
                end
            end
        })
    end
}
