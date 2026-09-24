return {
    setup = function()
        require('mini.base16').setup {
            palette = require('nixCats').extra('base16colors')
        }
    end
}
