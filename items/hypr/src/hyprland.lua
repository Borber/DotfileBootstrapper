-- ============================================================================
--  Hyprland 主配置文件 (Lua)
-- ============================================================================

-- ############################################################################
-- ##  变量定义
-- ############################################################################

-- 主修饰键：SUPER 即 Windows / Command 键
local main_mod = "SUPER"

-- 常用程序：终端 / 文件管理器 / 启动器 / 记事本
local terminal = "ghostty"
local file_manager = "dolphin"
local menu = "dms ipc call spotlight toggle"
local notepad = "dms ipc call notepad toggle"


-- ############################################################################
-- ##  辅助函数
-- ############################################################################

-- 聚焦到第一个空闲的工作区
-- 遍历所有工作区，找到编号最小的未被使用的 id 并切换过去
local function focus_first_empty_workspace()
  local active_workspace = hl.get_active_workspace()
  -- 如果当前工作区已经为空，则无需切换
  if not active_workspace or active_workspace.is_empty or active_workspace.windows == 0 then
    return
  end

  -- 收集已被占用且有窗口的工作区 id
  local used = {}
  local max_used = 0

  for _, workspace in ipairs(hl.get_workspaces()) do
    local id = workspace.id
    if type(id) == "number" and id > 0 and not workspace.special and (workspace.windows or 0) > 0 then
      used[id] = true
      if id > max_used then
        max_used = id
      end
    end
  end

  -- 从 1 开始寻找第一个未被占用的工作区
  for id = 1, max_used + 1 do
    if not used[id] and id ~= active_workspace.id then
      hl.dispatch(hl.dsp.focus({ workspace = id }))
      return
    end
  end
end


-- ############################################################################
-- ##  环境变量
-- ############################################################################

-- 输入法：fcitx5
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx;ibus")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")


-- ############################################################################
-- ##  自启程序 (hyprland.start)
-- ############################################################################

hl.on("hyprland.start", function()
  -- DMS 服务（显示管理/快捷键/光标等）
  hl.exec_cmd("dms run")
  -- 显示器自动切换 (kanshi)
  hl.exec_cmd("kanshi")
  -- 输入法 (fcitx5 后台守护进程)
  hl.exec_cmd("fcitx5 -d --replace")
  -- Quickshell 概览面板
  hl.exec_cmd("qs -c overview")
end)


-- ############################################################################
-- ##  快捷键：程序启动
-- ############################################################################

-- Super + Enter        → 打开终端
hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
-- Super + Ctrl + Enter → 跳转到第一个空闲工作区
hl.bind(main_mod .. " + CTRL + RETURN", focus_first_empty_workspace)
-- Super + C            → 关闭当前窗口
hl.bind(main_mod .. " + C", hl.dsp.window.close())
-- Super + M            → 退出 Hyprland（优先使用 hyprshutdown）
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
-- Super + E            → 打开文件管理器
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
-- Super + V            → 切换窗口浮动/平铺状态
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- Super + R            → 打开启动器 / 搜索菜单
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(menu))
-- Super + N            → 打开记事本
hl.bind(main_mod .. " + N", hl.dsp.exec_cmd(notepad))


-- ############################################################################
-- ##  快捷键：任务切换 & 全局覆盖
-- ############################################################################

-- Alt + Tab → 切换概览面板
hl.bind("ALT + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))


-- ############################################################################
-- ##  快捷键：焦点移动 (Vim 风格 HJKL)
-- ############################################################################

-- Super + H → 焦点向左
hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
-- Super + J → 焦点向下
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
-- Super + K → 焦点向上
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
-- Super + L → 焦点向右
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))


-- ############################################################################
-- ##  快捷键：窗口交换 (Vim 风格 HJKL)
-- ############################################################################

-- Super + Shift + H → 当前窗口向左交换
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
-- Super + Shift + J → 当前窗口向下交换
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))
-- Super + Shift + K → 当前窗口向上交换
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
-- Super + Shift + L → 当前窗口向右交换
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))


-- ############################################################################
-- ##  快捷键：工作区切换
-- ############################################################################

-- 切换到下一个 / 上一个非空工作区
hl.bind(main_mod .. " + CTRL + L", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + CTRL + H", hl.dsp.focus({ workspace = "e-1" }))

-- 鼠标滚轮在工作区间滚动
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- 切换到指定编号工作区 (1-10) / 移动窗口到指定工作区
for i = 1, 10 do
  local key = tostring(i % 10) -- 10 → "0"

  -- Super + 数字       → 聚焦该工作区
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  -- Super + Shift + 数字 → 将当前窗口移到该工作区
  hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end


-- ############################################################################
-- ##  视觉效果：常规 / 分组 / 装饰 / 光标
-- ############################################################################

hl.config({
  -- 常规设置：间隙、边框、颜色
  general = {
    gaps_in = 3,      -- 内间隙 (px)
    gaps_out = 6,     -- 外间隙 (px)
    border_size = 2,  -- 边框宽度 (px)
    col = {
      active_border = "rgb(c6789a)",          -- 活动窗口边框色
      inactive_border = "rgba(4a4a4aaa)",     -- 非活动窗口边框色
      nogroup_border_active = "rgb(c6789a)",   -- 非分组窗口活动边框色
      nogroup_border = "rgba(4a4a4aaa)",       -- 非分组窗口边框色
    },
  },

  -- 窗口分组：分组边框和分组栏颜色
  group = {
    col = {
      border_active = "rgb(c6789a)",
      border_inactive = "rgba(4a4a4aaa)",
    },

    groupbar = {
      col = {
        active = "rgb(c6789a)",
        inactive = "rgba(4a4a4aaa)",
      },
    },
  },

  -- 装饰：阴影 / 模糊
  decoration = {
    shadow = {
      enabled = false,   -- 禁用窗口阴影
    },

    blur = {
      enabled = true,    -- 启用背景模糊
      size = 6,          -- 模糊半径
      passes = 2,        -- 模糊渲染次数
      vibrancy = 0.2,    -- 振动强度 (0~1)
    },
  },

  -- 光标：禁止鼠标自动跳转到新窗口
  cursor = {
    no_warps = true,
  },
})


-- ############################################################################
-- ##  窗口规则
-- ############################################################################

-- Ghostty 无边框模式：禁止分组，保留普通窗口边框
hl.window_rule({
  name = "ghostty-frameless",
  match = {
    class = "^com\\.mitchellh\\.ghostty$",
  },
  group = "deny",
})


-- ############################################################################
-- ##  外部模块导入
-- ############################################################################

-- DMS 生成的显示器配置（分辨率/位置/缩放等）
require("dms.outputs")
-- DMS 生成的额外快捷键
require("dms.binds")
-- Grimblast 截图快捷键
require("grimblast")
-- PiliPlus / Zen Browser 在独占工作区时自动全屏
require("smart_fullscreen")
-- DMS 生成的光标配置
require("dms.cursor")
