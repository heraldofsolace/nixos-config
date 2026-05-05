if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {

    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            --[[ ----------------------------------------- ]]
            --[[ Uh-oh! We don't want to use mason on nix! ]]
            --[[ luckily we have our lazyAdd utility!      ]]
            --[[ We can use it to add true only if not     ]]
            --[[ loaded via nix.                           ]]
            --[[ When NOT loaded in nix                    ]]
            --[[ It returns the 1st value, otherwise,      ]]
            --[[ it returns the 2nd value.                 ]]
            --[[    (or nil if there wasnt one)            ]]
            --[[ ----------------------------------------- ]]
            {
                'williamboman/mason.nvim',
                enabled = require('nixCatsUtils').lazyAdd(true, false)
            }, {
                'williamboman/mason-lspconfig.nvim',
                enabled = require('nixCatsUtils').lazyAdd(true, false)
            }, -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', opts = {}},

            -- Additional lua configuration, makes nvim stuff amazing!
            {'folke/neodev.nvim'}, {'folke/neoconf.nvim'}, {
                'ray-x/navigator.lua',
                dependencies = {
                    {
                        'ray-x/guihua.lua',
                        build = require('nixCatsUtils').lazyAdd(
                            'cd lua/fzy && make')
                    }
                }
            }
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. They will be passed to
            --  the `settings` field of the server config. You must look up that documentation yourself.
            --
            --  If you want to override the default filetypes that your language server will attach to you can
            --  define the property 'filetypes' to the map in question.
            local servers = {
                clangd = {},
                gopls = {
                    hints = {
                        rangeVariableTypes = true,
                        parameterNames = true,
                        constantValues = true,
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        functionTypeParameters = true
                    }

                },
                pyright = {},
                rust_analyzer = {
                    inlayHints = {
                        bindingModeHints = {enable = false},
                        chainingHints = {enable = true},
                        closingBraceHints = {enable = true, minLines = 25},
                        closureReturnTypeHints = {enable = "never"},
                        lifetimeElisionHints = {
                            enable = "never",
                            useParameterNames = false
                        },
                        maxLength = 25,
                        parameterHints = {enable = true},
                        reborrowHints = {enable = "never"},
                        renderColons = true,
                        typeHints = {
                            enable = true,
                            hideClosureInitialization = false,
                            hideNamedConstructor = false
                        }
                    }
                },
                tsserver = {

                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true
                        }
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true
                        }
                    }

                },
                html = {filetypes = {'html', 'twig', 'hbs'}},
                nixd = {},
                nil_ls = {},
                lua_ls = {
                    Lua = {
                        formatters = {ignoreComments = true},
                        signatureHelp = {enabled = true},
                        diagnostics = {globals = {"nixCats"}},
                        hint = {enable = true}
                    },
                    workspace = {checkThirdParty = true},
                    telemetry = {enabled = false},
                    filetypes = {'lua'}
                }
            }

            local function get_keys(t)
                local keys = {}
                for key, _ in pairs(t) do table.insert(keys, key) end
                return keys
            end

            local server_names = get_keys(servers)

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local keymaps = {
                        {
                            'gd',
                            require('telescope.builtin').lsp_definitions,
                            description = "[G]oto [D]efinition",
                            opts = {noremap = true}
                        }, {
                            'gr',
                            require('telescope.builtin').lsp_references,
                            description = "[G]oto [R]eferences",
                            opts = {noremap = true}
                        }, {
                            'gI',
                            require('telescope.builtin').lsp_implementations,
                            description = "[G]oto [I]mplementation",
                            opts = {noremap = true}
                        }, {
                            '<leader>D',
                            require('telescope.builtin').lsp_type_definitions,
                            description = "Type [D]efinition",
                            opts = {noremap = true}
                        }, {
                            '<leader>ds',
                            require('telescope.builtin').lsp_document_symbols,
                            description = "[D]ocument [S]ymbols",
                            opts = {noremap = true}
                        }, {
                            '<leader>ws',
                            require('telescope.builtin').lsp_dynamic_workspace_symbols,
                            description = "[W]orkspace [S]ymbols",
                            opts = {noremap = true}
                        }, {
                            '<leader>rn',
                            vim.lsp.buf.rename,
                            description = "[R]e[n]ame",
                            opts = {noremap = true}
                        }, {
                            '<leader>ca',
                            vim.lsp.buf.code_action,
                            description = "[C]ode [A]ction",
                            opts = {noremap = true}
                        }, {
                            'K',
                            vim.lsp.buf.hover,
                            description = "Hover Documentation",
                            opts = {noremap = true}
                        }, {
                            'gD',
                            vim.lsp.buf.declaration,
                            description = "[G]oto [D]eclaration",
                            opts = {noremap = true}
                        }
                    }

                    require('legendary').keymaps(keymaps)

                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                        end,
                        })
                    end

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        require('legendary').keymaps({
                            {
                                '<leader>th',
                                function()
                                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                                end,
                                description = "[T]oggle Inlay [H]ints",
                                opts = {noremap = true, silent = true}
                            }
                        })
                    end
                end,
            })
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Setup neovim lua configuration
            require('neodev').setup()

            require("neoconf").setup({
                plugins = {
                    lua_ls = {enabled = true, enabled_for_neovim_config = true}
                }
            })

            require("navigator").setup({
                lsp = {disable_lsp = server_names} -- disable pylsp setup from navigator
            })

            --[[ ------------------------------------- ]]
            --[[ Handling mason is covered in the help ]]
            --[[ See :help nixCats.luaUtils.mason      ]]
            --[[ ------------------------------------- ]]
            if require('nixCatsUtils').isNixCats then
                for server, config in pairs(servers) do
                    config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
                    vim.lsp.config(server, config)
                    vim.lsp.enable(server)
                end
            else
                -- Ensure the servers above are installed
                local mason_lspconfig = require 'mason-lspconfig'

                mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers)}

                mason_lspconfig.setup_handlers {
                    function(server_name)
                        vim.lsp.config(server_name, 
                            require('blink.cmp').get_lsp_capabilities({
                                capabilities = config.capabilities,
                                settings = servers[server_name],
                                filetypes = (servers[server_name] or {}).filetypes
                            }))
                        vim.lsp.enable(server_name)
                    end
                }
            end

        end
    }, {'Bekaboo/dropbar.nvim', event = {"BufNewFile", "BufReadPost"}}, {
        "MysticalDevil/inlay-hints.nvim",
        event = "LspAttach",
        dependencies = {"neovim/nvim-lspconfig"},
        config = function()
            require("inlay-hints").setup({
                commands = {enable = true}, -- Enable InlayHints commands, include `InlayHintsToggle`, `InlayHintsEnable` and `InlayHintsDisable`
                autocmd = {enable = true} -- Enable the inlay hints on `LspAttach` event
            })
        end
    }
}

