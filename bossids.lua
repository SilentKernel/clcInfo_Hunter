local _, class = UnitClass("player")
if class ~= "HUNTER" then return end

local emod = clcInfo.env
local overrides = {
	[362] = { -- Throne of Thunder
		"Durumu the Forgotten", -- Durumu appears in the EJ db as "Durumu", which does not match his
								-- actual NPC name.
	}
}

local spellframe = CreateFrame("Frame", nil, UIParent)
spellframe:RegisterEvent("PLAYER_ENTERING_WORLD")
spellframe:RegisterEvent("ZONE_CHANGED")
spellframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")

spellframe:SetScript("OnEvent", function(self, event, unit, name, rank, line, id)
	if event == "PLAYER_ENTERING_WORLD" or "ZONE_CHANGED" or "ZONE_CHANGED_NEW_AREA" then
		-- we're caching talents in emod.talents, so need to hook them when we log in
		-- or when we change spec
		emod:UpdateEncounterBosses()
	end
end)

emod.instance_bosses = {}

function emod:UpdateEncounterBosses()
	table.wipe(emod.instance_bosses)

	-- traverse the creatures of every encounter in the current dungeon/raid
	-- and build a list of names of creatures
	local instanceID = EJ_GetCurrentInstance()
	if not instanceID or instanceID == 0 then return end

	local encounterIndex = 1
	local __, __, encounterID, __, __ = EJ_GetEncounterInfoByIndex(encounterIndex, instanceID)

	while encounterID do
		local bossIndex = 1
		local __, bossName = EJ_GetCreatureInfo(bossIndex, encounterID)

		while bossName do
			table.insert(emod.instance_bosses, bossName)

			bossIndex = bossIndex + 1
			__, bossName = EJ_GetCreatureInfo(bossIndex, encounterID)
		end

		encounterIndex = encounterIndex + 1
		__, __, encounterID = EJ_GetEncounterInfoByIndex(encounterIndex, instanceID)
	end
end

function emod:UnitIsBoss(unit)
	-- if we've already got instances bosses and it matches, let's not do all the
	-- calls to parse the GUID into pieces, etc.
	if #emod.instance_bosses > 0 then
		if tContains(emod.instance_bosses, UnitName("target")) then return true end
	end

	if overrides[EJ_GetCurrentInstance()] and #overrides[EJ_GetCurrentInstance()] > 0 then
		if tContains(overrides[EJ_GetCurrentInstance()], UnitName("target")) then return true end
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		return true
	end

	return false
end
