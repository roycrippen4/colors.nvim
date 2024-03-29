local api = vim.api
local get_lines = api.nvim_buf_get_lines
local get_cursor = api.nvim_win_get_cursor
local map = vim.keymap.set
local logger = require('colors.logger')

local M = {}

M.css = {
  tailwind = require('colors.tools.css.lists.tailwind'),
  mui = require('colors.tools.css.lists.mui'),
  chakra = require('colors.tools.css.lists.chakra'),
  base = require('colors.tools.css.lists.base'),
}

--[[==========================================================================]]
--[[============================= GENERAL ====================================]]
--[[==========================================================================]]

---@param border string|BorderTable
---@return string|table<string[]>
function M.get_border(border)
  if type(border) == 'string' then
    return border
  end

  return {
    border.tl,
    border.t,
    border.tr,
    border.r,
    border.br,
    border.b,
    border.bl,
    border.r,
  }
end

--- Returns true if the given string is a valid hexidecimal (#FFFFFF) number
---@param str string
---@return boolean
function M.is_hex(str)
  if string.find(str, '^#%x%x%x%x%x%x$') then
    return true
  end
  return false
end

---@param opts table
---@param prompt string
---@param callback function
function M.select(opts, prompt, callback)
  vim.ui.select(opts, { prompt = prompt }, function(choice) ---@param choice string
    callback(choice)
  end)
end

--- Get the hex code of a number
---@param int integer
---@return string
function M.hex(int)
  return tostring(bit.tohex(int, 2)):upper()
end

--- Rounds a float
---@param number float
---@return number rounded
function M.round_float(number)
  if number - math.floor(number) < 0.5 then
    return math.floor(number)
  else
    return math.ceil(number)
  end
end

--- Adjust a color value (kept inside 0-255)
---@param value number
---@param amount number
---@return number adjusted
function M.adjust_value(value, amount)
  value = value + amount
  return math.max(math.min(value, 255), 0)
end

--- Gets a partial block for a number between 0 and 1
---@param number number
---@return string
function M.get_partial_block(number)
  if number >= 0.875 then
    return '▉'
  elseif number >= 0.75 then
    return '▊'
  elseif number >= 0.625 then
    return '▋'
  elseif number >= 0.5 then
    return '▌'
  elseif number >= 0.375 then
    return '▍'
  elseif number >= 0.25 then
    return '▎'
  elseif number >= 0.125 then
    return '▏'
  else
    return ''
  end
end

--- Produces a progress bar
---@param value number
---@param max_value number Max possible value
---@param max_width number Max possible width
---@return string Bar
function M.get_bar(value, max_value, max_width)
  local block_value = max_value / max_width
  local bar = string.rep('█', math.floor(value / block_value))
  return bar .. M.get_partial_block(value / block_value - math.floor(value / block_value))
end

--[[==========================================================================]]
--[[============================== COLORS ====================================]]
--[[==========================================================================]]

--- Gets the values of a hex color
---@param hex_string string "#xxxxxx"
---@return number, number, number "red,green,blue"
function M.hex_to_rgb(hex_string)
  local red = tonumber(hex_string:sub(2, 3), 16)
  local green = tonumber(hex_string:sub(4, 5), 16)
  local blue = tonumber(hex_string:sub(6, 7), 16)
  return red, green, blue
end

--- Get colors for a gradient
---@param start_color string "#xxxxxx"
---@param end_color string "#xxxxxx"
---@param length number
---@return table|nil colors
function M.get_gradient(start_color, end_color, length)
  local points = length - 2
  if points < 0 then
    points = 0
  end

  local start_red, start_green, start_blue = M.hex_to_rgb(start_color)
  if not start_red or not start_green or not start_blue then
    return
  end

  local end_red, end_green, end_blue = M.hex_to_rgb(end_color)
  if not end_red or not end_green or not end_blue then
    return
  end

  local red_step = (end_red - start_red) / (points + 1)
  local green_step = (end_green - start_green) / (points + 1)
  local blue_step = (end_blue - start_blue) / (points + 1)
  local colors = {
    '#' .. M.hex(start_red) .. M.hex(start_green) .. M.hex(start_blue),
  }
  for i = 1, points do
    colors[#colors + 1] = '#'
      .. M.hex(M.round_float(start_red + red_step * i))
      .. M.hex(M.round_float(start_green + green_step * i))
      .. M.hex(M.round_float(start_blue + blue_step * i))
  end
  colors[#colors + 1] = '#' .. M.hex(end_red) .. M.hex(end_green) .. M.hex(end_blue)

  return colors
end

--- Gets the gray color for a certain color
---@param color string "#xxxxxx"
---@return string color
function M.get_gray(color)
  local red, green, blue = M.hex_to_rgb(color)
  local amount = red * 0.2126 + green * 0.7152 + blue * 0.0722
  local single_hex = M.hex(M.round_float(amount))
  return '#' .. string.rep(single_hex, 3)
end

--- Gets complementary color
---@param color string "#xxxxxx"
---@return string color
function M.complementary(color)
  local Xred, Xgreen, Xblue = M.hex_to_rgb(color)
  local red = M.hex(255 - Xred)
  local green = M.hex(255 - Xgreen)
  local blue = M.hex(255 - Xblue)
  return '#' .. red .. green .. blue
end

-- functions from https://github.com/NTBBloodbath/color-converter.nvim
--- Converts rgb to hsl
---@param r number
---@param g number
---@param b number
---@return table
function M.rgb_to_hsl(r, g, b)
  r = r / 255
  g = g / 255
  b = b / 255

  local c_max = math.max(r, g, b)
  local c_min = math.min(r, g, b)
  local h = 0
  local s = 0
  local l = (c_min + c_max) / 2

  local chroma = c_max - c_min
  if chroma > 0 then
    s = math.min((l <= 0.5 and chroma / (2 * l) or chroma / (2 - (2 * l))), 1)

    if c_max == r then
      h = ((g - b) / chroma + (g < b and 6 or 0))
    elseif c_max == g then
      h = (b - r) / chroma + 2
    elseif c_max == b then
      h = (r - g) / chroma + 4
    end

    h = h * 60
    h = math.floor(h + 0.5)
  end

  return {
    h,
    ('%.1f'):format(s * 100),
    ('%.1f'):format(l * 100),
    a,
  }
end

--- Converts hue to rgb
---@param p number
---@param q number
---@param t number
---@return number
local function hue_to_rgb(p, q, t)
  if t < 0 then
    t = t + 1
  end
  if t > 1 then
    t = t - 1
  end
  if t < 1 / 6 then
    return p + (q - p) * 6 * t
  end
  if t < 1 / 2 then
    return q
  end
  if t < 2 / 3 then
    return p + (q - p) * (2 / 3 - t) * 6
  end

  return p
end

--- Converts hsl to rgb
---@param h number
---@param s number
---@param l number
---@return table
function M.hsl_to_rgb(h, s, l)
  h = h / 360
  s = s / 100
  l = l / 100
  local r, g, b

  -- achromatic
  if s == 0 then
    r = l
    g = l
    b = l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1 / 3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1 / 3)
  end

  return {
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5),
  }
end

---@param match string | nil
---@param format_type string
---@param offset integer
---@return Prefix|nil
local function get_prefix(match, format_type, offset)
  if format_type ~= 'tailwind' or not match then
    return
  end

  for _, pre in pairs(M.css.tailwind.prefixes) do
    local _pattern = pre:gsub('([%W])', '%%%1')
    local pattern = '%f[%w_]' .. _pattern .. '%f[%W]'
    local _, j = match:find(pattern)
    if j then
      return {
        name = pre .. '-',
        start = offset,
        _end = j + offset,
      }
    end
  end
end

---@param  line string
---@param  column integer
---@return ColorTable|nil
function M.get_color_table(line, column)
  local formats = {
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local color = match:match('(%a+)')
        local shade = match:match('(%d+)')
        local hex = M.css.mui.colors[color][tonumber(shade)]
        local r, g, b = M.hex_to_rgb(hex)
        return { r, g, b }
      end,
      pattern = '%a+%[%d%d%d?%]',
      type = 'chakra',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local color = match:match('(%a+)')
        local shade = match:match('(%d+)')
        local accent = match:match('(A[1247]00)')
        local hex
        if accent then
          hex = M.css.mui.colors[color][accent]
        else
          hex = M.css.mui.colors[color][tonumber(shade)]
        end
        local r, g, b = M.hex_to_rgb(hex)
        return { r, g, b }
      end,
      pattern = '%a+%[A?%d%d%d?%]',
      type = 'mui',
    },

    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local color = match:match('(%a+)')
        local shade = match:match('(%d+)')
        local r, g, b = M.hex_to_rgb(M.css.tailwind.colors[color][tonumber(shade)])
        return { r, g, b }
      end,
      type = 'tailwind',
      pattern = '(%f[%w-]()[^:%s][%w-]*%-[a-z%-]+%-%d+()%f[^%w-])',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local r, g, b = M.hex_to_rgb(match)
        return { r, g, b }
      end,
      type = 'hex',
      pattern = '#%x%x%x%x%x%x',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local r, g, b = match:match('rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)')

        return {
          tonumber(r),
          tonumber(g),
          tonumber(b),
        }
      end,
      type = 'rgb',
      pattern = 'rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local values = {
          match:match('rgb%(%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)'),
        }
        return {
          tonumber(values[1]) / 100 * 255,
          tonumber(values[2]) / 100 * 255,
          tonumber(values[3]) / 100 * 255,
        }
      end,
      type = 'rgb_percent',
      pattern = 'rgb%(%d+%%%s*,%s*%d+%%%s*,%s*%d+%%%s*%)',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local values = {
          match:match('hsl%((%d+%.?%d?)%s*,%s*(%d+%.?%d?)%%%s*,%s*(%d+%.?%d?)%%%s*%)'),
        }
        local rgb = M.hsl_to_rgb(values[1], values[2], values[3])
        return { rgb[1], rgb[2], rgb[3] }
      end,
      type = 'hsl',
      pattern = 'hsl%(%d+%.?%d?%s*,%s*%d+%.?%d?%%%s*,%s*%d+%.?%d?%%%s*%)',
    },
    {
      get_rgb_table = function(match)
        if vim.tbl_contains(vim.tbl_keys(M.css.base), match) then
          local r, g, b = M.hex_to_rgb(M.css.base[match])
          return { r, g, b }
        end
      end,
      type = 'base',
      pattern = '%l+',
    },
  }

  ---@type ColorTable[]
  local matches = {}

  for _, format in ipairs(formats) do
    for match in line:gmatch(format.pattern) do
      local start_pos, end_pos = line:find(match, 1, true)
      if start_pos and end_pos and column >= start_pos - 1 and column <= end_pos then
        local prefix = get_prefix(match, format.type, start_pos)
        if prefix then
          start_pos = prefix._end + 1
          match = line:sub(start_pos, end_pos)
        end
        table.insert(matches, {
          start_pos = start_pos,
          end_pos = end_pos,
          match = match,
          rgb_values = format.get_rgb_table(match),
          type = format.type,
          prefix = prefix,
        })
      end
    end
  end

  if #matches > 0 then
    return M.validate(matches[1])
  end

  return nil
