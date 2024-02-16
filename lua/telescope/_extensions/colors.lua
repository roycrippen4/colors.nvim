local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  error('This plugin requires telescope.nvim')
end

local has_colors, colors = pcall(require, 'colors')
if not has_colors then
  error('This plugin requires colors.nvim')
end

local config = {
  replace_by_default = true,
  names_by_default = false,
}

---@param ext_config ColorsExtConfig
function config:__setup(ext_config)
  vim.tbl_deep_extend('force', self, ext_config or {})
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')

local function make_display(entry)
  ---@type string
  local display = entry.value[1]
  local hl_name = 'TelescopeResults' .. display:gsub('%[', ''):gsub('%]', ''):upper()
  return display, { { { 0, #display }, hl_name } }
end

---@param colors_list ColorListItem[]
local function make_highlights(colors_list)
  for _, dict in ipairs(colors_list) do
    local hl_name = 'TelescopeResults' .. dict[1]:gsub('%[', ''):gsub('%]', ''):upper()
    local fg_color = require('colors.utils').get_fg_color(dict[2])
    vim.api.nvim_set_hl(0, hl_name, { fg = fg_color, bg = dict[2] })
  end
end

---@param choice ColorListName
local function css_list_picker_callback(choice, opts)
  if not choice then
    return
  end

  local color_list = colors.get_color_table(choice)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  local picker = pickers.new(opts, {
    prompt_title = 'Select a color',
    finder = finders.new_table({
      results = color_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry[1],
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = actions_state.get_selected_entry()
        vim.api.nvim_put({ selection.value[2] }, '', false, true)
      end)

      return true
    end,
  })
  picker:find()
end

--- Shows lists with vim.ui.select() and opens the choice in the telescope picker
local css_list_picker = function(opts)
  opts = opts or {}
  local list_names = { 'base', 'chakra', 'mui', 'tailwind' }

  vim.ui.select(list_names, {
    prompt = 'Select a color list: ',
  }, function(choice)
    css_list_picker_callback(choice, opts)
  end)
end

local css_default_list = function(opts)
  local color_list = colors.get_color_table(colors.config.default_css_list)
  if not color_list then
    vim.notify('Color list could not be found.')
    return
  end

  make_highlights(color_list)

  local picker = pickers.new(opts, {
    prompt_title = 'Select a color',
    finder = finders.new_table({
      results = color_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry[1],
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = actions_state.get_selected_entry()
        vim.api.nvim_put({ selection.value[2] }, '', false, true)
      end)

      return true
    end,
  })
  picker:find()
end

return telescope.register_extension({
  setup = config.__setup,
  exports = {
    colors_select_list = css_list_picker,
    colors_default_list = css_default_list,
  },
})
