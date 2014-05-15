--[[--------------------------------------------------------------------
    Ovale Spell Priority
    Copyright (C) 2012 Sidoine
    Copyright (C) 2012, 2013, 2014 Johnny C. Lam

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License in the LICENSE
    file accompanying this program.
--]]--------------------------------------------------------------------

--[[
	This addon tracks rune information on death knights.
--]]

local _, Ovale = ...
local OvaleRunes = Ovale:NewModule("OvaleRunes", "AceEvent-3.0")
Ovale.OvaleRunes = OvaleRunes

--<private-static-properties>
-- Forward declarations for module dependencies.
local OvaleData = nil
local OvalePower = nil
local OvaleSpellBook = nil
local OvaleStance = nil
local OvaleState = nil

local ipairs = ipairs
local pairs = pairs
local API_GetRuneCooldown = GetRuneCooldown
local API_GetRuneType = GetRuneType
local API_GetTime = GetTime
local API_UnitClass = UnitClass

-- Player's class.
local _, self_class = API_UnitClass("player")

local BLOOD_RUNE = 1
local UNHOLY_RUNE = 2
local FROST_RUNE = 3
local DEATH_RUNE = 4

local RUNE_TYPE = {
	blood = BLOOD_RUNE,
	unholy = UNHOLY_RUNE,
	frost = FROST_RUNE,
	death = DEATH_RUNE,
}
local RUNE_NAME = {}
do
	for k, v in pairs(RUNE_TYPE) do
		RUNE_NAME[v] = k
	end
end

--[[
	Rune slots are numbered as follows in the default UI:

		blood	frost	unholy
		[1][2]	[5][6]	[3][4]
--]]
local RUNE_SLOTS = {
	[BLOOD_RUNE] =	{ 1, 2 },
	[UNHOLY_RUNE] =	{ 3, 4 },
	[FROST_RUNE] =	{ 5, 6 },
}

--[[
	From SimulationCraft's sc_death_knight.cpp:

	If explicitly consuming a death rune, any death runes available are preferred in the order:

		frost > blood > unholy.

	If consuming a non-death rune of a given type and that no rune of that type is available,
	any death runes available are preferred in the order:

		blood > unholy > frost
--]]
local DEATH_RUNE_PRIORITY = { 3, 4, 5, 6, 1, 2 }
local ANY_RUNE_PRIORITY = { 1, 2, 3, 4, 5, 6 }

-- Improved Blood Presence increases rune regenerate rate by 20%.
local IMPROVED_BLOOD_PRESENCE = 50371
--</private-static-properties>

--<public-static-properties>
-- Current rune information, indexed by slot.
OvaleRunes.rune = {}
OvaleRunes.RUNE_TYPE = RUNE_TYPE
--</public-static-properties>

--<private-static-methods>
local function IsActiveRune(rune, atTime)
	return (rune.startCooldown == 0 or rune.endCooldown <= atTime)
end
--</private-static-methods>

--<public-static-methods>
function OvaleRunes:OnInitialize()
	-- Resolve module dependencies.
	OvaleData = Ovale.OvaleData
	OvalePower = Ovale.OvalePower
	OvaleSpellBook = Ovale.OvaleSpellBook
	OvaleStance = Ovale.OvaleStance
	OvaleState = Ovale.OvaleState
end

function OvaleRunes:OnEnable()
	if self_class == "DEATHKNIGHT" then
		-- Initialize rune database.
		for runeType, slots in ipairs(RUNE_SLOTS) do
			for _, slot in pairs(slots) do
				self.rune[slot] = { slotType = runeType, IsActiveRune = IsActiveRune }
			end
		end
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllRunes")
		self:RegisterEvent("PLAYER_LOGIN", "UpdateAllRunes")
		self:RegisterEvent("RUNE_POWER_UPDATE")
		self:RegisterEvent("RUNE_TYPE_UPDATE")
		self:RegisterEvent("UNIT_RANGEDDAMAGE")
		self:RegisterEvent("UNIT_SPELL_HASTE", "UNIT_RANGEDDAMAGE")
		OvaleState:RegisterState(self, self.statePrototype)
	end
