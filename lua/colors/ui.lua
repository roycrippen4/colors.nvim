local api = vim.api
local add_hl = api.nvim_buf_add_highlight
local autocmd = api.nvim_create_autocmd
local buf_delete = api.nvim_buf_delete
local create_buf = api.nvim_create_buf
local create_ns = api.nvim_create_namespace
local open_win = api.nvim_open_win
local set_lines = api.nvim_buf_set_lines
local set_option = api.nvim_set_option_value
local win_close = api.nvim_win_close
local c = require('colors').config
local logger = require('colors.logger')

local main = {} ---@class MainUI
local help = {} ---@class HelpUI

---@param win_config WinConfig
function main:open(win_config)
  self:close()
  self.is_open = true
  self.buf = create_buf(false, true)
  vim.bo[self.buf].ft = 'Colors'
  self.win = open_win(self.buf, true, win_config)
end

function main:close()
  if self.is_open and self.win and api.nvim_win_is_valid(self.win) then
    win_close(self.win, true)
    buf_delete(self.buf, { force = true })
    self.win = nil
    self.buf = nil
    self.is_open = false
  end
end

function help:check() end

function help:init()
  self.ns = create_ns('ColorsHelp')
  self.buf = create_buf(false, true)
  self.is_open = true
  set_option('bufhidden', 'wipe', { buf = self.buf })

  self.bar_pos = 1
  self.scrollbar_ns = create_ns('ColorsHelpScrollbar')
  self.scrollbar_buf = create_buf(false, true)
end

---@param len integer
function help:add_hl(len)
  add_hl(self.buf, self.ns, 'Special', 0, 0, -1)
  for i = 1, len, 1 do
    add_hl(self.buf, self.ns, 'String', i, 8, -1)
    add_hl(self.buf, self.ns, 'Keyword', i, 0, 8)
  end
end

----- -@param picker? boolean
function help:update_scrollbar(--[[ picker ]])
  local scrollbar_lines = {
    { '█', '', '', '', '', '', '', '' },
    { '█', '█', '', '', '', '', '', '' },
    { '', '█', '█', '', '', '', '', '' },
    { '', '', '█', '█', '', '', '', '' },
    { '', '', '', '█', '█', '', '', '' },
    { '', '', '', '', '█', '█', '', '' },
    { '', '', '', '', '', '█', '█', '' },
    { '', '', '', '', '', '', '█', '█' },
    { '', '', '', '', '', '', '', '█' },
  }
  set_lines(self.scrollbar_buf, 0, -1, false, scrollbar_lines[self.bar_pos])

  local height = vim.api.nvim_win_get_height(self.scrollbar_win)
  for i = 0, height do
    add_hl(self.scrollbar_buf, self.scrollbar_ns, 'ColorsHelpScrollbar', i, 0, -1)
  end
end

---@param picker? boolean
function help:set_lines(picker)
  local lines = {
    ' Keymaps ',
    '',
    ' ' .. c.mappings.scroll_up .. ' Scroll up',
    ' ' .. c.mappings.scroll_down .. ' Scroll down',
    ' ' .. c.mappings.increment .. '       Increment',
    ' ' .. c.mappings.decrement .. '       Decrement',
    ' ' .. c.mappings.increment_big .. '       Increment big',
    ' ' .. c.mappings.decrement_big .. '       Decrement big',
    ' ' .. c.mappings.increment_bigger .. '   Increment bigger',
    ' ' .. c.mappings.decrement_bigger .. '   Decrement bigger',
    ' ' .. c.mappings.min_value .. '       Set to minimum',
    ' ' .. c.mappings.max_value .. '       Set to maximum',
    ' ' .. c.mappings.export .. '       Export to other tool',
    ' ' .. c.mappings.save_to_register_default .. '    Save to register',
    ' ' .. c.mappings.save_to_register_choose .. '   Pick format and save to register',
    ' ' .. c.mappings.replace_default .. '  Replace color under cursor',
    ' ' .. c.mappings.replace_choose .. ' Pick format and replace color',
  }

  if picker then
    table.insert(lines, 5, ' j       Select next value')
    table.insert(lines, 6, ' k       Select previous value')
    table.insert(lines, ' ' .. c.mappings.set_picker_to_white .. '       Set to white')
    table.insert(lines, ' ' .. c.mappings.set_picker_to_black .. '       Set to black')
  end

  set_lines(self.buf, 0, -1, false, lines)
  self:update_scrollbar()
  self:add_hl(#lines)
end

---@param picker? boolean
function help:make_wins(picker)
  local col = (picker and 35) or 52
  local height = 8
  local width = 42

  -- make help window
  self.win = open_win(self.buf, false, {
    relative = 'win',
    col = col,
    row = -1,
    zindex = 100,
    width = width,
    height = height,
    border = c.border,
    style = 'minimal',
    focusable = true,
  })
  vim.wo[self.win].scrolloff = 0

  -- make scrollbar window
  self.scrollbar_win = open_win(self.scrollbar_buf, false, {
    relative = 'win',
    col = col + width + 2,
    row = 0,
    zindex = 101,
    width = 1,
    height = height,
    border = 'none',
    style = 'minimal',
    focusable = false,
  })
end

function help:close()
  if self.is_open and self.win and api.nvim_win_is_valid(self.win) then
    win_close(self.win, true)
    self.is_open = false
    self.win = nil
  end

  if self.scrollbar_win and api.nvim_win_is_valid(self.scrollbar_win) then
    win_close(self.scrollbar_win, true)
    self.scrollbar_win = nil
  end
end

function help:set_keymaps()
  vim.keymap.set('n', c.mappings.scroll_down, function()
    vim.fn.win_execute(self.win, 'normal! 2j zt')

    if self.bar_pos < 9 then
      self.bar_pos = self.bar_pos + 1
      self:update_scrollbar()
    end
  end, { buffer = true })

  vim.keymap.set('n', c.mappings.scroll_up, function()
    if self.bar_pos >= 2 then
      self.bar_pos = self.bar_pos - 1
      self:update_scrollbar()
    end
    vim.fn.win_execute(self.win, 'normal! 2k')
  end, { buffer = true })
end

---@param picker? boolean
function help:open(picker)
  if self.is_open then
    self:close()
    return
  end
  self:init()
  self:make_wins(picker)
  self:set_lines(picker)
  self:set_keymaps()

  autocmd('WinClosed', {
    group = vim.api.nvim_create_augroup('CloseUI', { clear = true }),
    pattern = tostring(self.win),
    callback = function()
      self.is_open = false
      self.buf = nil
    end,
  })
end

---@class UI
local UI = {
  main = main,
  help = help,
}

return UI
