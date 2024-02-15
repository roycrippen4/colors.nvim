-- local api = vim.api
-- local add_hl = api.nvim_buf_add_highlight
-- local create_ns = api.nvim_create_namespace
-- local set_hl = api.nvim_set_hl
-- local set_lines = api.nvim_buf_set_lines
-- local set_option = api.nvim_set_option_value
-- local get_width = api.nvim_win_get_width
-- local set_cursor = api.nvim_win_set_cursor

-- local _gui_cursor = vim.go.guicursor
-- local config = require('colors').config
-- local U = require('colors.utils')
-- local UI = require('colors.ui')
-- local logger = require('colors.logger')
-- local map = vim.keymap.set

-- local function close()
--   UI.help:close()
--   UI.main:close()
-- end

-- ---@class Blender
-- local B = {}

-- function B:create_keymaps(bufnr, winnr)
--   U.disable_keymaps(config.mappings.disable)
--   local opts = { buffer = true, nowait = true, silent = true }

--   map('n', config.mappings.increment, function()
--     self:adjust(1, bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.increment_big, function()
--     self:adjust(5, bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.increment_bigger, function()
--     self:adjust(10, bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.decrement, function()
--     self:adjust(-1, bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.decrement_big, function()
--     self:adjust(-5, bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.decrement_bigger, function()
--     self:adjust(-10, bufnr, winnr)
--   end, opts)

--   map('n', 'q', function()
--     close()
--   end, opts)

--   map('n', config.mappings.export, function()
--     self:export()
--   end, opts)

--   map('n', config.mappings.save_to_register_default, function()
--     vim.fn.setreg(config.register, U.format_strings[config.default_format](self.colors.gradient[self.idx]))
--     close()
--   end, opts)

--   map('n', config.mappings.save_to_register_choose, function()
--     local callback = function(item)
--       item = item:sub(1, 3)
--       vim.fn.setreg(config.register, U.format_strings[item](self.colors.gradient[self.idx], self))
--     end

--     local format_opts = {
--       'hex: ' .. U.format_strings.hex(self.colors.gradient[self.idx]),
--       'rgb: ' .. U.format_strings.rgb(self.colors.gradient[self.idx]),
--       'hsl: ' .. U.format_strings.hsl(self.colors.gradient[self.idx]),
--     }

--     U.select(format_opts, 'Choose format', callback)
--     close()
--   end, { buffer = bufnr })

--   map('n', config.mappings.replace_default, function()
--     local test = U.format_strings[config.default_format](self.colors.gradient[self.idx])
--     logger:log(test)
--     -- U.replace_under_cursor()
--     close()
--   end, opts)

--   map('n', config.mappings.replace_choose, function()
--     local format_opts = {
--       'hex: ' .. U.format_strings.hex(self.colors.gradient[self.idx]),
--       'rgb: ' .. U.format_strings.rgb(self.colors.gradient[self.idx]),
--       'hsl: ' .. U.format_strings.hsl(self.colors.gradient[self.idx]),
--     }

--     local callback = function(item)
--       item = item:sub(1, 3)
--       U.replace_under_cursor(U.format_strings[item](self.colors.gradient[self.idx], UI))
--     end

--     U.select(format_opts, 'Choose format', callback)
--     close()
--   end, opts)

--   map('n', config.mappings.max_value, function()
--     self.idx = 256
--     self:update(bufnr, winnr)
--   end, opts)

--   map('n', config.mappings.min_value, function()
--     self.idx = 1
--     self:update(bufnr, winnr)
--   end, opts)

--   map('n', '?', function()
--     UI.help:open()
--   end, opts)
-- end

-- ---@param amount number
-- ---@param bufnr number
-- ---@param winnr number
-- function B:adjust(amount, bufnr, winnr)
--   if self.idx + amount > 256 then
--     self.idx = 256
--     return
--   end

--   if self.idx + amount < 1 then
--     self.idx = 1
--     return
--   end

--   self.idx = self.idx + amount
--   self:update(bufnr, winnr)
-- end

-- ---@param bufnr integer
-- ---@param winnr integer
-- function B:update(bufnr, winnr)
--   set_option('modifiable', true, { buf = bufnr })
--   set_hl(0, 'ColorsPreview', { bg = self.colors.gradient[self.idx] })

--   local c_strs = U.format_strings[config.default_format](self.colors.gradient[self.idx])
--   local preview = string.format(config.preview, c_strs)
--   local lines = string.rep(' ', get_width(winnr) - #preview) .. preview
--   local marker = string.rep(' ', math.floor(self.idx / 5) - 1) .. '^'

--   set_lines(bufnr, 1, -1, false, { marker })
--   set_lines(bufnr, 2, 3, false, { lines })
--   add_hl(bufnr, self.ns, 'ColorsPreview', 2, 0, #lines - #preview)
--   set_option('modifiable', false, { buf = bufnr })
-- end

-- --- Displays gradient at a certain position
-- ---@param bufnr number
-- ---@param line number
-- ---@param width number
-- function B:display_gradient(bufnr, line, width)
--   local gradient = U.get_gradient(self.colors.first_color, self.colors.second_color, width * 2)
--   local lines = string.rep(' ', width) .. ' '

--   set_option('modifiable', true, { buf = bufnr })
--   set_lines(bufnr, line, line, false, { lines })
--   set_option('modifiable', false, { buf = bufnr })

--   if gradient then
--     for i = 1, width do
--       local hl_name = 'ColorsGradient' .. i
--       set_hl(0, hl_name, { bg = gradient[i * 2] })
--       add_hl(bufnr, 0, hl_name, line, i - 1, i)

--       if i == width then
--         add_hl(bufnr, 0, hl_name, line, width, width + 1)
--       end
--     end
--   end
-- end

-- function B:export()
--   local opts = { 'picker', 'grayscale', 'lighten', 'darken' }
--   local function callback(tool)
--     local color_str = U.format_strings.hex(self.colors.gradient[self.idx])
--     require('colors.tools')[tool](color_str)
--   end

--   U.select(opts, 'Choose tool', callback)
--   close()
-- end

-- ---@param color1 string
-- ---@param color2 string
-- function B:init(color1, color2)
--   self.idx = 1
--   self.cur_pos = { 1, 0 }
--   self.ns = create_ns('ColorsGradient')
--   ---@type Colors
--   self.colors = {
--     first_color = color1,
--     second_color = color2,
--     gradient = U.get_gradient(color1, color2, 256),
--   }
-- end

-- ---@param color1 string
-- ---@param color2 string
-- function B:blend(color1, color2)
--   self:init(color1, color2)
--   UI.main:open({
--     zindex = 100,
--     width = 51,
--     relative = 'cursor',
--     col = 1,
--     row = 1,
--     height = 3,
--     border = config.border,
--     style = 'minimal',
--   })
--   self:update(UI.main.buf, UI.main.win)
--   self:create_keymaps(UI.main.buf, UI.main.win)
--   set_option('cursorline', false, { win = UI.main.win })
--   self:display_gradient(UI.main.buf, 0, 50)
--   vim.go.guicursor = 'a:ColorsCursor'
--   self:update(UI.main.buf, UI.main.win)
-- end

-- function B:create_autocmds()
--   vim.api.nvim_create_autocmd('BufEnter', {
--     group = vim.api.nvim_create_augroup('BlenderOpen', { clear = true }),
--     callback = function()
--       logger:log('BufEnter called')
--       vim.go.guicursor = _gui_cursor
--       UI.main:close()
--       UI.help:close()
--     end,
--   })

--   vim.api.nvim_create_autocmd('CursorMoved', {
--     group = vim.api.nvim_create_augroup('UpdateBlender', { clear = true }),
--     callback = function()
--       logger:log('CursorMoved called')
--       set_cursor(UI.main.win, self.cur_pos)
--     end,
--     buffer = UI.main.buf,
--   })
-- end

-- return B
