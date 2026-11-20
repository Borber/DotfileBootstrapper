local mp = require("mp")
local options = require("mp.options")
local utils = require("mp.utils")

local settings = {
    font_size = 25,
    opacity = 1.0,
    display_region_ratio = 1.0,
    scroll_duration = 5,
    smooth_scroll = false,
}
options.read_options(settings, "local-danmaku")

local converted_subtitle
local scroll_filter = "@local-danmaku-fps"
local scroll_filter_enabled = false

local function set_scroll_filter(enabled)
    if enabled == scroll_filter_enabled then
        return
    end

    if enabled then
        scroll_filter_enabled = mp.commandv("vf", "add", scroll_filter .. ":lavfi=[fps=fps=source_fps*2]") == true
    elseif mp.commandv("vf", "remove", scroll_filter) then
        scroll_filter_enabled = false
    end
end

local function update_scroll_filter()
    local fps = mp.get_property_number("container-fps", 0)
    local subtitle = mp.get_property("current-tracks/sub/external-filename")
    set_scroll_filter(settings.smooth_scroll and converted_subtitle ~= nil
        and converted_subtitle == subtitle and mp.get_property_bool("sub-visibility", false)
        and fps > 0 and fps <= 30)
end

local function remove_converted_subtitle()
    if converted_subtitle then
        set_scroll_filter(false)
        os.remove(converted_subtitle)
        converted_subtitle = nil
    end
end

local function load_local_danmaku()
    if converted_subtitle then
        mp.commandv("sub-add", converted_subtitle, "select", "弹幕")
        return
    end

    local media_path = mp.get_property("path", "")
    local path = media_path
    if path:sub(1, 8) == "file:///" then
        path = path:sub(8):gsub("%%(%x%x)", function(byte)
            return string.char(tonumber(byte, 16))
        end)
    elseif not path:find("://", 1, true) and path ~= "" then
        path = utils.join_path(mp.get_property("working-directory"), path)
    end
    local info = utils.file_info(path)
    if not info or not info.is_file then
        mp.osd_message("请先打开本地视频")
        return
    end

    local directory, filename = utils.split_path(path)
    local stem = directory .. (filename:match("^(.+)%.[^.]+$") or filename)
    local ass = utils.file_info(stem .. ".ass")
    if ass and ass.is_file then
        mp.commandv("sub-add", stem .. ".ass", "select")
        return
    end

    local source, format
    for _, extension in ipairs({ "xml", "pb" }) do
        local candidate = stem .. "." .. extension
        local candidate_info = utils.file_info(candidate)
        if candidate_info and candidate_info.is_file then
            source = candidate
            format = extension == "pb" and "protobuf" or "xml"
            break
        end
    end
    if not source then
        mp.osd_message("找不到与视频同名的 .ass、.xml 或 .pb 弹幕")
        return
    end

    local width = mp.get_property_number("video-params/dw", 0)
    local height = mp.get_property_number("video-params/dh", 0)
    if width < 1 or height < 1 then
        mp.osd_message("视频画面尚未就绪")
        return
    end

    if not (settings.font_size > 0 and settings.font_size < math.huge
        and settings.opacity >= 0 and settings.opacity <= 1
        and settings.display_region_ratio > 0 and settings.display_region_ratio <= 1
        and settings.scroll_duration > 0 and settings.scroll_duration < math.huge) then
        mp.osd_message("请检查 local-danmaku.conf 中的弹幕参数")
        return
    end

    local font_size = settings.font_size * (height / 1080)
    local output = os.tmpname()
    local converter = mp.command_native({ "expand-path", "~~/bin/biliass" })
    local result = mp.command_native({
        name = "subprocess",
        playback_only = true,
        capture_stderr = true,
        args = {
            converter, source, "-f", format,
            "-s", string.format("%dx%d", width, height), "-o", output,
            "--fontsize", tostring(font_size),
            "--alpha", tostring(settings.opacity),
            "--display-region-ratio", tostring(settings.display_region_ratio),
            "--duration-marquee", tostring(settings.scroll_duration),
        },
    })

    if not result or result.status ~= 0 then
        os.remove(output)
        mp.msg.error(result and (result.stderr or result.error_string) or "biliass failed to run")
        mp.osd_message("弹幕转换失败，详情见 mpv 日志")
        return
    end

    if mp.get_property("path") ~= media_path or not mp.commandv("sub-add", output, "select", "弹幕") then
        os.remove(output)
        return
    end
    converted_subtitle = output
    update_scroll_filter()
end

mp.add_key_binding("Ctrl+Alt+d", "load-local-danmaku", load_local_danmaku)
mp.observe_property("current-tracks/sub/external-filename", "string", update_scroll_filter)
mp.observe_property("sub-visibility", "bool", update_scroll_filter)
mp.observe_property("container-fps", "number", update_scroll_filter)
mp.register_event("end-file", remove_converted_subtitle)
mp.register_event("shutdown", remove_converted_subtitle)
