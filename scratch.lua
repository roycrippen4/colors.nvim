local logger = require('colors.logger')
local verbose = true
local utils = require('colors.utils')

local function verbose_log(...)
  if verbose then
    logger:log(...)
  end
end

local rgb_percent = {
  type = 'RGB PERCENT',
  pattern = 'rgb%(%d+%%%s*,%s*%d+%%%s*,%s*%d+%%%s*%)',
  items = {
    { 'rgb(100%,100%,100%)', true },
    { 'rgb(100%,00%,100)', false },
    { 'rgb(1000%,00%,100%)', false },
    { 'rgb(0%,0%,0%)', true },
    { 'rgb(0%,0,0%)', false },
  },
}

local rgb_256 = {
  type = 'RGB 256',
  pattern = 'rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)',
  items = {
    { 'rgb(255, 255, 255)', true },
    { 'rgb( 128 , 64 , 32 )', true },
    { 'rgb(0,0,0)', true },
    { 'rgb(100%,100%,100%)', false },
    { 'rgb(100%,00%,100)', false },
    { 'rgb(1000%,00%,100%)', false },
    { 'rgb(0%,0%,0%)', false },
    { 'rgb(0%,0,0%)', false },
    { 'rgb(0,0)', false },
  },
}

local hex_3 = {
  type = 'HEX 3',
  pattern = '#%x%x%x',
  items = {
    { 'ff2', false },
    { '#00', false },
    { '#0x4', false },
    { '#123', true },
    { '#12z', false },
    { '#aaa', true },
    { 'aaa', false },
  },
}

local hex_6 = {
  type = 'HEX 6',
  pattern = '#%x%x%x%x%x%x',
  items = {
    { '#525252', true },
    { '#000000', true },
    { '#FF0099', true },
    { '#77777', false },
  },
}

local hsl = {
  type = 'HSL',
  pattern = 'hsl%(%d+%.?%d?%s*,%s*%d+%.?%d?%%%s*,%s*%d+%.?%d?%%%s*%)',
  items = {
    { 'hsl(0, 100%, 50%)', true },
    { 'hsl(210, 100%, 67%)', true },
    { 'hsl(210, 76%, 0%)', true },
    { 'hsl(0, 100, 50)', false },
    { 'hsl(100, 50)', false },
  },
}

local data = {
  hex_3,
  hex_6,
  rgb_256,
  rgb_percent,
  hsl,
}

local test = function()
  for _, format in ipairs(data) do
    verbose_log('TESTING', format.type .. '...')
    local passed = true
    for i = 1, #format.items, 1 do
      local item = format.items[i]
      local str, expected = item[1], item[2]
      if str:match(format.pattern) and expected then
        verbose_log('Test passed: ' .. str, 'Expected', tostring(expected), 'recieved', 'true')
        goto continue
      end

      if expected == false then
        verbose_log('Test passed: ' .. str, 'Expected', tostring(expected), 'recieved', 'false')
        goto continue
      end
      passed = false
      verbose_log('Test failed for str: ' .. str .. '.', 'Expected ', expected, 'recieved ', not expected)
      ::continue::
    end
    if passed then
      logger:log('PASSED')
    else
      logger:log('FAILED')
    end
    logger:log()
  end
end

return {
  logger:clear(),
  test(),
}
