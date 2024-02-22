local api = vim.api
local add_hl = api.nvim_buf_add_highlight
local autocmd = api.nvim_create_autocmd
local set_option = api.nvim_set_option_value
local set_lines = api.nvim_buf_set_lines
local set_cursor = api.nvim_win_set_cursor
local get_width = api.nvim_win_get_width
local get_win = api.nvim_get_current_win
local get_cursor = api.nvim_win_get_cursor
local create_ns = api.nvim_create_namespace
local map = vim.keymap.set

-- local logger = require('colors.logger')
local config = require('colors').config
local _gui_cursor = vim.go.guicursor
local utils = require('colors.utils')
local ui = require('colors.ui')

---@class ColorPicker
local Picker = {}

--- Gets a partial block for a number between 0 and 1
---@param number number
---@return string
local function get_partial_block(number)
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
---@param _value number
---@param max_value number Max possible value
---@param max_width number Max possible width
---@return string Bar
local function get_bar(_value, max_value, max_width)
  local block_value = max_value / max_width
  local bar = string.rep('█', math.floor(_value / block_value))
  return bar .. get_partial_block(_value / block_value - math.floor(_value / block_value))
end

function Picker:close()
  ui.main:close()
  ui.help:close()
end

---@param bufnr integer
---@param winnr integer
function Picker:set_keymaps(bufnr, winnr)
  local opts = { buffer = true, nowait = true, silent = true }
  utils.disable_keymaps(config.mappings.disable)

  map('n', 'q', function()
    self:close()
  end, opts)

  map('n', '?', function()
    ui.help:open(true)
  end, opts)

  map('n', config.mappings.increment, function()
    self:adjust_color(1, bufnr, winnr)
  end, opts)

  map('n', config.mappings.decrement, function()
    self:adjust_color(-1, bufnr, winnr)
  end, opts)

  map('n', config.mappings.increment_big, function()
    self:adjust_color(5, bufnr, winnr)
  end, opts)

  map('n', config.mappings.decrement_big, function()
    self:adjust_color(-5, bufnr, winnr)
  end, opts)

  map('n', config.mappings.increment_bigger, function()
    self:adjust_color(10, bufnr, winnr)
  end, opts)

  map('n', config.mappings.decrement_bigger, function()
    self:adjust_color(-10, bufnr, winnr)
  end, opts)

  map('n', config.mappings.save, function()
    self:confirm()
  end, opts)

  map('n', config.mappings.choose_format_save, function()
    self:confirm_select()
  end, opts)

  map('n', config.mappings.replace, function()
    self:replace()
  end, opts)

  map('n', config.mappings.choose_format_replace, function()
    self:replace_select()
  end, opts)

  map('n', config.mappings.max_value, function()
    self:set_color(255, bufnr, winnr)
  end, opts)

  map('n', config.mappings.min_value, function()
    self:set_color(0, bufnr, winnr)
  end, opts)

  map('n', config.mappings.set_to_black, function()
    self:set_to_white_or_black(bufnr, winnr, true)
  end, opts)

  map('n', config.mappings.set_to_white, function()
    self:set_to_white_or_black(bufnr, winnr)
  end, opts)

  map('n', config.mappings.export, function()
    self:export()
  end, opts)
end

---@param bufnr integer
---@param winnr integer
---@param black? boolean
function Picker:set_to_white_or_black(bufnr, winnr, black)
  if black then
    self:set_color(0, bufnr, winnr, 1)
    self:set_color(0, bufnr, winnr, 2)
    self:set_color(0, bufnr, winnr, 3)
    return
  end

  self:set_color(255, bufnr, winnr, 1)
  self:set_color(255, bufnr, winnr, 2)
  self:set_color(255, bufnr, winnr, 3)
end

function Picker:make_hex_string()
  return '#' .. utils.hex(self.red) .. utils.hex(self.green) .. utils.hex(self.blue)
end

