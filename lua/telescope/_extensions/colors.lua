local has_telescope, telescope = pcall(require, 'telescope')
-- local logger = require('colors.logger')

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
local ns = vim.api.nvim_create_namespace('TelescopeColors')

local function make_display(entry)
  ---@type string
  local display = entry.value[1]
  local hl_name = 'TelescopeColorResults_' .. display:gsub('%[', '_'):gsub('%]', ''):gsub('%-', '_'):upper()
  return display, { { { 0, #display }, hl_name } }
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

local sort_normal = function(a, b)
  local pattern = '(%a+)%-?%[?(%a*)(%d*)%]?'
  local nameA, prefixA, numA = a[1]:match(pattern)
  local nameB, prefixB, numB = b[1]:match(pattern)
  numA, numB = tonumber(numA) or 0, tonumber(numB) or 0

  if nameA < nameB then
    return true
  end
  if nameA > nameB then
    return false
  end

  if prefixA == '' and prefixB == 'A' then
    return true
  end
  if prefixA == 'A' and prefixB == '' then
    return false
  end

  return numA < numB
end

---@param colors_list table
---@param choice 'mui'|'base'|'tailwind'|'chakra'
local function make_highlights(colors_list, choice)
  local color_choices = {}

  if choice ~= 'base' then
    for color, shade_table in pairs(colors_list.colors) do
      for shade, hex in pairs(shade_table) do
        local entry = ((choice == 'tailwind') and color .. '-' .. shade) or color .. '[' .. shade .. ']'
        table.insert(color_choices, { entry, hex })
        local hl_name = 'TelescopeColorResults_' .. color:gsub('%[', ''):gsub('%]', ''):upper() .. '_' .. shade
        local fg_color = utils.get_fg_color(hex)
        vim.api.nvim_set_hl(0, hl_name, { fg = fg_color, bg = hex })
      end
    end
    table.sort(color_choices, sort_normal)
  else
    for k, v in pairs(colors_list) do
      local hl_name = 'TelescopeColorResults_' .. k
      local fg_color = utils.get_fg_color(v)
      vim.api.nvim_set_hl(0, hl_name, { fg = fg_color, bg = v })
      table.insert(color_choices, { k, v })
    end

    table.sort(color_choices, function(a, b)
      return utils.hex_to_luminance(a[2]) < utils.hex_to_luminance(b[2])
    end)
    return color_choices
  end

  return color_choices
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

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  local choices = make_highlights(color_list, choice)

  pickers.new(theme['get_' .. _config.telescope_theme](), defaults(choices)):find()
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
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  local color_list = colors.get_color_table(config.css.default_list)

  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  local choices = make_highlights(color_list, config.css.default_list)

  -- border-x-slate-50
  pickers.new(theme['get_' .. _config.telescope_theme](), defaults(choices)):find()
end

return telescope.register_extension({
  exports = {
    select_list = css_list_picker,
    default_list = css_default_list,
  },
})
