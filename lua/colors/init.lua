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
      -- Sets the default list of css colors to choose from. Options: 'base'|'mui'|'chakra'|'tailwind'
      default_list = 'tailwind',
      -- True uses the css color name by default. False uses associated hex value
      use_names = true,
      -- Configuration for Telescope
      telescope_config = {
        -- Sets the telescope theme. Options: 'dropdown'|'ivy'|'cursor'
        telescope_theme = 'dropdown',
        -- Sets the telescope behavior. Options: 'replace'|'insert'|'save'
        select_behavior = 'replace',
        -- Sets the fallback behavior when select_behavior is 'replace'.
        -- If a color isn't under the cursor it can either 'save' or 'insert'.
        -- The `always_insert` setting will override this setting.
        fallback_behavior = 'save',
      },
    },
    -- Sets the default register for saving a color,
    register = '+',
    -- Shows color's hex value in the Picker/Blending tools
    preview = ' %s ',
    -- Sets the default format for saving, replacing, and inserting
    format = 'hex',
    -- Default border for windows
    border = {
      tl = { '╭', 'ColorsBorder' },
      t = { '─', 'ColorsBorder' },
      tr = { '╮', 'ColorsBorder' },
      l = { '│', 'ColorsBorder' },
      r = { '│', 'ColorsBorder' },
      bl = { '╰', 'ColorsBorder' },
      b = { '─', 'ColorsBorder' },
      br = { '╯', 'ColorsBorder' },
    },
    -- Enables debug logging
    debug = false,
    -- Default color used if a color is not found under the cursor
    fallback_color = '#777777',
    -- Opens the help window when a tool is used
    always_open_help = true,
    -- Always inserts a color at the cursor.
    -- If replacing, but a color is not found under the cursor, insert the current color.
    -- If replacing and a color is found under the cursor, replace with the current color.
    always_insert = false,
    -- Mappings table
    mappings = {
      -- Disable these keymaps to prevent modification errors in buffer
      disable = d,
      -- Scrolls help window up
      scroll_up = '<C-p>',
      -- Scrolls help window down
      scroll_down = '<C-n>',
      -- Increase value
      increment = 'l',
      -- Decrease value
      decrement = 'h',
      -- Increase value more
      increment_big = 'L',
      -- Decrease value more
      decrement_big = 'H',
      -- Increase value even more
      increment_bigger = '<C-S-L>',
      -- Decrease value even more
      decrement_bigger = '<C-S-H>',
      -- Set value to miniumum
      min_value = 'm',
      -- Set value to maximum
      max_value = 'M',
      -- Save the color in default format to the default register
      save = '<m-cr>',
      -- Choose a format then save the color default register
      choose_format_save = 'g<cr>',
      -- Replace color under cursor with default format
      replace = '<cr>',
      -- Choose a format then replace the color under the cursor
      choose_format_replace = 'g<m-cr>',
      -- Sets R, G, and B values to 00 in the picker
      set_to_black = 'b',
      -- Sets R, G, and B values to FF in the picker
      set_to_white = 'w',
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
    list_name = M.config.css.default_list
    assert(list_name)
  end
  require('colors.tools').show_list(list_name)
end

---@param list_name? ColorListName
M.get_css_table = function(list_name)
  if not list_name then
    list_name = M.config.css.default_list
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
  vim.api.nvim_set_hl(0, 'ColorsBorder', { link = 'FloatBorder' })
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
