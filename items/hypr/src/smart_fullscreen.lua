-- 指定应用在普通工作区独占时自动进入真全屏。
-- 同一工作区出现其它窗口后，自动恢复为普通平铺窗口。

-- 只用明确的 class / initial_class 匹配，避免标题等弱特征误判。
local target_classes = {
  ["com.example.piliplus"] = true,
  ["zen"] = true,
}

local function normalized(value)
  if type(value) ~= "string" then
    return nil
  end

  return value:lower()
end

local function is_target(window)
  return window and (
    target_classes[normalized(window.class)] == true
    or target_classes[normalized(window.initial_class)] == true
  )
end

local function is_managed(window)
  return window and window.mapped ~= false and window.hidden ~= true
end

local function set_fullscreen(window, enabled)
  -- Hyprland fullscreen_state: 0 = none, 2 = fullscreen.
  -- 同时设置 internal 和 client，确保 layer shell 顶栏也被盖住。
  local mode = enabled and 2 or 0

  if (window.fullscreen or 0) == mode then
    return false
  end

  hl.dispatch(hl.dsp.window.fullscreen_state({
    internal = mode,
    client = mode,
    action = "set",
    window = window,
  }))
end

local function update_workspace(workspace)
  -- 只处理普通工作区，不影响 special workspace。
  if not workspace or workspace.special then
    return
  end

  local windows = {}

  for _, window in ipairs(hl.get_workspace_windows(workspace)) do
    if is_managed(window) then
      table.insert(windows, window)
    end
  end

  local only_window = #windows == 1 and windows[1] or nil

  -- 目标窗口独占时全屏；只要有额外窗口，就恢复普通显示。
  for _, window in ipairs(windows) do
    if is_target(window) then
      set_fullscreen(window, window == only_window)
    end
  end
end

local function update_smart_fullscreen()
  for _, workspace in ipairs(hl.get_workspaces()) do
    update_workspace(workspace)
  end
end

for _, event in ipairs({
  "config.reloaded",
  "workspace.active",
  "window.open",
  "window.close",
  "window.destroy",
  "window.move_to_workspace",
  "window.class",
}) do
  hl.on(event, update_smart_fullscreen)
end

update_smart_fullscreen()
