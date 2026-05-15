-- ============================================================================
--  Grimblast — 截图快捷键模块
-- ============================================================================

-- Alt + A -> 冻结后区域截图，适合菜单/弹窗
hl.bind("ALT + A", hl.dsp.exec_cmd("grimblast --freeze copy area"))

-- Alt + Shift + A -> 当前输出，最快，适合输入法候选栏/瞬时弹窗
hl.bind("ALT + SHIFT + A", hl.dsp.exec_cmd("grimblast copy output"))
