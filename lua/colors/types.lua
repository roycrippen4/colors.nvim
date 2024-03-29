---@class ColorTable
---@field start_pos integer
---@field end_pos integer
---@field match string
---@field rgb_values RGB
---@field type Format
---@field prefix? Prefix

---@alias Prefix { start: integer, _end: integer, name: string } | nil

---@class UI
---@field main MainUI
---@field help HelpUI

---@class MainUI
---@field win integer|nil
---@field buf integer|nil
---@field title string

---@class HelpUI
---@field win integer|nil
---@field buf integer|nil
---@field ns integer|nil
---@field scrollbar_buf integer|nil
---@field scrollbar_win integer|nil
---@field scrollbar_ns integer|nil
---@field bar_pos integer

---@class ColorPicker
---@field adjust_color function
---@field blue number
---@field close function
---@field confirm function
---@field confirm_select function
---@field create_autocmds function
---@field cur_pos table
---@field export function
---@field get_select_opts function
---@field green number
---@field init function
---@field ns_b number
---@field ns_g number
---@field ns_main number
---@field ns_r number
---@field pick function
---@field prev_win integer
---@field red number
---@field replace function
---@field replace_select function
---@field set_color function
---@field set_keymaps function
---@field set_picker_lines function
---@field set_to_white_or_black function
---@field update function
---@field update_highlights function
---@field current string

---@class BlenderColors
---@field first_color string
---@field second_color string
---@field gradient table|nil

---@class WinConfig
---@field relative 'editor'|'cursor'
---@field zindex integer
---@field width integer
---@field col integer
---@field row integer
---@field height integer
---@field border any

---@class Blender
---@field idx integer
---@field cur_pos { [1]: integer, [2]: integer }
---@field ns integer
---@field help_ns integer
---@field win_config WinConfig

---@class ColorsMappings
-- Keymaps to disable prevent modification errors in buffer (only disables in plugin windows)
---@field disable? string|string[]
-- Scrolls help window up
---@field scroll_up? string
-- Scrolls help window down
---@field scroll_down? string
-- Increase value
---@field increment? string
-- Increase value more
---@field increment_big? string
-- Increase value even more
---@field increment_bigger? string
-- Decrease value
---@field decrement? string
-- Decrease value more
---@field decrement_big? string
-- Decrease value even more
---@field decrement_bigger? string
-- Set value to miniumum
---@field min_value? string
-- Set value to maximum
---@field max_value? string
-- Save the color with default format to the default register
---@field save? string
-- Choose a format then save the color default register
---@field choose_format_save? string
-- Replace color under cursor with default format
---@field replace? string
-- Choose a format then replace the color under the cursor
---@field choose_format_replace? string
-- Export color to another tool
---@field export? string
-- Sets R, G, and B values to 00 in the picker
---@field set_to_black? string
-- Sets R, G, and B values to FF in the picker
---@field set_to_white? string

---@class ColorsConfig
-- Sets the default register for saving a color
---@field register? string
-- Shows color's hex value in the Picker/Blending tools
---@field preview? string
-- Sets the default format for saving, replacing, and inserting
---@field format? Format
-- Always inserts a color at the cursor.
-- If replacing, but a color is not found under the cursor, insert the current color.
-- If replacing and a color is found under the cursor, replace with the current color.
---@field always_insert? boolean
---
---  `True` always saves the selected color the default register
---
---  ---
---  __Default:__ `True`
--- @field always_save? boolean
-- Always opens the help window when a tool is opened. Does not effect Telescope extension.
---@field always_open_help? boolean
--- Fallback color to use if a color under the cursor is not found.
--- Allows the ability to open a tool with that color as a starting point.
---@field fallback_color? string
--- Sets the border for the UI windows.
--- Accpets the standard border options for `vim.api.nvim_buf_open_win()` or
--- can accept a `BorderTable`.
---@field border? string|BorderTable
--- Enables debug logging
---@field debug? boolean
--- Keymaps for the tools
---@field mappings? ColorsMappings
--- Css specific options
---@field css ColorsCssConfig

-- css specific configuration
---@class ColorsCssConfig
---
-- Sets the default list of css colors to choose from
---@field default_list? 'mui'|'chakra'|'tailwind'|'base'
---
-- Determines the list order when searching for a color match.
-- Useful in cases where a color name is not unique to a specific list.
--
-- This option defaults to { 'tailwind', 'mui', 'chakra', 'base' }
-- If you use this setting you must provide each list name in the order you want.
-- The option will return to default settings if the list passed does not match the required criteria
---@field search_order? CssListOrder
--
-- True uses the css color name by default. False gets associated hex value
---@field use_names? boolean,
---
---@field telescope_config? ColorsExtConfig

