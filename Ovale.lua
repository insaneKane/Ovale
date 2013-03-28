--[[--------------------------------------------------------------------
    Ovale Spell Priority
    Copyright (C) 2009, 2010, 2011, 2012, 2013 Sidoine, Johnny C. Lam

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License in the LICENSE
    file accompanying this program.
----------------------------------------------------------------------]]

local _, addonNamespace = ...
local Ovale = LibStub("AceAddon-3.0"):NewAddon(addonNamespace, "Ovale", "AceConsole-3.0", "AceEvent-3.0")

--<private-static-properties>
local L = LibStub("AceLocale-3.0"):GetLocale("Ovale")
local OvaleGUID = nil
local OvaleOptions = nil

local format = string.format
local pairs = pairs
local wipe = table.wipe
local API_GetTime = GetTime
local API_SendAddonMessage = SendAddonMessage
local API_UnitCanAttack = UnitCanAttack
local API_UnitExists = UnitExists
local API_UnitHasVehicleUI = UnitHasVehicleUI
local API_UnitIsDead = UnitIsDead
--</private-static-properties>

--<public-static-properties>
Ovale.L = L
--The current time, updated once per frame refresh.
Ovale.now = API_GetTime()
--The table of check boxes definition
Ovale.casesACocher = {}
--the frame with the icons
Ovale.frame = nil
--check boxes GUI items
Ovale.checkBoxes = {}
--drop down GUI items
Ovale.dropDowns = {}
--set it if there was a bug, traces will be enabled on next frame
Ovale.bug = false
Ovale.traced = false
--trace next script function calls
Ovale.trace=false
--in combat?
Ovale.enCombat = false
--score in current combat
Ovale.score = 0
--maximal theoric score in current combat
Ovale.maxScore = 0
Ovale.refreshNeeded = {}
Ovale.combatStartTime = nil
Ovale.listes = {}
--</public-static-properties>

--Key bindings
BINDING_HEADER_OVALE = "Ovale"
BINDING_NAME_OVALE_CHECKBOX0 = L["Inverser la boîte à cocher "].."(1)"
BINDING_NAME_OVALE_CHECKBOX1 = L["Inverser la boîte à cocher "].."(2)"
BINDING_NAME_OVALE_CHECKBOX2 = L["Inverser la boîte à cocher "].."(3)"
BINDING_NAME_OVALE_CHECKBOX3 = L["Inverser la boîte à cocher "].."(4)"
BINDING_NAME_OVALE_CHECKBOX4 = L["Inverser la boîte à cocher "].."(5)"

--<public-static-methods>
function Ovale:OnEnable()
    -- Called when the addon is enabled
	OvaleGUID = Ovale:GetModule("OvaleGUID")
	OvaleOptions = Ovale:GetModule("OvaleOptions")

	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED")

	self.frame = LibStub("AceGUI-3.0"):Create("OvaleFrame")
	self:UpdateFrame()
end

function Ovale:OnDisable()
    -- Called when the addon is disabled
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self.frame:Hide()
end

--Called when the player target change
--Used to update the visibility e.g. if the user chose
--to hide Ovale if a friendly unit is targeted
function Ovale:PLAYER_TARGET_CHANGED()
	self.refreshNeeded.target = true
	self:UpdateVisibility()
end

function Ovale:PLAYER_REGEN_ENABLED()
	self.enCombat = false
	self:UpdateVisibility()
	-- if self.maxScore and self.maxScore > 0 then
	-- 	self:Print((self.score/self.maxScore*100).."%")
	-- end
end

function Ovale:PLAYER_REGEN_DISABLED()
	if self.maxScore > 0 then
		-- Broadcast message is "score;maxScore;playerGUID"
		local message = self.score .. ";" .. self.maxScore .. ";" .. OvaleGUID:GetGUID("player")
		API_SendAddonMessage("Ovale", message, "RAID")
	end
	self.enCombat = true
	self.score = 0
	self.maxScore = 0
	self.combatStartTime = Ovale.now
	self:UpdateVisibility()
end

local function OnCheckBoxValueChanged(widget)
	OvaleOptions:GetProfile().check[widget.userdata.k] = widget:GetValue()
	if Ovale.casesACocher[widget.userdata.k].compile then
		Ovale:SendMessage("Ovale_CheckBoxValueChanged")
	end
end

