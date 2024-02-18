--  FIX: Telescope extension.
--      The tailwind data structure update has broken the telescope extension.
--      Need to fix it. Shouldn't be too bad.

-- TODO: LOW PRIORITY: Replace a tailwindcss color/shade with a different color/shade
--        Currently if you were to try to replace a color/shade combo with a different set it would destroy the prefix.
--        The plugin should be able to maintain the prefix and only change the color/shade
--        Example of problem: className="accent-slate-500" -> className="slate-400"
--        It would be dope as fuck to extend <C-a> and <C-x> to increment the shade. Who knows how hard that would be though.

-- TODO: Update the readme.
-- It is so inaccurate and misleading right now.
-- Needs images of the UI stuff (I'm pretty proud of it so show it off)
-- Better explanations for the features offered and how to use them.

-- TODO: Overhaul current css implementation
--   LOW PRIORITY:  Should also be able to take the current color and match it with the closest current css color name.
--   HIGH PRIORITY: Should still build a native UI for those who don't use telescope
--   DONE: HIGH PRIORITY: If replacing with css value then it should be in any format offered by other tools
--   DONE: HIGH PRIORITY: Fix the telescope user configuration. Currently it does not work and uses the default
--   DONE: HIGH PRIORITY: Ensure telescope respects the configuration settings with the selection stuff
--   DONE: Should support popular UI-library color names
--   DONE: Should support basic color names.
--   DONE: Should be able to replace any color under cursor with either css value or css name.

-- BUG: DONE: Fix the preview for the picker
-- BUG: DONE: Fix picker help win
-- BUG: DONE: Fix picker export
-- BUG: DONE: Fix bar colors
-- TODO: DONE: Replace if color under cursor by default.
-- TODO: DONE: Finish fixing up the help window
-- TODO: DONE: Select a color from css table - Built the telescope extension for this.
-- BUG: DONE: Fix replacing a color in a different format.
--       Currently getting an `invalid winnr` error.
-- TODO: DONE: Decide whether or not to use 3-digit hex
--       We will not be supporting 3-digit hex
--- TODO: DONE: Better tailwind detection.
---       We may need to abandon using tailwind colors alltogether.
---       Detection is very dificult due to the highly composable nature.
---       If I can figure out a way to differentiate between 'slate-50' and 'slate-500' we can leave the support as it stands.
