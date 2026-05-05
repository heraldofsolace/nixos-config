if not require('nixCatsUtils').enableForCategory('telescope') then
    return {}
end

return {
    {
        'nvim-telescope/telescope.nvim',

        branch = '0.1.x',
        cmd = 'Telescope',
        dependencies = {
            {'nvim-lua/plenary.nvim', lazy = true}, {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                --[[ --------------------------------- ]]
                --[[ Uh-oh! This one has a build step! ]]
                --[[ Nix has already done that for us. ]]
                --[[ Use the lazyAdd function to       ]]
                --[[ disable build steps on nix.       ]]
                --[[ --------------------------------- ]]
                build = require('nixCatsUtils').lazyAdd('make'),
                cond = require('nixCatsUtils').lazyAdd(function()
                    return vim.fn.executable 'make' == 1
                end)
            }
        },
        config = function()
            local telescope = require("telescope")

            local default = {
                defaults = {
                    vimgrep_arguments = {
                        "rg", "--color=never", "--no-heading",
                        "--with-filename", "--line-number", "--column",
                        "--smart-case"
                    },
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    entry_prefix = "  ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8
                        },
                        vertical = {mirror = false},
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120
                    },
                    file_sorter = require("telescope.sorters").get_fuzzy_file,
                    file_ignore_patterns = {"node_modules"},
                    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                    path_display = {"truncate"},
                    winblend = 0,
                    border = {},
                    borderchars = {
                        "─", "│", "─", "│", "╭", "╮", "╯", "╰"
                    },
                    color_devicons = true,
                    use_less = true,
                    set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
                    file_previewer = require("telescope.previewers").vim_buffer_cat
                        .new,
                    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep
                        .new,
                    qflist_previewer = require("telescope.previewers").vim_buffer_qflist
                        .new,
                    -- Developer configurations: Not meant for general override
                    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker
                }
            }

            telescope.setup(default)

            telescope.load_extension("lazygit")
            telescope.load_extension("frecency")
            if require('nixCatsUtils').enableForCategory('general') then
                telescope.load_extension("noice")
            end
            local keymaps = {
                {
                    '<leader>ff',
                    ':Telescope find_files<cr>',
                    description = "Telescope search files",
                    opts = {noremap = true}
                }, {
                    '<leader>fg',
                    ':Telescope live_grep<cr>',
                    description = "Telescope live grep",
                    opts = {noremap = true}
                }, {
                    '<leader>fb',
                    ':Telescope buffers<cr>',
                    description = "Telescope buffer",
                    opts = {noremap = true}
                }, {
                    '<leader>fh',
                    ':Telescope help_tags<cr>',
                    description = "Telescope help tags",
                    opts = {noremap = true}
                }, {
                    '<leader>fo',
                    ':Telescope oldfiles<cr>',
                    description = "Telescope old files",
                    opts = {noremap = true}
                }, {
                    '<leader>ft',
                    ':Telescope tags<cr>',
                    description = "Telescope tags",
                    opts = {noremap = true}
                }, {
                    '<leader>fc',
                    ':Telescope commands<cr>',
                    description = "Telescope commands",
                    opts = {noremap = true}
                }, {
                    '<leader>fr',
                    ':Telescope registers<cr>',
                    description = "Telescope registers",
                    opts = {noremap = true}
                }, {
                    '<leader>fk',
                    ':Telescope keymaps<cr>',
                    description = "Telescope keymaps",
                    opts = {noremap = true}
                }, {
                    '<leader>fgc',
                    ':Telescope git_commits<cr>',
                    description = "Telescope git commits",
                    opts = {noremap = true}
                }, {
                    '<leader>fgb',
                    ':Telescope git_bcommits<cr>',
                    description = "Telescope git bcommits",
                    opts = {noremap = true}
                }, {
                    '<leader>fcf',
                    ':Telescope current_buffer_fuzzy_find<cr>',
                    description = "Telescope current buffer fuzzy find",
                    opts = {noremap = true}
                }, {
                    '<leader>fbm',
                    ':Telescope marks<cr>',
                    description = "Telescope makrs",
                    opts = {noremap = true}
                }, {
                    '<leader>ccs',
                    ':Telescope colorscheme<cr>',
                    description = "Telescope colorscheme",
                    opts = {noremap = true}
                }, {
                    '<leader>frc',
                    ':Telescope frecency',
                    description = "Telescope frecency",
                    opts = {noremap = true}
                }
            }

            require('legendary').keymaps(keymaps)

        end
    }, {"nvim-telescope/telescope-frecency.nvim"}
}
