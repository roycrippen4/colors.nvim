# 🎨 colors.nvim

**colors.nvim** is a modern color toolbox for Neovim.

> NOTE: This plugin is currently in **_heavy_**, **_active_** development.
>
> There are **NO** guarantees that it will work properly or as advertised!
>
> I am using github for personal storage at the moment!
>
> This plugin should be considered pre-alpha if anything!

## ✨ Features

- 📦 Manage all color needs with a powerful UI
- 🧑‍🔬️ Process a color with the Lighten/Darken/Grayscale tools
- 🔀 Replace the color under the cursor with any supported format
- 📋 Save your color to the clipboard to paste in later
- 🖍 Use colors from several popular UI-library palettes

## ⚡️ Requirements

- Neovim >= **0.9.0**

## 📦 Installation

Use you favourite package manager and call the setup function.

<details>
    <summary>Lazy</summary>

```lua
-- This is the configuration I am currently using
  {
    'roycrippen4/colors.nvim',
    keys = {
      {
        '<leader>cp',
        function()
          require('colors').picker()
        end,
        desc = 'Pick a color  ',
      },
      {
        '<leader>cd',
        function()
          require('colors').darken()
        end,
        desc = 'Darken a color  ',
      },
      {
        '<leader>cl',
        function()
          require('colors').lighten()
        end,
        desc = 'Lighten a color  ',
      },
    },
    opts = {},
  },
}
```

</details>

<details>
    <summary>Packer</summary>
    
```lua
use {
  "roycrippen4/colors.nvim",
  config = function()
    require("colors").setup()
  end,
}
```
</details>

## ⚙️ Default configuration

**colors.nvim** comes with the following default configuration

```lua
require('colors').setup({
  config = {
    -- Sets the default register for saving a color
    register = '+',
    -- Shows the color in the Picker/Blending tools
    preview = ' %s ',
    -- Sets the default format
    default_format = 'hex',
    -- Default border for windows
    border = 'rounded',
    -- Default color used if a color is not found under the cursor
    fallback_color = '#777777',
    -- Opens the help window when a tool is used
    open_help_by_default = true,
    -- Tries to replace color first, but will simple insert the color if one is not found
    insert_by_default = true,
    -- Mappings table
    mappings = {
      -- Disable these keymaps to prevent modification errors in buffer
      disable = d,
      -- Scrolls help window up
      scroll_up = '<C-S-P>',
      -- Scrolls help window down
      scroll_down = '<C-S-N>',
      -- Increase value
      increment = 'l',
      -- Decrease value
      decrement = 'h',
      -- Increase value more
      increment_big = 'L',
      -- Decrease value more
      decrement_big = 'H',
      -- Increase value even more
      increment_bigger = '<M-L>',
      -- Decrease value even more
      decrement_bigger = '<M-H>',
      -- Set value to miniumum
      min_value = 'm',
      -- Set value to maximum
      max_value = 'M',
      -- Save the color in default format to the default register
      save_to_register_default = '<m-cr>',
      -- Choose a format then save the color default register
      save_to_register_choose = 'g<cr>',
      -- Replace color under cursor with default format
      replace_default = '<cr>',
      -- Choose a format then replace the color under the cursor
      replace_choose = 'g<m-cr>',
      -- Sets R, G, and B values to 00 in the picker
      set_picker_to_black = 'b',
      -- Sets R, G, and B values to FF in the picker
      set_picker_to_white = 'w',
      -- Export color to another tool
      export = 'e',
    },
  },
})
```

> Note:
>
> colors.nvim only creates keybinds for use inside of the tools.
>
> You must create your own keybinds to invoke the tools!

## 👀 Tools

### Supported Formats

<details>
    <summary>RGB</summary>
    
- `rgb(255, 255, 0)`
- `rgb(100%, 100%, 0%)`

</details>

<details>
    <summary>Hex</summary>
    
- `#FFAB00`
</details>

<details>
    <summary>HSL</summary>

- `hsl(60, 100%, 50%)`
- `hsla(60, 100%, 50%)`
</details>

<details>
    <summary>CSS</summary>

##### Color support for the following:

- _Standard CSS_
- _Tailwind CSS_
- _Material UI_
- _ChakraUI_

</details>

### Usage

Invoke a tool via a keymap

#### Mappings

You can use `h`/`l` and the mappings specified in the config to increment and decrement values or pick a position on a gradient.
With `0` and `$` to go to the minimum and the maximum values instantly.

With `q` you can close the tools.

With most tools you can use `<cr>` to save the currently selected color to the register speicified in the config.
If this isn't the case or something is special it will be written below.
You can use `g<cr>` to get a prompt in which you can choose the format.

With `<m-cr>`/`g<m-cr>` you can replace the color under the cursor instead of copying into a register.

You can use `E` to export the currently selected color to a different tool and modify it there.

#### Color Picker

```lua
require('colors').picker()
```

##### Saving color

You can use `<cr>` to save the color into the register specified in the config.
The default format (specified in the config) will be used.

You can use `g<cr>` to get prompted to choose a color format in which the color then will be saved to the register.

#### Lighten color

Lighten a color

#### Darken color

Darken a color

#### Color to grayscale

Make a color more gray

#### List css colors

TODO: Document css features

# Other Plugins

Check out these other color-focused plugins for Neovim

- [vim-colortemplate](https://github.com/lifepillar/vim-colortemplate)

- [colortils.nvim](https://github.com/nvim-colortils/colortils.nvim)

- [color-picker.nvim](https://github.com/ziontee113/color-picker.nvim)

- [nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua)

## Credits

Massive credit to max and his project [colortils.nvim](https://github.com/nvim-colortils/colortils.nvim).
This plugin is a heavily modified fork of his project.
