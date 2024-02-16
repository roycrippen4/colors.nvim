local Utils = require('colors.utils')
local Blender = require('colors.tools.blender')
local Picker = require('colors.tools.picker')
local Css = require('colors.tools.css')

local M = {}

---@param list_name ColorListName
function M.show_list(list_name)
  Css:list(list_name)
end

---@param color string
function M.lighten(color)
  Blender:blend(color, '#FFFFFF')
end

---@param color string
function M.darken(color)
  Blender:blend(color, '#000000')
end

---@param color string
function M.grayscale(color)
  local gray = Utils.get_gray(color)
  Blender:blend(color, gray)
end

---@param hex_string string
---@return string
function M.picker(hex_string)
  return Picker:pick(hex_string)
end

return M
