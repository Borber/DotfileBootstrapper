-- Keep optional full-border installs square. Without the plugin, the theme still
-- removes rounded separators from tabs, status, and indicators.
local ok, full_border = pcall(require, "full-border")
if ok then
  full_border:setup({ type = ui.Border.PLAIN })
end
