local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  error('This plugin requires telescope.nvim')
end

local has_colors, colors = pcall(require, 'colors')
if not has_colors then
  error('This plugin requires colors.nvim')
end

local config = colors.config
local _config = colors.config.css.telescope_config
assert(_config)

local utils = require('colors.utils')
local theme = require('telescope.themes')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')

local function make_display(entry)
  ---@type string
  local display = entry.value[1]
  local hl_name = 'TelescopeResults' .. display:gsub('%[', ''):gsub('%]', ''):upper()
  return display, { { { 0, #display + 40 }, hl_name } }
end

local entry_maker = function(entry)
  return {
    value = entry,
    display = make_display,
    ordinal = entry[1],
  }
end

local attach_mappings = function(prompt_bufnr, _)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local win = vim.api.nvim_get_current_win()

    ---@type { [1]: string, [2]: string }
    local selection = actions_state.get_selected_entry().value
    local color = (_config.use_names and selection[1]) or selection[2]

    if _config.always_save or _config.fallback_behavior == 'save' then
      vim.fn.setreg(config.register, color)
    end

    if _config.select_behavior == 'save' then
      vim.fn.setreg(config.register, color)
      return
    end

    if _config.select_behavior == 'insert' then
      vim.api.nvim_put({ color }, '', false, true)
      return
    end

    utils.replace_under_cursor(color, win, (_config.fallback_behavior == 'insert'))
  end)
  return true
end

local defaults = function(color_list)
  return {
    prompt_title = 'Select a color',
    previewer = false,
    finder = finders.new_table({
      results = color_list,
      entry_maker = entry_maker,
    }),
    sorter = conf.generic_sorter(),
    attach_mappings = attach_mappings,
  }
end

---@param colors_list ColorListItem[]
local function make_highlights(colors_list)
  for _, dict in ipairs(colors_list) do
    local hl_name = 'TelescopeResults' .. dict[1]:gsub('%[', ''):gsub('%]', ''):upper()
    local fg_color = utils.get_fg_color(dict[2])
    vim.api.nvim_set_hl(0, hl_name, { fg = fg_color, bg = dict[2] })
  end
end

---@param choice ColorListName
local function css_list_picker_callback(choice)
  if not choice then
    return
  end

  -- border-x-slate-50
  local color_list = colors.get_color_table(choice)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  pickers.new(theme['get_' .. _config.telescope_theme](), defaults(color_list)):find()
end

--- Shows lists with vim.ui.select() and opens the choice in the telescope picker
local css_list_picker = function()
  local list_names = { 'base', 'chakra', 'mui', 'tailwind' }

  vim.ui.select(list_names, {
    prompt = 'Select a color list: ',
  }, function(choice)
    css_list_picker_callback(choice)
  end)
end

local css_default_list = function()
  local color_list = colors.get_color_table(config.css.default_list)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  -- border-x-slate-50
  pickers.new(theme['get_' .. _config.telescope_theme](), defaults(color_list)):find()
end

return telescope.register_extension({
  exports = {
    select_list = css_list_picker,
    default_list = css_default_list,
  },
})
