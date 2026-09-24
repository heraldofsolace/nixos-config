-- Replaces folke/todo-comments.nvim
return {
    setup = function()
        local hipatterns = require('mini.hipatterns')
        hipatterns.setup {
            highlighters = {
                fixme = {pattern = 'FIXME', group = 'MiniHipatternsFixme'},
                hack = {pattern = 'HACK', group = 'MiniHipatternsHack'},
                todo = {pattern = 'TODO', group = 'MiniHipatternsTodo'},
                note = {pattern = 'NOTE', group = 'MiniHipatternsNote'}
            }
        }
    end
}
