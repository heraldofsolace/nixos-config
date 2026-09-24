-- Replaces goolord/alpha-nvim. mini.starter's own query system (type the
-- item's leading letters, then <CR>) takes the place of alpha's per-button
-- keybinds, so item names double as the shortcut hint.
return {
    setup = function()
        local starter = require('mini.starter')

        local header = table.concat({
            '   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ',
            '    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
            '          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
            '           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
            '          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
            '   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
            '  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
            ' ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
            ' ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
            '      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
            '       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     '
        }, '\n')

        starter.setup {
            header = header,
            items = {
                starter.sections.builtin_actions(),
                {
                    name = 'Find File',
                    action = function()
                        require('mini.pick').builtin.files()
                    end,
                    section = 'Find'
                }, {
                    name = 'Recent File',
                    action = function()
                        require('mini.extra').pickers.oldfiles()
                    end,
                    section = 'Find'
                }, {
                    name = 'Find Word',
                    action = function()
                        require('mini.pick').builtin.grep_live()
                    end,
                    section = 'Find'
                }, {
                    name = 'Bookmarks',
                    action = function()
                        require('mini.extra').pickers.marks()
                    end,
                    section = 'Find'
                }, {
                    name = 'Settings',
                    action = 'e $MYVIMRC | cd %:p:h',
                    section = 'Find'
                }
            },
            content_hooks = {
                starter.gen_hook.adding_bullet(),
                starter.gen_hook.aligning('center', 'center')
            }
        }
    end
}
