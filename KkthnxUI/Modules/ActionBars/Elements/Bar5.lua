local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local cfg = C.Bars.Bar5
local margin = C.Bars.BarMargin

function Module:CreateBar5()
	local num = NUM_ACTIONBAR_BUTTONS
	local RegisterStateDriver = _G.RegisterStateDriver
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar" .. "5", "Bar5", { "RIGHT", _G.KKUI_ActionBar4, "LEFT", -margin, 0 })
	Module.movers[6] = frame.mover

	_G.MultiBarLeft:SetParent(frame)
	_G.MultiBarLeft:EnableMouse(false)
	_G.MultiBarLeft.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarLeftButton" .. i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C["ActionBar"].Bar5Fader
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end
