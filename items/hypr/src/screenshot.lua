-- ============================================================================
--  Noctalia — 截图快捷键模块
-- ============================================================================

return function(noctalia)
  -- Alt + A -> 区域截图并复制到剪贴板
  hl.bind("ALT + A", hl.dsp.exec_cmd(noctalia .. " msg screenshot-region"))

  -- Alt + Shift + A -> 当前输出快速截图并复制到剪贴板
  hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd(noctalia .. " msg screenshot-fullscreen"))
end