function Picker:get_select_opts()
  local hex_string = self:make_hex_string()
  return {
    'hex: ' .. utils.format_strings(hex_string, 'hex'),
    'rgb: ' .. utils.format_strings(hex_string, 'rgb'),
    'hsl: ' .. utils.format_strings(hex_string, 'hsl'),
  }
end

function Picker:update_highlights()
  local red_hex = utils.hex(self.red)
  local green_hex = utils.hex(self.green)
  local blue_hex = utils.hex(self.blue)

  api.nvim_set_hl(0, 'ColorsPreview', {
    bg = '#' .. red_hex .. green_hex .. blue_hex,
  })
  api.nvim_set_hl(0, 'ColorsRed', { fg = '#' .. red_hex .. '0000' })
  api.nvim_set_hl(0, 'ColorsGreen', { fg = '#00' .. green_hex .. '00' })
  api.nvim_set_hl(0, 'ColorsBlue', { fg = '#0000' .. blue_hex })
end

---@param bufnr integer
---@param winnr integer
function Picker:set_picker_lines(bufnr, winnr)
  local r_str = utils.hex(self.red)
  local g_str = utils.hex(self.green)
  local b_str = utils.hex(self.blue)
  local hex_str = ' #' .. r_str .. g_str .. b_str .. ' '
  local preview = string.rep(' ', get_width(winnr) - #hex_str) .. hex_str

  local lines = {
    ' Red:     ' .. r_str .. ' ' .. get_bar(self.red, 255, 20),
    ' Green:   ' .. g_str .. ' ' .. get_bar(self.green, 255, 20),
    ' Blue:    ' .. b_str .. ' ' .. get_bar(self.blue, 255, 20),
    '',
    preview,
  }

  set_option('modifiable', true, { buf = bufnr })
  set_lines(bufnr, 0, -1, false, lines)
  set_option('modifiable', false, { buf = bufnr })
  add_hl(bufnr, self.ns_r, 'ColorsRed', 0, 12, -1)
  add_hl(bufnr, self.ns_g, 'ColorsGreen', 1, 12, -1)
  add_hl(bufnr, self.ns_b, 'ColorsBlue', 2, 12, -1)
  add_hl(bufnr, self.ns_main, 'ColorsPreview', 4, 0, get_width(winnr) - #hex_str)
end

---@param amount number
---@param bufnr integer
---@param winnr integer
function Picker:adjust_color(amount, bufnr, winnr)
  local row = get_cursor(winnr)[1]

  if not vim.tbl_contains({ 1, 2, 3, 6 }, row) then
    return
  end

  if row == 1 then
    self.red = utils.adjust_value(self.red, amount)
  elseif row == 2 then
    self.green = utils.adjust_value(self.green, amount)
  elseif row == 3 then
    self.blue = utils.adjust_value(self.blue, amount)
  end

  self:update(bufnr, winnr)
end

---@param bufnr integer
---@param winnr integer
function Picker:update(bufnr, winnr)
  self:update_highlights()
  self:set_picker_lines(bufnr, winnr)
end

--- Confirm color and choose format
function Picker:confirm_select()
  self:close()

  local callback = function(item)
    if not item then
      return
    end

    vim.fn.setreg(config.register, utils.format_strings(self:make_hex_string(), item:sub(1, 3)))
  end

  utils.select(self:get_select_opts(), 'Choose format', callback)
end

--- Confirm color and save with default format
function Picker:confirm()
  self:close()
  vim.fn.setreg(config.register, utils.format_strings(self:make_hex_string(), config.format))
end

--- Replace color under cursor with default format
function Picker:replace()
  self:close()
  vim.fn.setreg(config.register, utils.format_strings(self:make_hex_string(), config.format))
  local replacement = utils.format_strings(self:make_hex_string(), config.format)
  utils.replace_under_cursor(replacement, get_win(), config.always_insert)
end

--- Replace color under cursor with choosen format
function Picker:replace_select()
  self:close()

  local callback = function(item)
    if not item then
      return
    end

    utils.replace_under_cursor(
      utils.format_strings(self:make_hex_string(), item:sub(1, 3)),
      get_win(),
      config.always_insert
    )
  end

  utils.select(self:get_select_opts(), 'Choose format', callback)
end

--- Sets a color value to a certain value
---@param color_value number
---@param bufnr integer
---@param winnr integer
---@param idx? integer
function Picker:set_color(color_value, bufnr, winnr, idx)
  color_value = math.min(math.max(color_value, 0), 255)
  local row
  if idx then
    row = idx
  else
    row = get_cursor(winnr)[1]
  end

  if not vim.tbl_contains({ 1, 2, 3 }, row) then
    return
  end

  if row == 1 then
    self.red = color_value
  end

  if row == 2 then
    self.green = color_value
  end

  if row == 3 then
    self.blue = color_value
  end

  self:update(bufnr, winnr)
end

function Picker:export()
  local opts = { 'grayscale', 'lighten', 'darken', 'convert to css name' }

  local function callback(tool)
    if not tool then
      return
    end

    if tool == 'convert to css name' then
      return
    end

    local hex_color = '#' .. utils.hex(self.red) .. utils.hex(self.green) .. utils.hex(self.blue)
    require('colors.tools')[tool](hex_color)
  end

  utils.select(opts, 'Choose tool', callback)
  self:close()
end

function Picker:init(hex_string)
  self.ns_main = create_ns('ColorsPicker')
  self.ns_r = create_ns('ColorsPickerRed')
  self.ns_g = create_ns('ColorsPickerGreen')
  self.ns_b = create_ns('ColorsPickerBlue')
  self.cur_pos = { 1, 0 }
  self.red, self.green, self.blue = utils.hex_to_rgb(hex_string)
  self.prev_win = api.nvim_get_current_win()
end

---@param hex_string string
function Picker:pick(hex_string)
  self:init(hex_string)
  ui.main:open({
    relative = 'cursor',
    zindex = 100,
    width = 34,
    col = 1,
    row = 1,
    height = 5,
    border = utils.get_border(config.border),
    style = 'minimal',
  })

  if config.always_open_help then
    ui.help:open(true)
  end

  self:update(ui.main.buf, ui.main.win)
  self:set_keymaps(ui.main.buf, ui.main.win)
  self:create_autocmds()
  set_option('cursorline', true, { win = ui.main.win })

  self:update(ui.main.buf, ui.main.win)
end

function Picker:create_autocmds()
  local PickerGroup = vim.api.nvim_create_augroup('PickerGroup', { clear = true })

  autocmd('CursorMoved', {
    group = PickerGroup,
    callback = function()
      vim.go.guicursor = 'a:ColorsCursor'
      local cursor = get_cursor(ui.main.win)
      local row = self.cur_pos[1]
      local bigger = false
      if cursor[1] > self.cur_pos[1] or cursor[2] > self.cur_pos[2] then
        bigger = true
        row = math.min((self.cur_pos[1] + 1), 3)
      elseif cursor[1] < self.cur_pos[1] or cursor[2] < self.cur_pos[2] then
        row = math.max(self.cur_pos[1] - 1, 1)
      end
      if vim.tbl_contains({ 4, 5 }, row) then
        if bigger then
          row = 6
        else
          row = 3
        end
      end
      set_cursor(ui.main.win, { row, 0 })
      api.nvim_buf_clear_namespace(ui.main.buf, self.ns_main, 0, 3)
      self.cur_pos = { row, 0 }
    end,
    buffer = ui.main.buf,
  })

  autocmd('BufEnter', {
    group = PickerGroup,
    callback = function()
      if vim.bo.ft ~= 'Colors' or vim.bo.ft ~= 'TelescopePrompt' then
        vim.go.guicursor = _gui_cursor
        self:close()
        self.prev_win = get_win()
      end
    end,
  })
end

return Picker