local function OnDropDownValueChanged(widget)
	OvaleOptions:GetProfile().list[widget.userdata.k] = widget.value
	if Ovale.listes[widget.userdata.k].compile then
		Ovale:SendMessage("Ovale_ListValueChanged")
	end
end

function Ovale:ToggleOptions()
	self.frame:ToggleOptions()
end

function Ovale:UpdateVisibility()
	local profile = OvaleOptions:GetProfile()

	if not profile.display then
		self.frame:Hide()
		return
	end

	self.frame:Show()
	if profile.apparence.hideVehicule and API_UnitHasVehicleUI("player") then
		self.frame:Hide()
	end
	
	if profile.apparence.avecCible and not API_UnitExists("target") then
		self.frame:Hide()
	end
	
	if profile.apparence.enCombat and not Ovale.enCombat then
		self.frame:Hide()
	end	
	
	if profile.apparence.targetHostileOnly and (API_UnitIsDead("target") or not API_UnitCanAttack("player", "target")) then
		self.frame:Hide()
	end
end

function Ovale:UpdateFrame()
	local profile = OvaleOptions:GetProfile()
	self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", profile.left, profile.top)

	self.frame:ReleaseChildren()

	self.frame:UpdateIcons()
	
	self:UpdateVisibility()
	
	wipe(self.checkBoxes)
	
	for k,checkBox in pairs(self.casesACocher) do
		self.checkBoxes[k] = LibStub("AceGUI-3.0"):Create("CheckBox");
		self.frame:AddChild(self.checkBoxes[k])
		self.checkBoxes[k]:SetLabel(checkBox.text)
		if profile.check[k]==nil then
			profile.check[k] = checkBox.checked
		end
		if (profile.check[k]) then
			self.checkBoxes[k]:SetValue(profile.check[k]);
		end
		self.checkBoxes[k].userdata.k = k
		self.checkBoxes[k]:SetCallback("OnValueChanged",OnCheckBoxValueChanged)
	end
	
	wipe(self.dropDowns)
	
	if (self.listes) then
		for k,list in pairs(self.listes) do
			self.dropDowns[k] = LibStub("AceGUI-3.0"):Create("Dropdown");
			self.dropDowns[k]:SetList(list.items)
			if not profile.list[k] then
				profile.list[k] = list.default
			end
			if (profile.list[k]) then
				self.dropDowns[k]:SetValue(profile.list[k]);
			end
			self.dropDowns[k].userdata.k = k
			self.dropDowns[k]:SetCallback("OnValueChanged",OnDropDownValueChanged)
			self.frame:AddChild(self.dropDowns[k])
		end
	end
end

function Ovale:IsChecked(v)
	return self.checkBoxes[v] and self.checkBoxes[v]:GetValue()
end

function Ovale:GetListValue(v)
	return self.dropDowns[v] and self.dropDowns[v].value
end

function Ovale:SetCheckBox(v,on)
	for k,checkBox in pairs(self.casesACocher) do
		if v==0 then
			self.checkBoxes[k]:SetValue(on)
			OvaleOptions:GetProfile().check[k] = on
			break
		end
		v = v - 1
	end
end

function Ovale:ToggleCheckBox(v)
	for k,checkBox in pairs(self.casesACocher) do
		if v==0 then
			self.checkBoxes[k]:SetValue(not self.checkBoxes[k]:GetValue())
			OvaleOptions:GetProfile().check[k] = self.checkBoxes[k]:GetValue()
			break
		end
		v = v - 1
	end
end

function Ovale:DebugPrint(flag, ...)
	local profile = OvaleOptions:GetProfile()
	if profile and profile.debug and profile.debug[flag] then
		self:Print("[" .. flag .. "]", ...)
	end
end

function Ovale:DebugPrintf(flag, ...)
	local profile = OvaleOptions:GetProfile()
	if profile and profile.debug and profile.debug[flag] then
		self:Printf("[%s] %s", flag, format(...))
	end
end

function Ovale:Error(...)
	self:Print("Fatal error: ", ...)
	self.bug = true
end

function Ovale:Errorf(...)
	self:Printf("Fatal error: %s", format(...))
	self.bug = true
end

function Ovale:Log(...)
	if self.trace then
		self:Print(...)
	end
end

function Ovale:Logf(...)
	if self.trace then
		return self:Printf(...)
	end
end
--</public-static-methods>
