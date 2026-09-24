-- Replaces nvim-lualine/lualine.nvim. Not a pixel-for-pixel recreation of
-- the old animated/randomized-icon lualine theme (mini.statusline has no
-- equivalent component model for that) - this is a clean standard
-- statusline built from mini.statusline's own section helpers. The hunk
-- counts read vim.b.minidiff_summary_string, set automatically by
-- plugins/mini/diff.lua; the branch name comes from vim-fugitive, which
-- is still part of this config (see plugins/general.lua).
return {
    setup = function()
        local statusline = require('mini.statusline')

        local function branch()
            local ok, head = pcall(vim.fn.FugitiveHead)
            return (ok and head ~= '' and head) or ''
        end

        statusline.setup {
            use_icons = vim.g.have_nerd_font,
            content = {
                active = function()
                    local mode, mode_hl = statusline.section_mode({trunc_width = 120})
                    local diff = statusline.section_diff({trunc_width = 75})
                    local diagnostics =
                        statusline.section_diagnostics({trunc_width = 75})
                    local filename = statusline.section_filename({trunc_width = 140})
                    local location = statusline.section_location({trunc_width = 75})
                    local search = statusline.section_searchcount({trunc_width = 75})

                    return statusline.combine_groups {
                        {hl = mode_hl, strings = {mode}},
                        {hl = 'MiniStatuslineDevinfo', strings = {branch(), diff, diagnostics}},
                        '%<', {hl = 'MiniStatuslineFilename', strings = {filename}},
                        '%=',
                        {hl = 'MiniStatuslineFileinfo', strings = {search}},
                        {hl = mode_hl, strings = {location}}
                    }
                end
            }
        }
    end
}