end

function OvaleRunes:OnDisable()
	if self_class == "DEATHKNIGHT" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_LOGIN")
		self:UnregisterEvent("RUNE_POWER_UPDATE")
		self:UnregisterEvent("RUNE_TYPE_UPDATE")
		self:UnregisterEvent("UNIT_RANGEDDAMAGE")
		self:UnregisterEvent("UNIT_SPELL_HASTE")
		OvaleState:UnregisterState(self)
		self.rune = {}
	end
end

function OvaleRunes:RUNE_POWER_UPDATE(event, slot, usable)
	self:UpdateRune(slot)
end

function OvaleRunes:RUNE_TYPE_UPDATE(event, slot)
	self:UpdateRune(slot)
end

function OvaleRunes:UNIT_RANGEDDAMAGE(event, unitId)
	if unitId == "player" then
		self:UpdateAllRunes()
	end
end

function OvaleRunes:UpdateRune(slot)
	local rune = self.rune[slot]
	local runeType = API_GetRuneType(slot)
	local start, duration, runeReady = API_GetRuneCooldown(slot)
	rune.type = runeType
	if start > 0 then
		-- Rune is on cooldown.
		rune.startCooldown = start
		rune.endCooldown = start + duration
	else
		-- Rune is active.
		rune.startCooldown = 0
		rune.endCooldown = 0
	end
end

function OvaleRunes:UpdateAllRunes()
	for slot = 1, 6 do
		self:UpdateRune(slot)
	end
end

function OvaleRunes:Debug()
	local now = API_GetTime()
	for slot = 1, 6 do
		local rune = self.rune[slot]
		if rune:IsActiveRune(now) then
			Ovale:FormatPrint("rune[%d] (%s) is active.", slot, RUNE_NAME[rune.type])
		else
			Ovale:FormatPrint("rune[%d] (%s) comes off cooldown in %f seconds.", slot, RUNE_NAME[rune.type], rune.endCooldown - now)
		end
	end
end
--</public-static-methods>

--[[----------------------------------------------------------------------------
	State machine for simulator.

	AFTER: OvalePower
--]]----------------------------------------------------------------------------

--<public-static-properties>
OvaleRunes.statePrototype = {}
--</public-static-properties>

--<private-static-properties>
local statePrototype = OvaleRunes.statePrototype
--</private-static-properties>

--<state-properties>
-- indexed by slot (1 through 6)
statePrototype.rune = nil
--</state-properties>

--<public-static-methods>
-- Initialize the state.
function OvaleRunes:InitializeState(state)
	state.rune = {}
	for slot in ipairs(self.rune) do
		state.rune[slot] = {}
	end
end

-- Reset the state to the current conditions.
function OvaleRunes:ResetState(state)
	for slot, rune in ipairs(self.rune) do
		local stateRune = state.rune[slot]
		for k, v in pairs(rune) do
			stateRune[k] = v
		end
	end
end

-- Release state resources prior to removing from the simulator.
function OvaleRunes:CleanState(state)
	for slot, rune in ipairs(state.rune) do
		for k in pairs(rune) do
			rune[k] = nil
		end
		state.rune[slot] = nil
	end
end

-- Apply the effects of the spell on the player's state, assuming the spellcast completes.
function OvaleRunes:ApplySpellAfterCast(state, spellId, targetGUID, startCast, endCast, nextCast, isChanneled, nocd, spellcast)
	local si = OvaleData.spellInfo[spellId]
	if si then
		for i, name in ipairs(RUNE_NAME) do
			local count = si[name] or 0
			while count > 0 do
				local atTime = isChanneled and startCast or endCast
				state:ConsumeRune(atTime, name, spellcast.snapshot)
				count = count - 1
			end
		end
	end
end
--</public-static-methods>

--<state-methods>
statePrototype.DebugRunes = function(state)
	local now = state.currentTime
	for slot, rune in ipairs(state.rune) do
		if rune:IsActiveRune(now) then
			Ovale:FormatPrint("rune[%d] (%s) is active.", slot, RUNE_NAME[rune.type])
		else
			Ovale:FormatPrint("rune[%d] (%s) comes off cooldown in %f seconds.", slot, RUNE_NAME[rune.type], rune.endCooldown - now)
		end
	end
