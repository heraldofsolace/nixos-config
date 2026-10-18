-- Replaces goolord/alpha-nvim. mini.starter's own query system (type the
-- item's leading letters, then <CR>) takes the place of alpha's per-button
-- keybinds, so item names double as the shortcut hint.
-- Same live-palette-cycling trick as the fish sparkline banner (see
-- shells/fish.nix's palette-cat): each header line gets the next accent
-- color in sequence, so the dashboard reads as *this* theme too.
local function setup_gradient_highlights()
    local base16 = require('nixCats').extra('base16colors')
    local accents = {
        base16.base08,
        base16.base09,
        base16.base0A,
        base16.base0B,
        base16.base0C,
        base16.base0D,
        base16.base0E
    }
    for i, hex in ipairs(accents) do
        vim.api.nvim_set_hl(0, 'MiniStarterGradient' .. i, { fg = hex })
    end
    return #accents
end

local function apply_header_gradient(content)
    local starter = require('mini.starter')
    local n_colors = setup_gradient_highlights()
    local coords = starter.content_coords(content, 'header')
    for i, coord in ipairs(coords) do
        content[coord.line][coord.unit].hl = 'MiniStarterGradient' .. (((i - 1) % n_colors) + 1)
    end
    return content
end

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
                apply_header_gradient,
                starter.gen_hook.adding_bullet(),
                starter.gen_hook.aligning('center', 'center')
            }
        }
    end
}
