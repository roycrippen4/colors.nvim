<div align="center">

# colors.nvim

</div>

## 🔥 Features 🔥

- Color picker
  - rgb
  - hex
  - hsl
- Lighten/darken colors
- Grayscale blending
- Export from any tool to any other tool
- Replace color under cursor
- Some utilities for css colors
  - List Colors
  - Select a color from the css list (in development)
  - Convert a css color into rgb, hex, or hsl (in development)

## 📦 Installation

Use you favourite package manager and call the setup function.

Packer

```lua
use {
  "roycrippen4/colors.nvim",
  cmd = "Colors",
  config = function()
    require("colors").setup()
  end,
}
```

Lazy

```lua
{
  "roycrippen4/colors.nvim",
  event = 'BufReadPost',
  opts = {}
},
```

## ⚙️ Customization

You can change the settings by passing options to the setup function.
This is the default configuration:

```lua
require("colors").setup({
    -- Register in which color codes will be copied
    register = "+",
    -- Preview for colors, if it contains `%s` this will be replaced with a hex color code of the color
    preview =  "████████ %s",
    -- The default in which colors should be saved
    -- This can be hex, hsl or rgb
    default_format = "hex",
    -- Border for the float
    border = "rounded",
    -- Some mappings which are used inside the tools
    mappings = {
        -- increment values
        increment = "l",
        -- decrement values
        decrement = "h",
        -- increment values with bigger steps
        increment_big = "L",
        -- decrement values with bigger steps
        decrement_big = "H",
        -- set values to the minimum
        min_value = "0",
        -- set values to the maximum
        max_value = "$",
        -- save the current color in the register specified above with the format specified above
        set_register_default_format = "<cr>",
        -- save the current color in the register specified above with a format you can choose
        set_register_choose_format = "g<cr>",
        -- replace the color under the cursor with the current color in the format specified above
        replace_default_format = "<m-cr>",
        -- replace the color under the cursor with the current color in a format you can choose
        replace_choose_format = "g<m-cr>",
        -- export the current color to a different tool
        export = "E",
    }
})
```

The row on which you are currently is highlighted with `ColortilsCurrentLine`.
You can modify that to change the way the tools look.

## 👀 Tools

### Supported Formats

Supported formats are the following:

- `rgb`/`rgba` (both with percentage and absolute values, e.g. `rgb(255, 255, 0)`/`rgb(100%, 100%, 0%, 0.5)`)
- `hex` (`#FFAB00`)
- `hsl`/`hsla` (`hsl(60, 100%, 50%)`, `hsla(60, 100%, 50%, 0.4)`)
- Css color names (only as argument)

### Usage

You can use the different tools with commands.
Those take the format `Colortils <tool> <color>`.
The color can be any of the supported formats.
Notice that symbols like `#`, `%` and space need to be escaped like e.g. this `\#FF00AB`.

If no valid color is provided as argument the color under the cursor (if available) will be used.
If there isn't any found the user will be asked for input (notice that you don't need to escape characters there).

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

`Colortils picker <color>`

<!-- ![picker](https://user-images.githubusercontent.com/81827001/176244717-c4a3d4c5-bb95-4abc-93e0-3733bf87ddb0.png) -->

##### Saving color

You can use `<cr>` to save the color into the register specified in the config.
The default format (specified in the config) will be used.

You can use `g<cr>` to get prompted to choose a color format in which the color then will be saved to the register.

#### Lighten color

`Colortils lighten <color>`

<!-- ![lighten](https://user-images.githubusercontent.com/81827001/176244769-0967873c-8782-4bfb-ba7e-79b2d2a60a54.png) -->

#### Darken color

`Colortils darken <color>`

<!-- ![darken](https://user-images.githubusercontent.com/81827001/176244817-fa21c4c9-9700-4889-a379-5bbddb576234.png) -->

#### Color to greyscale

`Colortils greyscale <color>`

<!-- ![greyscale](https://user-images.githubusercontent.com/81827001/176244870-697a7d17-3b06-4bd1-ba07-9a59177096c4.png) -->

#### Pick color on gradient

`Colortils gradient <color1> <color2>`

<!-- ![gradients](https://user-images.githubusercontent.com/81827001/176244977-3831bc86-f3e7-44fc-b4d9-d615d1ae9d16.png) -->

#### List css colors

`Colortils css list`

<!-- ![css_list](https://user-images.githubusercontent.com/81827001/171230907-313fddc8-29e6-4b97-a842-8ea69ed5b6d5.png) -->

# Other Plugins

Check out these other color-focused plugins for Neovim

- [vim-colortemplate](https://github.com/lifepillar/vim-colortemplate)

- [colortils.nvim](https://github.com/nvim-colortils/colortils.nvim)

- [color-picker.nvim](https://github.com/ziontee113/color-picker.nvim)

- [nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua)

## Credits

Massive credit to max and his project [colortils.nvim](https://github.com/nvim-colortils/colortils.nvim).
This plugin is an heavily modified fork of his project.
