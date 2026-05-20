-- 指定应用自动进入真全屏。
-- Zen/PiliPlus 只在普通工作区独占时全屏；Minecraft 游戏窗口始终全屏。

-- 只用明确的 class / initial_class 匹配，避免标题等弱特征误判。
local exclusive_fullscreen_classes = {
  ["com.example.piliplus"] = true,
  ["zen"] = true,
}

local always_fullscreen_classes = {
  ["minecraft"] = true,
}

-- Minecraft 的 class 可能带版本号，例如 "Minecraft 1.20.6"。
local always_fullscreen_class_prefixes = {
  "minecraft ",
  "minecraft*",
}

local function normalized(value)
  if type(value) ~= "string" then
    return nil
  end

  return value:lower()
end

local function starts_with(value, prefix)
  return value:sub(1, #prefix) == prefix
end

local function class_matches(value, exact_classes, prefixes)
  local class = normalized(value)

  if not class then
    return false
  end

  if exact_classes[class] == true then
    return true
  end

  for _, prefix in ipairs(prefixes or {}) do
    if starts_with(class, prefix) then
      return true
    end
  end

  return false
end

local function is_exclusive_fullscreen_target(window)
  return window and (
    class_matches(window.class, exclusive_fullscreen_classes)
    or class_matches(window.initial_class, exclusive_fullscreen_classes)
  )
end

local function is_always_fullscreen_target(window)
  return window and (
    class_matches(window.class, always_fullscreen_classes, always_fullscreen_class_prefixes)
    or class_matches(window.initial_class, always_fullscreen_classes, always_fullscreen_class_prefixes)
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

  -- Minecraft 游戏窗口始终全屏；其它目标窗口独占时全屏。
  for _, window in ipairs(windows) do
    if is_always_fullscreen_target(window) then
      set_fullscreen(window, true)
    elseif is_exclusive_fullscreen_target(window) then
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