--- Configuration for telescope extension
---
--- **Default configuration**
--- ```lua
--- -- other telescope config settings...
--- extensions = {
---   colors = {
---     telescope_theme = 'dropdown',
---     select_behavior = 'replace',
---     fallback_behavior = 'save',
---     always_save = true
---   }
--- }
--- ```
---
--- @class ColorsExtConfig
---  Sets the behavior of the picker when a color is selected.
---  `replace` - Replaces the color under the cursor
---  `insert` - Inserts the color at the cursor
---  `save` - Saves the color in the default register
---
---  ---
---  __Default:__ `replace`
--- @field select_behavior? 'replace'|'insert'|'save'
---
--- Defines the behavior in the event of a failure.
--- Typically used with `select_behavior` = "replace".
--- If a color is not found under the cursor,
--- then the plugin will either `save` or `insert` based on this parameter.
---
---  ---
---  __Default:__ `save`
--- @field fallback_behavior? 'insert'|'save'
---
--- Sets the theme for the telescope picker
---
---  ---
---  __Default:__ `dropdown`
--- @field telescope_theme? 'dropdown'|'cursor'|'ivy'

---@alias Format
---|'rgb'
---|'hsl'
---|'hex'
---|'css'

---@alias RGB { [1]: integer, [2]: integer, [3]: integer }
---@alias ColorListItem { [1]: string, [2]: string }
---@alias ColorListName 'base'|'chakra'|'mui'|'tailwind'

--- Table of string tuples. Each tuple must contain a single character and a highlight group.
--- There must be 8 total tuples.
---
--- ---
---
--- Example:
--- ```lua
--- local hl = 'MyBorderHighlight'
--- local border = {
---    tl = { '╭', hl },  t = { '─', hl }, tr = { '╮', hl },
---    l  = { '│', hl },                   r =  { '│', hl },
---    bl = { '╰', hl },  b = { '─', hl }, br = { '╯', hl },
--- }
--- ```
---@class BorderTable
--- The top left borderchar and highlight group
---@field tl { [1]: string, [2]: string }
--- The top borderchar and highlight group
---@field t { [1]: string, [2]: string }
--- The top right borderchar and highlight group
---@field tr { [1]: string, [2]: string }
--- The right borderchar and highlight group
---@field r { [1]: string, [2]: string }
--- The bottom borderchar and highlight group
---@field b { [1]: string, [2]: string }
--- The bottom left borderchar and highlight group
---@field bl { [1]: string, [2]: string }
--- The bottom right borderchar and highlight group
---@field br { [1]: string, [2]: string }
--- The left borderchar and highlight group
---@field l { [1]: string, [2]: string }

---@alias CssListOrder
---| {[1]: 'base',     [2]: 'chakra',   [3]: 'mui',      [4]: 'tailwind'}
---| {[1]: 'base',     [2]: 'chakra',   [3]: 'tailwind', [4]: 'mui'}
---| {[1]: 'base',     [2]: 'mui',      [3]: 'chakra',   [4]: 'tailwind'}
---| {[1]: 'base',     [2]: 'mui',      [3]: 'tailwind', [4]: 'chakra'}
---| {[1]: 'base',     [2]: 'tailwind', [3]: 'chakra',   [4]: 'mui'}
---| {[1]: 'base',     [2]: 'tailwind', [3]: 'mui',      [4]: 'chakra'}
---| {[1]: 'chakra',   [2]: 'base',     [3]: 'mui',      [4]: 'tailwind'}
---| {[1]: 'chakra',   [2]: 'base',     [3]: 'tailwind', [4]: 'mui'}
---| {[1]: 'chakra',   [2]: 'mui',      [3]: 'base',     [4]: 'tailwind'}
---| {[1]: 'chakra',   [2]: 'mui',      [3]: 'tailwind', [4]: 'base'}
---| {[1]: 'chakra',   [2]: 'tailwind', [3]: 'base',     [4]: 'mui'}
---| {[1]: 'chakra',   [2]: 'tailwind', [3]: 'mui',      [4]: 'base'}
---| {[1]: 'mui',      [2]: 'base',     [3]: 'chakra',   [4]: 'tailwind'}
---| {[1]: 'mui',      [2]: 'base',     [3]: 'tailwind', [4]: 'chakra'}
---| {[1]: 'mui',      [2]: 'chakra',   [3]: 'base',     [4]: 'tailwind'}
---| {[1]: 'mui',      [2]: 'chakra',   [3]: 'tailwind', [4]: 'base'}
---| {[1]: 'mui',      [2]: 'tailwind', [3]: 'base',     [4]: 'chakra'}
---| {[1]: 'mui',      [2]: 'tailwind', [3]: 'chakra',   [4]: 'base'}
---| {[1]: 'tailwind', [2]: 'base',     [3]: 'chakra',   [4]: 'mui'}
---| {[1]: 'tailwind', [2]: 'base',     [3]: 'mui',      [4]: 'chakra'}
---| {[1]: 'tailwind', [2]: 'chakra',   [3]: 'base',     [4]: 'mui'}
---| {[1]: 'tailwind', [2]: 'chakra',   [3]: 'mui',      [4]: 'base'}
---| {[1]: 'tailwind', [2]: 'mui',      [3]: 'base',     [4]: 'chakra'}
---| {[1]: 'tailwind', [2]: 'mui',      [3]: 'chakra',   [4]: 'base'}
