local api = vim.api
local get_lines = api.nvim_buf_get_lines
local get_buf = api.nvim_win_get_buf
local get_cursor = api.nvim_win_get_cursor
local map = vim.keymap.set
local logger = require('colors.logger')

local M = {}

--[[==========================================================================]]
--[[============================= GENERAL ====================================]]
--[[==========================================================================]]

---@param opts table
---@param prompt string
---@param callback function
function M.select(opts, prompt, callback)
  vim.ui.select(opts, { prompt = prompt }, function(choice) ---@param choice string
    callback(choice)
  end)
end

--- Get the hex code of a number
---@param number number
---@return string
function M.hex(number)
  return string.format('%02X', math.max(math.min(number, 255), 0))
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
function M.get_rgb_values(hex_string)
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

  local start_red, start_green, start_blue = M.get_rgb_values(start_color)
  if not start_red or not start_green or not start_blue then
    return
  end

  local end_red, end_green, end_blue = M.get_rgb_values(end_color)
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
  local red, green, blue = M.get_rgb_values(color)
  local amount = red * 0.2126 + green * 0.7152 + blue * 0.0722
  local single_hex = M.hex(M.round_float(amount))
  return '#' .. string.rep(single_hex, 3)
end

--- Gets complementary color
---@param color string "#xxxxxx"
---@return string color
function M.complementary(color)
  local Xred, Xgreen, Xblue = M.get_rgb_values(color)
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

---@param  line string
---@param  column integer
---@return ColorTable|nil
function M.get_color_table(line, column)
  local formats = {
    {
      get_rgb_table = function(match)
        local r = tonumber(match:sub(2, 2) .. match:sub(2, 2), 16)
        local g = tonumber(match:sub(3, 3) .. match:sub(3, 3), 16)
        local b = tonumber(match:sub(4, 4) .. match:sub(4, 4), 16)
        return { r, g, b }
      end,
      type = 'hex_3',
      pattern = '#%x%x%x',
    },
    {
      ---@param match string
      ---@return RGB
      get_rgb_table = function(match)
        local red = tonumber(match:sub(2, 3), 16)
        local green = tonumber(match:sub(4, 5), 16)
        local blue = tonumber(match:sub(6, 7), 16)
        return { red, green, blue }
      end,
      type = 'hex_6',
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
  }

  ---@type ColorTable[]
  local matches = {}
  for _, format in ipairs(formats) do
    for match in line:gmatch(format.pattern) do
      local start_pos, end_pos = line:find(match, 1, true)
      if start_pos and end_pos and column >= start_pos - 1 and column <= end_pos then
        table.insert(matches, {
          start_pos = start_pos,
          end_pos = end_pos,
          match = match,
          rgb_values = format.get_rgb_table(match),
          type = format.type,
        })
      end
    end
  end

  if #matches > 0 then
    return M.validate(matches[1])
  end

  return nil
end

-- #ffffff -- rgb(1, 2, 3) -- hsl(1, 2%, 3%)
--- #fff
--- #838212
---
--- rgb(1, 2, 3)
--- rgb(100, 200, 0)
--- rgb(30%, 30%, 30%)
--- rgb(1001%, 1002%, 1003%)
-- #012345 #543210 hsl(10, 10%, 10%)
-- hsl(210, 99%, 14%)

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
---@param replacement string
---@param winnr integer
---@param insert_by_default boolean
function M.replace_under_cursor(replacement, winnr, insert_by_default)
  local cursor = get_cursor(winnr)
  local color_table = M.get_color_under_cursor()

  if not color_table then
    if insert_by_default then
      vim.fn.feedkeys(vim.api.nvim_replace_termcodes('p', true, true, true), 'n')
      return
    end
    return
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
---@param kind 'hex'|'rgb'|'hsl'
---@return string
function M.format_strings(hex_string, kind)
  local red, green, blue = M.get_rgb_values(hex_string)

  if kind == 'hsl' then
    local h, s, l = unpack(M.rgb_to_hsl(red, green, blue))
    return 'hsl(' .. h .. ', ' .. s .. '%, ' .. l .. '%)'
  end

  if kind == 'rgb' then
    return 'rgb(' .. red .. ', ' .. green .. ', ' .. blue .. ')'
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

return M
