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
---@field set_color_value function
---@field set_keymaps function
---@field set_picker_lines function
---@field set_to_white_or_black function
---@field update function
---@field update_highlights function
---@field current string

---@class Colors
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
---@field disable? string|string[]
---@field scroll_up? string
---@field scroll_down? string
---@field increment? string
---@field increment_big? string
---@field increment_bigger? string
---@field decrement? string
---@field decrement_big? string
---@field decrement_bigger? string
---@field min_value? string
---@field max_value? string
---@field save_to_register_default? string
---@field save_to_register_choose? string
---@field replace_default? string
---@field replace_choose? string
---@field export? string
---@field set_picker_to_black? string
---@field set_picker_to_white? string

---@class ColorsConfig
---@field register? string
---@field preview? string
---@field default_format? Format
---@field insert_by_default? boolean
---@field open_help_by_default? boolean
---@field fallback_color? string
---@field border? string
---@field debug? boolean
---@field mappings? ColorsMappings

---@class ColorTable
---@field start_pos integer
---@field end_pos integer
---@field match string
---@field rgb_values RGB
---@field type Format

---@class ColorList
---@field list ColorListItem[]

---@alias Format
---|"rgb"
---|"hsl"
---|"hex"

---@alias RGB { [1]: integer, [2]: integer, [3]: integer }
---@alias ColorListItem { [1]: string, [2]: string }
