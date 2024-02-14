---@param str string
local function match_hex_six_hash(str)
  local pattern = '^#%x%x%x%x%x%x$'
  return str:match(pattern)
end

---@param str string
local function match_hex_six_no_hash(str)
  local pattern = '^%x%x%x%x%x%x$'
  return str:match(pattern)
end

---@param str string
local function match_hex_three_hash(str)
  local pattern = '^#%x%x%x$'
  return str:match(pattern)
end

---@param str string
local function match_hex_three_no_hash(str)
  local pattern = '^%x%x%x$'
  return str:match(pattern)
end

---@param str string
---@return boolean
local function match_rgb(str)
  local pattern = 'rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)'
  if str:match(pattern) then
    return true
  end
  return false
end

local rgb_strs = {
  'rgb(255, 255, 255)',
  'rgb( 128 , 64 , 32 )',
  'rgb(0,0,0)',
}

local hex_3_strs = {
  'ff2', -- 1 valid
  '#00', -- 2 invalid
  '#0x4', -- 3 invalid
  '#123', -- 4 valid
  '#12z', -- 5 invalid
}

---@param fn function
---@param data string[]
local test = function(fn, data)
  for _, str in ipairs(data) do
    print(fn(str))
  end
end

return {
  print('match_rgb'),
  test(match_rgb, rgb_strs),
  print(''),
  print('match_hex_three_hash'),
  test(match_hex_three_hash, hex_3_strs),
  print(''),
  print('match_hex_three_no_hash'),
  test(match_hex_three_no_hash, hex_3_strs),
}
