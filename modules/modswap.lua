local M = {}

-- 交换左右 Command 与 Option。hidutil 在 HID 层改键，系统快捷键和密码框同样生效
local SWAP = [==[{"UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E2},
    {"HIDKeyboardModifierMappingSrc":0x7000000E2,"HIDKeyboardModifierMappingDst":0x7000000E3},
    {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x7000000E6},
    {"HIDKeyboardModifierMappingSrc":0x7000000E6,"HIDKeyboardModifierMappingDst":0x7000000E7}]}]==]

-- shortcut: 恢复时直接清空整份 UserKeyMapping，会连带清掉别的 hidutil 映射，有多套映射时改成读改写
local RESET = '{"UserKeyMapping":[]}'

local function apply(json)
    local _, ok = hs.execute("/usr/bin/hidutil property --set '" .. json .. "'")
    return ok == true
end

function M.set(on)
    M.swapped = not not on
    if not apply(M.swapped and SWAP or RESET) then
        M.swapped = not M.swapped
        hs.alert.show("⌘ ⇄ ⌥ 切换失败")
        return
    end
    hs.alert.show(M.swapped and "⌘ ⇄ ⌥ 已互换" or "⌘ ⇄ ⌥ 已恢复")
end

function M.toggle()
    M.set(not M.swapped)
end

function M.start()
    M.stop()
    M.swapped = false
    apply(RESET) -- 重载即回到原状，避免上次退出时残留
    M.hotkey = hs.hotkey.bind({ "ctrl", "shift" }, "M", M.toggle)
end

function M.stop()
    if M.hotkey then
        M.hotkey:delete()
        M.hotkey = nil
    end
    if M.swapped then
        M.swapped = false
        apply(RESET)
    end
end

return M
