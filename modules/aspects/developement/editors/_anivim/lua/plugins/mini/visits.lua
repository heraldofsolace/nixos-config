-- Backs the frecency/"smart open" picking done in plugins/mini/extra.lua
return {
    setup = function() require('mini.visits').setup {} end
}
