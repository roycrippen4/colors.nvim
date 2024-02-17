local logger = require('colors.logger')
local Utils = require('colors.utils')
logger:show()

local d = { 'i', 'a', 'o', 'O', 'd', 'D', 'r', 'R', 's', 'S', 'x', 'X', 'c', 'C', 'K', '/', '?', ':', 'q:', 'q/', 'q?' }

local M = {
  ---@type ColorsConfig
  config = {
    -- css specific configuration
    ---@type ColorsCssConfig
    css = {
      -- Sets the default list of css colors to choose from
      default_css_list = 'mui',
      -- True uses the css color name by default. False gets associated hex value
      use_color_name_by_default = false,
      -- Configuration for telescope
      telescope_config = {
        telescope_theme = 'dropdown',
        select_behavior = 'replace',
        fallback_behavior = 'save',
        use_names = true,
        always_save = true,
      },
    },
    -- Sets the default register for saving a color,
    register = '+',
    -- Shows the color in the Picker/Blending tools
    preview = ' %s ',
    -- Sets the default format
    default_format = 'hex',
    -- Default border for windows
    border = 'rounded',
    -- Enables debug logging
    debug = true,
    -- Default color used if a color is not found under the cursor
    fallback_color = '#777777',
    -- Opens the help window when a tool is used
    open_help_by_default = true,
    -- Tries to replace color first, but will simple insert the color if one is not found
    insert_by_default = false,
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

---@param list_name? ColorListName
M.list = function(list_name)
  if not list_name then
    list_name = M.config.css.default_css_list
    assert(list_name)
  end
  require('colors.tools').show_list(list_name)
end

---@param list_name? ColorListName
M.get_color_table = function(list_name)
  if not list_name then
    list_name = M.config.css.default_css_list
    assert(list_name)
  end

  return require('colors.tools').get_css_color_table(list_name)
end

M.grayscale = function()
  local color = Utils.get_color_under_cursor()
  local hex_string = make_hex_string(color)
  require('colors.tools').grayscale(hex_string)
end

M.lighten = function()
  local color = Utils.get_color_under_cursor()
  local hex_string = make_hex_string(color)
  require('colors.tools').lighten(hex_string)
end

M.darken = function()
  local color = Utils.get_color_under_cursor()
  local hex_string = make_hex_string(color)
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
end

return M
