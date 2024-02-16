local api = vim.api
local add_hl = api.nvim_buf_add_highlight
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local buf_delete = api.nvim_buf_delete
local create_buf = api.nvim_create_buf
local create_ns = api.nvim_create_namespace
local open_win = api.nvim_open_win
local set_lines = api.nvim_buf_set_lines
local set_option = api.nvim_set_option_value
local map = vim.keymap.set
local win_close = api.nvim_win_close
local c = require('colors').config
-- local logger = require('colors.logger')

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
    add_hl(self.buf, self.ns, 'String', i, 19, -1)
    add_hl(self.buf, self.ns, 'Keyword', i, 0, 19)
  end
end

function help:update_scrollbar()
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
---@param css? boolean
function help:set_lines(picker, css)
  local lines = {
    ' Keymaps ',
    '',
    ' Scroll up         ' .. c.mappings.scroll_up .. ' ',
    ' Scroll down       ' .. c.mappings.scroll_down .. ' ',
    ' Increment         ' .. c.mappings.increment .. ' ',
    ' Decrement         ' .. c.mappings.decrement .. ' ',
    ' Increment big     ' .. c.mappings.increment_big .. ' ',
    ' Decrement big     ' .. c.mappings.decrement_big .. ' ',
    ' Increment bigger  ' .. c.mappings.increment_bigger .. ' ',
    ' Decrement bigger  ' .. c.mappings.decrement_bigger .. ' ',
    ' Set to minimum    ' .. c.mappings.min_value .. ' ',
    ' Set to maximum    ' .. c.mappings.max_value .. ' ',
    ' Export to tool    ' .. c.mappings.export .. ' ',
    ' Save to register  ' .. c.mappings.save_to_register_default .. ' ',
    ' Pick -> save      ' .. c.mappings.save_to_register_choose .. ' ',
    ' Replace color     ' .. c.mappings.replace_default .. ' ',
    ' Pick -> replace   ' .. c.mappings.replace_choose .. ' ',
  }

  if picker then
    table.insert(lines, 5, ' Move up           k ')
    table.insert(lines, 6, ' Move down         j ')
    table.insert(lines, ' Set to white      ' .. c.mappings.set_picker_to_white)
    table.insert(lines, ' Set to black      ' .. c.mappings.set_picker_to_black)
  end

  if css then
    -- TODO: These need to be actual keybinds
    table.insert(lines, ' Set to white      ' .. c.mappings.set_picker_to_white)
    table.insert(lines, ' Set to black      ' .. c.mappings.set_picker_to_black)
  end

  set_lines(self.buf, 0, -1, false, lines)
  self:update_scrollbar()
  self:add_hl(#lines)
end

---@param picker? boolean
---@param css? boolean
function help:make_wins(picker, css)
  local col = (picker and 35) or 52
  local height = (css and 15) or 8
  local width = 27

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
  map('n', c.mappings.scroll_down, function()
    vim.fn.win_execute(self.win, 'normal! 2j zt')

    if self.bar_pos < 9 then
      self.bar_pos = self.bar_pos + 1
      self:update_scrollbar()
    end
  end, { buffer = true })

  map('n', c.mappings.scroll_up, function()
    if self.bar_pos >= 2 then
      self.bar_pos = self.bar_pos - 1
      self:update_scrollbar()
    end
    vim.fn.win_execute(self.win, 'normal! 2k')
  end, { buffer = true })
end

---@param picker? boolean
---@param css? boolean
function help:open(picker, css)
  if self.is_open then
    self:close()
    return
  end
  self:init()
  self:make_wins(picker, css)
  self:set_lines(picker, css)
  self:set_keymaps()

  autocmd('WinClosed', {
    group = augroup('CloseUI', { clear = true }),
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
