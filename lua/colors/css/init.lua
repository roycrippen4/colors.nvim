local M = {}

--- Get the value for a color
---@param color string Color name
---@return string|nil
function M.get_color_value(color)
  for _, color_table in ipairs(M.colors) do
    if color_table[1] == color then
      return color_table[2]
    end
  end
  return nil
end

--- Gets the colors formatted as a table of string
---@return table "color strings"
function M.get_formated_colors()
  local lines = {}
  for _, color in ipairs(M.colors) do
    table.insert(
      lines,
      string.upper(color[1]:sub(1, 1)) .. color[1]:sub(2, -1) .. ':' .. string.rep(' ', 21 - #color[1]) .. color[2]
    )
  end
  return lines
end

--- Lists colors in a floating window
function M.list_colors()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.get_formated_colors())
  vim.keymap.set('n', 'q', '<cmd>q<CR>', { noremap = true, buffer = buf })
  ---@diagnostic disable-next-line: unused-local
  local width = vim.api.nvim_win_get_width(0)
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
  -- try to attach colorizer
  vim.cmd('ColorizerAttachToBuffer')
end

return M
