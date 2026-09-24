-- Add/delete/replace surrounding pairs. Not using mini.surround's default
-- 's'-prefixed mappings: core/keys.lua remaps the bare 's' key to a left
-- motion whenever vim.g.keyboard_layout isn't "qwerty" (the default in
-- this config), so every 's'-prefixed mapping would race that single-key
-- motion. Prefixed with 'g' instead, which is already a clue trigger and
-- otherwise unclaimed here.
return {
    setup = function()
        require('mini.surround').setup {
            mappings = {
                add = 'gsa',
                delete = 'gsd',
                find = 'gsf',
                find_left = 'gsF',
                highlight = 'gsh',
                replace = 'gsr',
                update_n_lines = 'gsn'
            }
        }
    end
}
