if not require('nixCatsUtils').enableForCategory('treesitter') then
    return {}
end

return {{
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {{'nvim-treesitter/nvim-treesitter-textobjects'}},
    lazy = false,
    branch = 'main',
    event = "BufRead",
    build = require('nixCatsUtils').lazyAdd(':TSUpdate'),
    opts = {
        -- custom handling of parsers
        ensure_installed = {"astro", "bash", "c", "css", "diff", "go", "gomod", "gowork", "gosum", "graphql", "html",
                            "javascript", "jsdoc", "json", "lua", "luadoc", "luap", "markdown", "markdown_inline",
                            "python", "query", "regex", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml", "ruby"}
    },
    config = function(_, opts)
        -- install parsers from custom opts.ensure_installed
        if opts.ensure_installed and #opts.ensure_installed > 0 then
            require("nvim-treesitter").install(opts.ensure_installed)
            -- register and start parsers for filetypes
            for _, parser in ipairs(opts.ensure_installed) do
                local filetypes = parser -- In this case, parser is the filetype/language name
                vim.treesitter.language.register(parser, filetypes)

                vim.api.nvim_create_autocmd({"FileType"}, {
                    pattern = filetypes,
                    callback = function(event)
                        vim.treesitter.start(event.buf, parser)
                    end
                })
            end
        end

        -- Auto-install and start parsers for any buffer
        vim.api.nvim_create_autocmd({"BufRead"}, {
            callback = function(event)
                local bufnr = event.buf
                local filetype = vim.api.nvim_get_option_value("filetype", {
                    buf = bufnr
                })

                -- Skip if no filetype
                if filetype == "" then
                    return
                end

                -- Check if this filetype is already handled by explicit opts.ensure_installed config
                for _, filetypes in pairs(opts.ensure_installed) do
                    local ft_table = type(filetypes) == "table" and filetypes or {filetypes}
                    if vim.tbl_contains(ft_table, filetype) then
                        return -- Already handled above
                    end
                end

                -- Get parser name based on filetype
                local parser_name = vim.treesitter.language.get_lang(filetype) -- might return filetype (not helpful)
                if not parser_name then
                    return
                end
                -- Try to get existing parser (helpful check if filetype was returned above)
                local parser_configs = require("nvim-treesitter.parsers")
                if not parser_configs[parser_name] then
                    return -- Parser not available, skip silently
                end

                local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

                if not parser_installed then
                    -- If not installed, install parser synchronously
                    require("nvim-treesitter").install({parser_name}):wait(30000)
                end

                -- let's check again
                parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

                if parser_installed then
                    -- Start treesitter for this buffer
                    vim.treesitter.start(bufnr, parser_name)
                end
            end
        })
    end
}, {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
        -- Disable entire built-in ftplugin mappings to avoid conflicts.
        -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
        vim.g.no_plugin_maps = true

        -- Or, disable per filetype (add as you like)
        -- vim.g.no_python_maps = true
        -- vim.g.no_ruby_maps = true
        -- vim.g.no_rust_maps = true
        -- vim.g.no_go_maps = true
    end,
    config = function()
        -- configuration
        require("nvim-treesitter-textobjects").setup {
            select = {
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V' -- linewise
                    -- ['@class.outer'] = '<c-v>', -- blockwise
                },
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true of false
                include_surrounding_whitespace = false
            }
        }

        -- keymaps
        -- You can use the capture groups defined in `textobjects.scm`
        vim.keymap.set({"x", "o"}, "am", function()
            require"nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
        end)
        vim.keymap.set({"x", "o"}, "im", function()
            require"nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
        end)
        vim.keymap.set({"x", "o"}, "ac", function()
            require"nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
        end)
        vim.keymap.set({"x", "o"}, "ic", function()
            require"nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
        end)
        -- You can also use captures from other query groups like `locals.scm`
        vim.keymap.set({"x", "o"}, "as", function()
            require"nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
        end)
    end
}}
