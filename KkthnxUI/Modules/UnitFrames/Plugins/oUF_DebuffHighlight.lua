local K = unpack(KkthnxUI)
local oUF = K.oUF

local CanDispel = {
	["DRUID"] = {
		["Magic"] = false,
		["Curse"] = true,
		["Poison"] = true,
	},
	["MONK"] = {
		["Magic"] = true,
		["Poison"] = true,
		["Disease"] = true,
	},
	["PALADIN"] = {
		["Magic"] = false,
		["Poison"] = true,
		["Disease"] = true,
	},
	["PRIEST"] = {
		["Magic"] = true,
		["Disease"] = true,
	},
	["SHAMAN"] = {
		["Magic"] = false,
		["Curse"] = true,
	},
	["MAGE"] = {
		["Curse"] = true,
	},
	["EVOKER"] = {
		["Magic"] = false,
		["Poison"] = true,
	},
}

local dispellist = CanDispel[K.Class] or {}
local origColors = {}

local function GetDebuffType(unit, filter)
	if not UnitCanAssist("player", unit) then
		return nil
	end

	local i = 1
	while true do
		local _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
		if not texture then
			break
		end

		if debufftype and not filter or (filter and dispellist[debufftype]) then
			return debufftype, texture
		end

		i = i + 1
	end
end

local function CheckSpec()
	if K.Class == "DRUID" then
		dispellist.Magic = GetSpecialization() == 4
	elseif K.Class == "MONK" then
		dispellist.Magic = GetSpecialization() == 2
	elseif K.Class == "PALADIN" then
		dispellist.Magic = GetSpecialization() == 1
	elseif K.Class == "SHAMAN" then
		dispellist.Magic = GetSpecialization() == 3
	elseif K.Class == "EVOKER" then
		dispellist.Magic = GetSpecialization() == 2
	end
end

local function Update(object, _, unit)
	if object.unit ~= unit then
		return
	end

	local debuffType, texture = GetDebuffType(unit, object.DebuffHighlightFilter)
	if debuffType then
		local color = _G.DebuffTypeColor[debuffType]
		if object.DebuffHighlightUseTexture then
			object.DebuffHighlight:SetTexture(texture)
		else
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 0.5)
		end
	else
		if object.DebuffHighlightUseTexture then
			object.DebuffHighlight:SetTexture(nil)
		else
			local color = origColors[object]
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	end
end

local function Enable(object)
	-- If we're not highlighting this unit return
	if not object.DebuffHighlight then
		return
	end

	-- If we're filtering highlights and we're not of the dispelling type, return
	if object.DebuffHighlightFilter and not CanDispel[K.Class] then
		return
	end

	-- Make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)
	object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
	CheckSpec()

	if not object.DebuffHighlightUseTexture then
		local r, g, b, a = object.DebuffHighlight:GetVertexColor()
		origColors[object] = { r = r, g = g, b = b, a = a }
	end

	return true
end

local function Disable(object)
	if object.DebuffHighlight then
		object:UnregisterEvent("UNIT_AURA", Update)
		object:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	end
end

oUF:AddElement("DebuffHighlight", Update, Enable, Disable)

for _, frame in ipairs(oUF.objects) do
	Enable(frame)
end
