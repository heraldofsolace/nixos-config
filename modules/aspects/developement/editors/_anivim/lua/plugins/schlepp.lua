if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    'zirrostig/vim-schlepp',
    config = function()
        local keymaps = {
            {
                '<Up>',
                '<Plug>SchleppUp',
                description = "Schlepp up",
                opts = {unique = true},
                mode = 'v'
            }, {
                '<Down>',
                '<Plug>SchleppDown',
                description = "Schlepp down",
                opts = {unique = true},
                mode = 'v'
            }, {
                '<Left>',
                '<Plug>SchleppLeft',
                description = "Schlepp left",
                opts = {unique = true},
                mode = 'v'
            }, {
                '<Right>',
                '<Plug>SchleppRight',
                description = "Schlepp right",
                opts = {unique = true},
                mode = 'v'
            }, {
                '<Plug>SchleppToggleReindent',
                description = "Schlepp toggle reindent",
                opts = {unique = true},
                mode = {'v', 'i'}
            }, {
                'Dk',
                '<Plug>SchleppDupUp',
                description = "Schlepp duplicate up",
                opts = {unique = true},
                mode = 'v'
            }, {
                'Dj',
                '<Plug>SchleppDupDown',
                description = "Schlepp duplicate down",
                opts = {unique = true},
                mode = 'v'
            }, {
                'Dh',
                '<Plug>SchleppDupLeft',
                description = "Schlepp duplicate left",
                opts = {unique = true},
                mode = 'v'
            }, {
                'Dl',
                '<Plug>SchleppDupRight',
                description = "Schlepp duplicate right",
                opts = {unique = true},
                mode = 'v'
            }
        }

        require('legendary').keymaps(keymaps)
    end
}

