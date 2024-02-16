local U = require('colors.utils')
local config = require('colors').config

local M = {}

-- --- Get the value for a color
-- ---@param color string Color name
-- ---@return string|nil
-- function M.get_color_value(color)
--   for _, color_table in ipairs(M.colors) do
--     if color_table[1] == color then
--       return color_table[2]
--     end
--   end
--   return nil
-- end

--- Lists colors in a floating window
function M.list_colors()
  local buf = vim.api.nvim_create_buf(false, true)
  local list = U.get_formated_colors(config.default_css_list)
  if not list then
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
  vim.keymap.set('n', 'q', '<cmd>q<CR>', { noremap = true, buffer = buf })
  local height = vim.api.nvim_win_get_height(0)

  ---@diagnostic disable-next-line: unused-local
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'win',
    win = 0,
    width = 30,
    height = math.floor(height * 0.9),
    col = 12,
    row = math.floor(height * 0.05) - 1,
    border = require('colors').config.border,
    style = 'minimal',
  })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.cmd('ColorizerAttachToBuffer')
end

return M