end

-- #ffffff rgb(10, 20, 30) hsl(10, 20%, 30%)  -- dark:border-y-rose-500 border-y-rose-200 teal[600]
--- #340
--- #838212
--- rgb(1, 2, 3)
--- rgb(100, 200, 0)
--- rgb(30%, 90%, 30%)
--- rgb1001%, 1002%, 1003%)
-- #012345 #543210 hsl(10, 10%, 10%)
-- hsl(210, 99%, 14%)
--
-- red aliceblue
-- bg-

---@return ColorTable|nil
function M.get_color_under_cursor()
  local cursor = get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]
  local color_table = M.get_color_table(get_lines(0, row - 1, row, false)[1], col)

  if not color_table then
    return
  end

  return color_table
end

--- Tries to replace the color under the cursor.
--- If one can't be found, than it simply inserts it at the cursor position
---@param replacement string The string to insert
---@param winnr integer the current winnr
---@param default_insert boolean If a color isn't found under the cursor, insert it in place instead
function M.replace_under_cursor(replacement, winnr, default_insert)
  local cursor = get_cursor(winnr)
  local color_table = M.get_color_under_cursor()

  if not color_table then
    if default_insert then
      api.nvim_put({ replacement }, '', true, false)
      return
    end
    return
  end

  if color_table.type == 'tailwind' and not replacement:match('%-') then
    color_table.start_pos = color_table.prefix.start
  end

  assert(color_table) -- it was whining, but the nil case is delt with above
  vim.api.nvim_buf_set_text(
    0,
    cursor[1] - 1,
    color_table.start_pos - 1,
    cursor[1] - 1,
    color_table.end_pos,
    { replacement }
  )