end

-- Consume a rune of the given type.  Assume that the required runes are available.
statePrototype.ConsumeRune = function(state, atTime, name, snapshot)
	--[[
		Find a usable rune, preferring a regular rune of that rune type over death
		runes of that rune type over death runes of any rune type.
	--]]
	local consumedRune
	local runeType = RUNE_TYPE[name]
	if runeType ~= DEATH_RUNE then
		-- Search for an active regular rune of the given rune type.
		for _, slot in ipairs(RUNE_SLOTS[runeType]) do
			local rune = state.rune[slot]
			if rune.type == runeType and rune:IsActiveRune(atTime) then
				consumedRune = rune
				break
			end
		end
		if not consumedRune then
			-- Search for an active death rune of the given rune type.
			for _, slot in ipairs(RUNE_SLOTS[runeType]) do
				if rune.type == DEATH_RUNE and rune:IsActiveRune(atTime) then
					consumedRune = rune
					break
				end
			end
		end
	end
	-- No runes of the right type are active, so look for any active death rune.
	if not consumedRune then
		local deathRunePriority = (runeType == DEATH_RUNE) and DEATH_RUNE_PRIORITY or ANY_RUNE_PRIORITY
		for _, slot in ipairs(deathRunePriority) do
			local rune = state.rune[slot]
			if rune.type == DEATH_RUNE and rune:IsActiveRune(atTime) then
				consumedRune = rune
				break
			end
		end
	end
	if consumedRune then
		-- Put that rune on cooldown, starting when the other rune of that slot type comes off cooldown.
		local k = consumedRune.slotType
		local start = atTime
		for _, slot in ipairs(RUNE_SLOTS[consumedRune.slotType]) do
			local rune = state.rune[slot]
			if rune.endCooldown > start then
				start = rune.endCooldown
			end
		end
		local duration = 10 / state:GetSpellHasteMultiplier(snapshot)
		if OvaleStance:IsStance("deathknight_blood_presence") and OvaleSpellBook:IsKnownSpell(IMPROVED_BLOOD_PRESENCE) then
			-- Improved Blood Presence increases rune regeneration rate by 20%.
			duration = duration / 1.2
		end
		consumedRune.startCooldown = start
		consumedRune.endCooldown = start + duration

		-- Each rune consumed generates 10 (12, if in Frost Presence) runic power.
		local runicpower = state.runicpower
		if OvaleStance:IsStance("deathknight_frost_presence") then
			runicpower = runicpower + 12
		else
			runicpower = runicpower + 10
		end
		local maxi = OvalePower.maxPower.runicpower
		state.runicpower = (runicpower < maxi) and runicpower or maxi
	else
		Ovale:Errorf("No %s rune available to consume!", RUNE_NAME[runeType])
	end
end

-- Returns a triplet of count, startCooldown, endCooldown:
--     count			The number of currently active runes of the given type.
--     startCooldown	The time at which the next rune of the given type went on cooldown.
--     endCooldown		The time at which the next rune of the given type will be active.
statePrototype.RuneCount = function(state, name, deathCondition)
	local count = 0
	local startCooldown, endCooldown = math.huge, math.huge
	local runeType = RUNE_TYPE[name]
	local now = state.currentTime
	if runeType ~= DEATH_RUNE then
		if deathCondition == "any" then
			-- Match runes of the given type or any death runes.
			for slot, rune in ipairs(state.rune) do
				if rune.type == runeType or rune.type == DEATH_RUNE then
					if rune:IsActiveRune(now) then
						count = count + 1
					elseif rune.endCooldown < endCooldown then
						startCooldown, endCooldown = rune.startCooldown, rune.endCooldown
					end
				end
			end
		else
			-- Match only the runes of the given type.
			for _, slot in ipairs(RUNE_SLOTS[runeType]) do
				local rune = state.rune[slot]
				if not deathCondition or (deathCondition == "none" and rune.type ~= DEATH_RUNE) then
					if rune:IsActiveRune(now) then
						count = count + 1
					elseif rune.endCooldown < endCooldown then
						startCooldown, endCooldown = rune.startCooldown, rune.endCooldown
					end
				end
			end
		end
	else
		-- Match any requested death runes.
		for slot, rune in ipairs(state.rune) do
			if rune.type == DEATH_RUNE then
				if rune:IsActiveRune(now) then
					count = count + 1
				elseif rune.endCooldown < endCooldown then
					startCooldown, endCooldown = rune.startCooldown, rune.endCooldown
				end
			end
		end
	end
	return count, startCooldown, endCooldown
