local M = {}

-- 单击（按下后很快松开）Shift 时切换的输入法
-- 查看 source id：hs.keycodes.currentSourceID() / hs.keycodes.methods(true)
local INPUT_SOURCES = {
    "com.apple.keylayout.ABC",
    "com.apple.inputmethod.SCIM.Shuangpin",
}

local TAP_SECONDS = 0.25 -- 按住超过这个时间就不算“单击”
local SHIFT_KEYCODES = { [56] = true, [60] = true } -- 左 / 右 Shift

local shiftDownAt, usedAsModifier

local function switchSource()
    local current = hs.keycodes.currentSourceID()
    local target = current == INPUT_SOURCES[1] and INPUT_SOURCES[2] or INPUT_SOURCES[1]
    if not hs.keycodes.currentSourceID(target) then
        hs.alert.show("输入法切换失败")
    end
end

local function shiftChanged(event)
    if event:getFlags().shift then
        shiftDownAt = hs.timer.secondsSinceEpoch()
        usedAsModifier = false
    elseif shiftDownAt then
        local tapped = not usedAsModifier
            and hs.timer.secondsSinceEpoch() - shiftDownAt <= TAP_SECONDS
        shiftDownAt = nil
        if tapped then switchSource() end
    end
end

local function handler(event)
    if event:getType() == hs.eventtap.event.types.flagsChanged then
        if SHIFT_KEYCODES[event:getKeyCode()] then
            shiftChanged(event)
        elseif shiftDownAt then
            usedAsModifier = true -- 同时按了其他修饰键
        end
    elseif shiftDownAt then
        usedAsModifier = true -- Shift 期间按了其他键或点了鼠标
    end
    return false -- 不拦截，Shift 本来的功能照常
end

function M.start()
    M.stop()
    M.watcher = hs.eventtap.new({
        hs.eventtap.event.types.flagsChanged,
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.leftMouseDown,
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.otherMouseDown,
    }, handler)
    M.watcher:start()
end

function M.stop()
    if M.watcher then
        M.watcher:stop()
        M.watcher = nil
    end
end

return M
