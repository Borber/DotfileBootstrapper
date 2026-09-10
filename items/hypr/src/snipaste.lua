-- ============================================================================
--  Snipaste — 截图快捷键模块
-- ============================================================================

-- Alt + A -> 区域截图，进入 Snipaste 截图/标注界面
hl.bind("ALT + A", hl.dsp.exec_cmd("Snipaste snip"))

-- Alt + Shift + A -> 当前输出快速截图并复制到剪贴板
hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd("Snipaste snip --active-screen -o clipboard"))
