function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
getmetatable("").__mod = interp

keys = {left = "s", down = "n", up = "m", right = "t"}

if vim.g.keyboard_layout and vim.g.keyboard_layout == "qwerty" then
    keys.left = "h"
    keys.down = "j"
    keys.up = "k"
    keys.right = "l"
end
local keymaps = {
    -- Navigation
    {keys.left, 'h', opts = {noremap = true}},
    {keys.down, 'j', opts = {noremap = true}},
    {keys.up, 'k', opts = {noremap = true}},
    {keys.right, 'l', opts = {noremap = true}}, 
    -- map existing keys to hjkl
    {'h', keys.left, opts = {noremap = true}},
    {'j', keys.down, opts = {noremap = true}},
    {'k', keys.up, opts = {noremap = true}},
    {'l', keys.right, opts = {noremap = true}}, 
    -- Splits
    {'<leader>|', ':vsplit<cr>'}, {'<leader>-', ':split<cr>'},
    -- No-op for arrows
    -- {'<Up>', ''}, {'<Down>', ''}, {'<Left>', ''}, {'<Right>', ''}, 
    -- Save
    {'<leader>w', ':w!<cr>'}, 
    
    -- Search
    {
        '*',
        ":<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>",
        opts = {noremap = true},
        mode = 'v'
    }, {
        '#',
        ":<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>",
        opts = {noremap = true},
        mode = 'v'
    }, -- Window navigation (tmux-aware; vim.g.tmux_navigator_no_mappings in
    -- core/opts.lua stops vim-tmux-navigator also binding its own default
    -- <C-h/j/k/l>, so this is the only window-nav binding active)
    {'<C-${down}>' % keys, ':TmuxNavigateDown<cr>'},
    {'<C-${up}>' % keys, ':TmuxNavigateUp<cr>'},
    {'<C-${left}>' % keys, ':TmuxNavigateLeft<cr>'},
    {'<C-${right}>' % keys, ':TmuxNavigateRight<cr>'},
    -- Window resize on the same direction keys, one layer up (Alt instead
    -- of Ctrl), mirroring hyprland.lua's mod/CTRL/ALT modifier layering.
    -- Right/up grow, left/down shrink.
    {'<A-${left}>' % keys, ':vertical resize -5<cr>'},
    {'<A-${right}>' % keys, ':vertical resize +5<cr>'},
    {'<A-${down}>' % keys, ':resize -5<cr>'},
    {'<A-${up}>' % keys, ':resize +5<cr>'}, -- Buffer and tabs
    {'<leader>ba', ':bufdo bd<cr>'}, {'<leader>${right}' % keys, ':bnext<cr>'},
    {'<leader>${left}' % keys, ':bprevious<cr>'}, {'<leader>tn', ':tabnew<cr>'},
    {'<leader>tc', ':tabclose<cr>'}, {'<leader>tm', ':tabmove'},
    {'<leader>tt', ':tabnext<cr>'},
    {'<leader>tl', ':exe "tabn ".g:lasttab<CR>'},
    {'<leader>te', ':tabedit <c-r>=expand("%:p:h")<cr>/'},
    -- Scrolling with j and k
    {keys.down, 'gj'}, {keys.up, 'gk'}, -- Spell
    {'<leader>sn', ']s'}, {'<leader>sp', '[s'}, {'<leader>sa', 'zg'},
    {'<leader>s?', 'z='}, {'<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', mode = 'i'},

    -- cd
    {'<leader>cd', ':cd %:p:h<cr>:pwd<cr>'}, -- Buffer
    {'<leader>q', ':e ~/buffer<cr>'},

    -- Readline-like mappings
    {'<C-A>', '<Home>', mode = 'c'}, {'<C-E>', '<End>', mode = 'c'},
    {'<C-K>', '<C-U>', mode = 'c'}, {'<C-P>', '<Up>', mode = 'c'},
    {'<C-N>', '<Down>', mode = 'c'}
}

require('legendary').keymaps(keymaps)

vim.api.nvim_exec([[
        function! CmdLine(str)
            call feedkeys(":" . a:str)
        endfunction 

        function! VisualSelection(direction, extra_filter) range
            let l:saved_reg = @"
            execute "normal! vgvy"

            let l:pattern = escape(@", "\\/.*'$^~[]")
            let l:pattern = substitute(l:pattern, "\n$", "", "")

            if a:direction == 'gv'
                call CmdLine("Ack '" . l:pattern . "' " )
            elseif a:direction == 'replace'
                call CmdLine("%s" . '/'. l:pattern . '/')
            endif

            let @/ = l:pattern
            let @" = l:saved_reg
        endfunction
    ]], false)

local autocmds = {
    {'TabLeave', function() vim.g.lasttab = vim.fn.tabpagenr() end}, {
        'BufReadPost', function()
            if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
                vim.api.nvim_command("normal! g'\"")
            end
        end
    }, {
        'WinEnter', function()
            if (vim.bo.filetype ~= 'ministarter') then
                vim.opt.colorcolumn = "120"
                vim.opt.cul = true
            end
        end
    }, {
        'WinLeave', function()
            if (vim.bo.filetype ~= 'ministarter') then
                vim.opt.colorcolumn = "0"
                vim.opt.cul = false
            end
        end
    }, {
        {'BufLeave', 'FocusLost', 'InsertEnter'}, function()
            if (vim.bo.filetype ~= 'ministarter') then
                vim.opt.relativenumber = false
            end
        end
    }, {
        {'BufEnter', 'FocusGained', 'InsertLeave'}, function()
            if (vim.bo.filetype ~= 'ministarter') then
                vim.opt.relativenumber = true
            end
        end
    }
}

require('legendary').autocmds(autocmds)
