local K, C, L = select(2, ...):unpack()

-- Lua API
local _G = _G
local type = type

-- Wow API
local CompactRaidFrameContainer = CompactRaidFrameContainer
local CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local CompactRaidFrameManager_UpdateShown = CompactRaidFrameManager_UpdateShown
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local SetCVar = SetCVar
local SetCVarBitfield = SetCVarBitfield
local StaticPopup_Show = StaticPopup_Show
local UnitAffectingCombat = UnitAffectingCombat

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: addon, InterfaceOptionsFrameCategoriesButton10, PetFrame_Update, PlayerFrame_AnimateOut
-- GLOBALS: PlayerFrame_AnimFinished, PlayerFrame_ToPlayerArt, PlayerFrame_ToVehicleArt, CompactRaidFrameManager
-- GLOBALS: UIFrameHider, CompactUnitFrameProfiles, HidePartyFrame, ShowPartyFrame, GarrisonLandingPageTutorialBox
-- GLOBALS: Advanced_UIScaleSlider, Advanced_UseUIScale, BagHelpBox, CollectionsMicroButtonAlert, EJMicroButtonAlert
-- GLOBALS: HelpOpenTicketButtonTutorial, HelpPlate, HelpPlateTooltip, PremadeGroupsPvETutorialAlert, ReagentBankHelpBox
-- GLOBALS: SpellBookFrameTutorialButton, TalentMicroButtonAlert, TutorialFrameAlertButton, WorldMapFrameTutorialButton
-- GLOBALS: LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, LE_FRAME_TUTORIAL_PET_JOURNAL, LE_FRAME_TUTORIAL_GARRISON_BUILDING
-- GLOBALS: InterfaceOptionsCombatPanelTargetOfTarget, InterfaceOptionsActionBarsPanelCountdownCooldowns, PlayerFrame
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesMakeLarger, InterfaceOptionsDisplayPanelRotateMinimap, RuneFrame
-- GLOBALS: InterfaceOptionsActionBarsPanelBottomLeft, InterfaceOptionsActionBarsPanelBottomRight, unit
-- GLOBALS: InterfaceOptionsActionBarsPanelRight, InterfaceOptionsActionBarsPanelRightTwo, InterfaceOptionsActionBarsPanelAlwaysShowActionBars
-- GLOBALS: PetFrame, TargetFrame, ComboFrame, FocusFrame, FocusFrameToT, TargetFrameToT, UIParent, PetJournalTutorialButton
-- GLOBALS: PlayerTalentFramePetSpecializationTutorialButton, PlayerTalentFrameSpecializationTutorialButton, PlayerTalentFrameTalentsTutorialButton

local function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

-- Kill all stuff on default UI that we don't need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("PLAYER_LOGIN")
DisableBlizzard:SetScript("OnEvent", function(self, event)
	if C.Unitframe.Enable then
		function PetFrame_Update() end
		function PlayerFrame_AnimateOut() end
		function PlayerFrame_AnimFinished() end
		function PlayerFrame_ToPlayerArt() end
		function PlayerFrame_ToVehicleArt() end

		for i = 1, MAX_PARTY_MEMBERS do
			_G["PartyMemberFrame"..i]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i]:SetParent(UIFrameHider)
			_G["PartyMemberFrame"..i]:Hide()
			_G["PartyMemberFrame"..i.."HealthBar"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."ManaBar"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."PetFrame"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."PetFrame"]:SetParent(UIFrameHider)
			_G["PartyMemberFrame"..i.."PetFrame".."HealthBar"]:UnregisterAllEvents()

			HidePartyFrame()
			ShowPartyFrame = K.Noop
			HidePartyFrame = K.Noop
		end
	end

	if C.Raidframe.Enable then
		if not CompactRaidFrameManager_UpdateShown then
			StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
		else
			if not CompactRaidFrameManager.hookedHide then
				hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
				CompactRaidFrameManager:HookScript("OnShow", HideRaid)
				CompactRaidFrameManager.hookedHide = true
			end
			CompactRaidFrameContainer:UnregisterAllEvents()
			HideRaid()
		end
	end

	if C.Unitframe.Enable and C.Raidframe.Enable then
		DisableBlizzard:RegisterEvent("GROUP_ROSTER_UPDATE", "DisableBlizzard")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- This may fuck shit up.. we"ll see...
	else
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
	end

	Advanced_UIScaleSlider:Kill()
	Advanced_UseUIScale:Kill()

	if C.General.DisableTutorialButtons then
		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
		PetJournalTutorialButton:Kill()
		PlayerTalentFramePetSpecializationTutorialButton:Kill()
		PlayerTalentFrameSpecializationTutorialButton:Kill()
		PlayerTalentFrameTalentsTutorialButton:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SpellBookFrameTutorialButton:Kill()
		TalentMicroButtonAlert:Kill()
		WorldMapFrameTutorialButton:Kill()
	end

	if C.Unitframe.Enable then
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
	end

	if C.Nameplates.Enable then
		SetCVar("ShowClassColorInNameplate", 1)
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end
end)