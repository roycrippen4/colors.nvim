-- BUG: Fix replacing a color in a different format.
-- Currently getting an `invalid winnr` error.

-- TODO: Overhaul current css implementation
--   LOW PRIORITY:  Should also be able to take the current color and match it with the closest current css color name.
--   HIGH PRIORITY: Should still build a native UI for those who don't use telescope
--   HIGH PRIORITY: If replacing with css value then it should be in any format offered by other tools
--   HIGH PRIORITY: Fix the telescope user configuration. Currently it does not work and uses the default
--   HIGH PRIORITY: Ensure telescope respects the configuration settings with the selection stuff
--   DONE: Should support popular UI-library color names
--   DONE: Should support basic color names.
--   DONE: Should be able to replace any color under cursor with either css value or css name.

-- BUG: DONE: Fix the preview for the picker
-- BUG: DONE: Fix picker help win
-- BUG: DONE: Fix picker export
-- BUG: DONE: Fix bar colors
-- TODO:  DONE: Replace if color under cursor by default.
-- TODO:  DONE: Finish fixing up the help window
-- TODO:  DONE: Select a color from css table - Built the telescope extension for this.
