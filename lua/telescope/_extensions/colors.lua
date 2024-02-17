local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  error('This plugin requires telescope.nvim')
end

local has_colors, colors = pcall(require, 'colors')
if not has_colors then
  error('This plugin requires colors.nvim')
end

--- @type ColorsExtConfig
local default_ext_config = {
  select_behavior = 'replace',
  use_names = true,
  always_save = true,
  fallback_behavior = 'save',
}

local utils = require('colors.utils')
local dropdown = require('telescope.themes').get_dropdown()
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
    local selection = actions_state.get_selected_entry()
    if default_ext_config.select_behavior == 'save' then
      -- if config.replace_by_default then
      --   utils.replace_under_cursor(selection.value[1], win, colors.config.default_insert)
      --   return
      -- end
    end
    utils.replace_under_cursor(selection.value[2], win, colors.config.default_insert)
    vim.api.nvim_put({ selection.value[2] }, '', false, true)
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

  local color_list = colors.get_color_table(choice)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  pickers.new(dropdown, defaults(color_list)):find()
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
  local color_list = colors.get_color_table(colors.config.css.default_css_list)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  pickers.new(dropdown, defaults(color_list)):find()
end

return telescope.register_extension({
  setup = function(ext_config)
    config = vim.tbl_deep_extend('force', default_ext_config, ext_config or {})
    return config
  end,
  exports = {
    select_list = css_list_picker,
    default_list = css_default_list,
  },
})
