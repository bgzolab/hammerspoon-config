-- 加载按键替换模块
local keyreplace = require("modules.keyreplace")
keyreplace.start()

-- 单击 Shift 切换输入法
local shiftswitch = require("modules.shiftswitch")
shiftswitch.start()

-- Ctrl+Shift+M 临时互换 Command 与 Option
local modswap = require("modules.modswap")
modswap.start()