end

---@param colors ColorTable
---@return ColorTable|nil
function M.validate(colors)
  if not colors.type or not colors.rgb_values or not colors.end_pos or not colors.start_pos or not colors.match then
    return
  end

  local r, g, b = colors.rgb_values[1], colors.rgb_values[2], colors.rgb_values[3]
  if not r or not g or not b then
    return
  end

  if M.validate_rgb(r, g, b) then
    return colors
  end

  return nil
end

---@param r integer
---@param g integer
---@param b integer
function M.validate_rgb(r, g, b)
  return r and g and b and r <= 255 and g <= 255 and b <= 255 and r >= 0 and g >= 0 and b >= 0
end

---@param hex_string string
---@param kind 'hex'|'rgb'|'hsl'|'css'
---@return string
function M.format_strings(hex_string, kind)
  local red, green, blue = M.hex_to_rgb(hex_string)

  if kind == 'hsl' then
    local h, s, l = unpack(M.rgb_to_hsl(red, green, blue))
    return 'hsl(' .. h .. ', ' .. s .. '%, ' .. l .. '%)'
  end

  if kind == 'rgb' then
    return 'rgb(' .. red .. ', ' .. green .. ', ' .. blue .. ')'
  end

  if kind == 'css' then
    return 'css'
  end

  return hex_string
end

