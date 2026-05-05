if not require('nixCatsUtils').enableForCategory('general') then
    return {}
end

return {
    'numToStr/Comment.nvim',
    enabled = require('nixCatsUtils').enableForCategory('general'),
    opts = {},
    name = 'comment.nvim'
}
