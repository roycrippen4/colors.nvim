local api = vim.api
local map = vim.keymap.set
local set_option = api.nvim_set_option_value
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local set_lines = api.nvim_buf_set_lines
local get_line = api.nvim_buf_get_lines
local get_buf = api.nvim_win_get_buf
local get_height = api.nvim_win_get_height
local get_win = api.nvim_get_current_win

local logger = require('colors.logger')
local U = require('colors.utils')
local UI = require('colors.ui')
local config = require('colors').config
local _gui_cursor = vim.go.guicursor

local CSS = {}

-- --- Get the value for a color
-- ---@param color string Color name
-- ---@return string|nil
-- function M.get_color_value(color)
--   for _, color_table in ipairs(M.colors) do
--     if color_table[1] == color then
--       return color_table[2]
--     end
--   end
--   return nil
-- end

---@param list_name string
---@return ColorListItem[]|nil
function CSS:get_css_color_table(list_name)
  local list_path = 'colors.tools.css.lists.' .. list_name

  ---@type boolean, ColorListItem[]
  local ok, color_table = pcall(require, list_path)
  if not ok then
    vim.notify('Unable to get the color table!')
    return
  end

  return color_table
end

---@return string
local function get_color_from_list()
  local win = get_win()
  local buf = get_buf(win)
  local linenr = vim.fn.line('.', win)
  assert(linenr)
  local line = get_line(buf, linenr - 1, linenr, true)[1]
  local split = vim.split(line, ' ')
  local color = split[#split]
  return color
end

--- Gets the list of colors by name
--- @param list_name? ColorListName
--- @return string[]|nil
local function get_list(list_name)
  if not list_name then
    local list = U.get_formated_colors(config.default_css_list)
    return list
  end

  local list = U.get_formated_colors(list_name)
  if not list then
    return
  end

  return list
end

function CSS:close()
  UI.main:close()
  UI.help:close()
  self.prev_win = get_win()
end

---@param bufnr integer
---@param winnr integer
function CSS:set_keymaps(bufnr, winnr)
  local opts = { buffer = true, nowait = true, silent = true }
  U.disable_keymaps(config.mappings.disable)

  map('n', 'q', function()
    self:close()
  end, opts)

  map('n', '?', function()
    UI.help:open(true)
  end, opts)

  map('n', config.mappings.save_to_register_default, function()
    self:confirm()
  end, opts)

  map('n', config.mappings.save_to_register_choose, function()
    self:confirm_select()
  end, opts)

  map('n', config.mappings.replace_default, function()
    self:replace()
  end, opts)

  map('n', config.mappings.replace_choose, function()
    self:replace_select(winnr)
  end, opts)

  map('n', config.mappings.export, function()
    self:export()
  end, opts)
end

--- Confirm color and choose format
function CSS:confirm_select()
  self:close()

  -- local callback = function(item)
  --   vim.fn.setreg(config.register, U.format_strings(self:make_hex_string(), item:sub(1, 3)))
  -- end

  -- U.select(self:get_select_opts(), 'Choose format', callback)
end

--- Confirm color and save with default format
function CSS:confirm()
  get_color_from_list()
  self:close()
  -- vim.fn.setreg(config.register, U.format_strings(self:make_hex_string(), config.default_format))
end

--- Replace color under cursor with default format
function CSS:replace()
  local hex_string = get_color_from_list()
  self:close()
  local new_color = U.format_strings(hex_string, config.default_format)
  vim.fn.setreg(config.register, new_color)
  U.replace_under_cursor(new_color, vim.api.nvim_get_current_win(), config.insert_by_default)
end

--- Replace color under cursor with choosen format
---@param winnr integer
function CSS:replace_select(winnr)
  self:close()

  -- local callback = function(item)
  --   item = item:sub(1, 3)
  --   U.replace_under_cursor(U.format_strings(self:make_hex_string(), item), winnr, config.insert_by_default)
  -- end

  -- U.select(self:get_select_opts(), 'Choose format', callback)
end

function CSS:export()
  -- local opts = { 'picker', 'grayscale', 'lighten', 'darken' }
  -- local function callback(tool)
  --   local hex_color = '#' .. U.hex(self.red) .. U.hex(self.green) .. U.hex(self.blue)
  --   require('colors.tools')[tool](hex_color)
  -- end
  -- U.select(opts, 'Choose tool', callback)
  self:close()
end

---@param list_name ColorListName
function CSS:list(list_name)
  self.prev_win = api.nvim_get_current_win()
  local list = get_list(list_name)

  if not list then
    vim.notify('colors.css.list(): Could not get that list! Sorry!')
    return
  end

  local height = math.floor(get_height(0) * 0.8)
  UI.main:open({
    relative = 'cursor',
    zindex = 100,
    width = 30,
    col = 1,
    row = 1,
    height = height,
    border = config.border,
    style = 'minimal',
  })

  if config.open_help_by_default then
    UI.help:open(false, true)
  end

  get_list(list_name)
  self:set_keymaps(UI.main.buf, UI.main.win)
  self:create_autocmds()
  set_lines(UI.main.buf, 0, -1, false, list)
  set_option('cursorline', true, { win = UI.main.win })
  set_option('modifiable', false, { buf = UI.main.buf })
  vim.cmd('ColorizerAttachToBuffer')
end

function CSS:create_autocmds()
  local CSSGroup = augroup('CSSGroup', { clear = true })

  autocmd('WinEnter', {
    group = CSSGroup,
    callback = function()
      vim.go.guicursor = 'a:ColorsCursor'
    end,
  })

  autocmd('BufEnter', {
    group = CSSGroup,
    callback = function()
      if vim.bo.ft ~= 'Colors' then
        vim.go.guicursor = _gui_cursor
        self:close()
      end
    end,
  })
end

return CSS
