local logger = require('colors.logger')
local Utils = require('colors.utils')
local Css = require('colors.css')

local d = { 'i', 'a', 'o', 'O', 'd', 'D', 'r', 'R', 's', 'S', 'x', 'X', 'c', 'C', 'K', '/', '?', ':', 'q:', 'q/', 'q?' }

local M = {
  ---@type ColorsConfig
  config = {
    -- Sets the default register for saving a color
    register = '+',
    -- Shows the color in the Picker/Blending tools
    preview = ' %s ',
    -- Sets the default format
    default_format = 'hex',
    -- Default border for windows
    border = 'rounded',
    -- Enables debug logging
    debug = false,
    -- Default color used if a color is not found under the cursor
    fallback_color = '#777777',
    -- Opens the help window when a tool is used
    open_help_by_default = true,
    -- Tries to replace color first, but will simple insert the color if one is not found
    insert_by_default = true,
    -- Mappings table
    mappings = {
      -- Disable these keymaps to prevent modification errors in buffer
      disable = d,
      -- Scrolls help window up
      scroll_up = '<C-S-P>',
      -- Scrolls help window down
      scroll_down = '<C-S-N>',
      -- Increase value
      increment = 'l',
      -- Decrease value
      decrement = 'h',
      -- Increase value more
      increment_big = 'L',
      -- Decrease value more
      decrement_big = 'H',
      -- Increase value even more
      increment_bigger = '<M-L>',
      -- Decrease value even more
      decrement_bigger = '<M-H>',
      -- Set value to miniumum
      min_value = 'm',
      -- Set value to maximum
      max_value = 'M',
      -- Save the color in default format to the default register
      save_to_register_default = '<m-cr>',
      -- Choose a format then save the color default register
      save_to_register_choose = 'g<cr>',
      -- Replace color under cursor with default format
      replace_default = '<cr>',
      -- Choose a format then replace the color under the cursor
      replace_choose = 'g<m-cr>',
      -- Sets R, G, and B values to 00 in the picker
      set_picker_to_black = 'b',
      -- Sets R, G, and B values to FF in the picker
      set_picker_to_white = 'w',
      -- Export color to another tool
      export = 'e',
    },
  },
}

---@param color ColorTable|nil
---@return string
local function make_hex_string(color)
  if not color then
    return M.config.fallback_color
  end

  return '#' .. Utils.hex(color.rgb_values[1]) .. Utils.hex(color.rgb_values[2]) .. Utils.hex(color.rgb_values[3])
end

M.picker = function()
  local color = Utils.get_color_under_cursor()
  local hex_string = make_hex_string(color)
  require('colors.tools').picker(hex_string)
end

M.list_css = function()
  logger:log('called css')
  Css.list_colors()
end

M.grayscale = function()
  logger:log('called grayscale')
  local hex_string = make_hex_string(Utils.get_color())
  require('colors.tools').grayscale(hex_string)
end

M.lighten = function()
  logger:log('called lighten')
  local hex_string = make_hex_string(Utils.get_color())
  require('colors.tools').lighten(hex_string)
end

M.darken = function()
  logger:log('called darken')
  local hex_string = make_hex_string(Utils.get_color())
  require('colors.tools').darken(hex_string)
end

local function set_highlight_groups()
  vim.api.nvim_set_hl(0, 'ColorsHelpScrollbar', { fg = '#626262' })
  vim.api.nvim_set_hl(0, 'ColorsCurrentLine', { italic = true, default = true })
  vim.api.nvim_set_hl(0, 'ColorsCursor', { blend = 100, nocombine = true })
end

--- Main setup function
---@param update? table
function M.setup(update)
  local new_config = vim.tbl_deep_extend('force', M.config, update or {})
  M.config = new_config
  set_highlight_groups()

  vim.cmd.ColorPicker = M.picker()

  if M.config.debug then
    vim.schedule(function()
      logger:show()
    end)
  end
end

return M