end

-- Returns the number of seconds before all of the required runes are available.
statePrototype.GetRunesCooldown = nil
do
	-- If the rune is active, then return the remaining active runes count requirement.
	-- Also return the time of the next rune becoming active.
	local function MatchingRune(rune, count, endCooldown)
		if count > 0 then
			count = count - 1
			if rune.endCooldown > endCooldown then
				endCooldown = rune.endCooldown
			end
		else
			if rune.endCooldown < endCooldown then
				endCooldown = rune.endCooldown
			end
		end
		return count, endCooldown
	end

	-- The remaining count requirements, indexed by rune type.
	local runeCount = {}
	-- The latest time till a rune of that type is off cooldown, indexed by rune type.
	local runeEndCooldown = {}

	statePrototype.GetRunesCooldown = function(state, blood, unholy, frost, death, deathCondition)
		-- Initialize static variables.
		runeCount[BLOOD_RUNE] = blood or 0
		runeCount[UNHOLY_RUNE] = unholy or 0
		runeCount[FROST_RUNE] = frost or 0
		runeCount[DEATH_RUNE] = death or 0
		runeEndCooldown[BLOOD_RUNE] = 0
		runeEndCooldown[UNHOLY_RUNE] = 0
		runeEndCooldown[FROST_RUNE] = 0
		runeEndCooldown[DEATH_RUNE] = 0

		-- Use regular runes to meet the count requirements.
		for slot, rune in ipairs(state.rune) do
			if rune.type ~= DEATH_RUNE then
				local runeType = rune.type
				local count, endCooldown = MatchingRune(rune, runeCount[runeType], runeEndCooldown[runeType])
				runeCount[runeType] = count
				runeEndCooldown[runeType] = endCooldown
			end
		end
		-- Use death runes of the matching rune type to meet the count requirements.
		if deathCondition ~= "none" then
			for slot, rune in ipairs(state.rune) do
				if rune.type == DEATH_RUNE then
					local runeType = rune.slotType
					local count, endCooldown = MatchingRune(rune, runeCount[runeType], runeEndCooldown[runeType])
					runeCount[runeType] = count
					runeEndCooldown[runeType] = endCooldown
				end
			end
		end

		-- Remaining rune requirements that have not yet been met.
		local remainingCount = 0
		for runeType = 1, 4 do
			remainingCount = remainingCount + runeCount[runeType]
		end

		-- Use death runes of any type to meet any remaining count requirements.
		if deathCondition == "any" then
			for _, slot in ipairs(DEATH_RUNE_PRIORITY) do
				local rune = state.rune[slot]
				local runeType = DEATH_RUNE
				local count, endCooldown = MatchingRune(rune, remainingCount, runeEndCooldown[runeType])
				remainingCount = count
				runeEndCooldown[runeType] = endCooldown
			end
		end

		-- This shouldn't happen because it means the rune requirements will never be met.
		if remainingCount > 0 then
			Ovale:Logf("Impossible rune count requirements: blood=%d, unholy=%d, frost=%d, death=%d", blood, unholy, frost, death)
			return math.huge
		end

		local maxEndCooldown = 0
		for runeType = 1, 4 do
			if runeEndCooldown[runeType] > maxEndCooldown then
				maxEndCooldown = runeEndCooldown[runeType]
			end
		end
		if maxEndCooldown > 0 then
			return maxEndCooldown - state.currentTime
		end
		return 0
	end
end
--</state-methods>