---@param disable string|string[]
function M.disable_keymaps(disable)
  local opts = { buffer = true, nowait = true, silent = true }

  if type(disable) == 'string' then
    map('n', disable, '', opts)
    return
  end

  for _, mapping in ipairs(disable) do
    map('n', mapping, '', opts)
  end
end

--[[==========================================================================]]
--[[================================ CSS =====================================]]
--[[==========================================================================]]

--- Gets the colors formatted as a table of string
---@param list_name ColorListName
---@return string[]|nil "color strings"
function M.get_formated_colors(list_name)
  local list_str = 'colors.tools.css.lists.' .. list_name

  ---@type boolean, ColorListItem[]
  local ok, list = pcall(require, list_str)
  if not ok then
    vim.notify('Unable to find that list. Make sure you are using one of the avaliable list names')
    return
  end

  local lines = {}
  for _, color in ipairs(list) do
    table.insert(
      lines,
      string.upper(color[1]:sub(1, 1)) .. color[1]:sub(2, -1) .. ':' .. string.rep(' ', 21 - #color[1]) .. color[2]
    )
  end
  return lines
end

--- Preprocess the RGB color values according to the sRGB color space
--- as part of calculating the relative luminance of the color
---@param color number
---@return number
function M.normalize_rgb_value(color)
  color = color / 255.0
  if color <= 0.03928 then
    return color / 12.92
  end

  return ((color + 0.055) / 1.055) ^ 2.4
end

--- Converts hexidecimal string into a luminance value
---@param hex_string string
function M.hex_to_luminance(hex_string)
  local r, g, b = M.hex_to_rgb(hex_string)
  r, g, b = M.normalize_rgb_value(r), M.normalize_rgb_value(g), M.normalize_rgb_value(b)
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

--- Returns the 'white' or 'black' for a given background color.
---@param hex_string string
---@return 'white'|'black'
function M.get_fg_color(hex_string)
  local lum = M.hex_to_luminance(hex_string)

  if lum > 0.179 then
    return 'black'
  end

  return 'white'
end

--- Returns the Euclidean distance of two hex colors in sRGB space
--- @param hex1 string the first rgb value
--- @param hex2 string the second rgb value
--- @return number the distance between the numbers
function M.calc_distance(hex1, hex2)
  local r1, g1, b1 = M.hex_to_rgb(hex1)
  local r2, g2, b2 = M.hex_to_rgb(hex2)

  local rdiff = r2 - r1
  local gdiff = g2 - g1
  local bdiff = b2 - b1

  local diff_square_sum = (rdiff ^ 2) + (gdiff ^ 2) + (bdiff ^ 2)
  return math.sqrt(diff_square_sum)
end

--- Finds the closest css match given a hex string
--- @param hex string
--- @return { list_name: string, color_name: string, shade: string|integer|nil, dist: number }|nil
function M.hex_to_css(hex)
  if not M.is_hex(hex) then
    vim.notify('Error in hex_to_css! ' .. hex .. 'is not a valid hexidecimal!')
    return
  end

  local best = { list_name = '', color_name = '', shade = nil, dist = math.huge }

  for list_name, _ in pairs(M.css) do
    if list_name == 'base' then
      best = M.search_base_list(hex, best)
    else
      best = M.search_css_list(hex, best, list_name)
    end
  end

  if best and best.list_name and best.color_name and best.dist ~= math.huge then
    return best
  end
end

---@param user_hex string
---@param best { list_name: string, color_name: string, shade: string|integer|nil, dist: number }
---@param list_name string
---@return { list_name: string, color_name: string, shade: string|integer|nil, dist: number}
function M.search_css_list(user_hex, best, list_name)
  local list = M.css[list_name]
  for color_name, colors in pairs(list.colors) do
    for shade, color_hex in pairs(colors) do
      local distance = M.calc_distance(user_hex, color_hex)

      if type(shade) == 'string' and shade:sub(1, 1) ~= 'A' then
        shade = tonumber(shade, 10)
      end

      if distance < best.dist then
        best.dist = distance
        best.color_name = color_name
        best.shade = shade
        best.list_name = list_name
      end
    end
  end

  return best
end

---@param user_hex string
---@param best { list_name: string, color_name: string, shade: string|integer|nil, dist: number}
---@return { list_name: string, color_name: string, shade: string|integer|nil, dist: number }
function M.search_base_list(user_hex, best)
  for color_name, list_hex in pairs(M.css.base) do
    local distance = M.calc_distance(user_hex, list_hex)

    if distance < best.dist then
      best.dist = distance
      best.color_name = color_name
      best.list_name = 'base'
    end
  end

  return best
end

-----@param hex_string string The color to search for the closest match
-----@param list_name? string The name of the list to search for the closest match.
---         Uses default css list if undefined
-----@return string
-- function M.replace_with_css_name(hex_string, list_name) end

return M
