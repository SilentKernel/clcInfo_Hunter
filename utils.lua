local _, class = UnitClass("player")
if class ~= "HUNTER" then return end

-- utilities function for functions that all the spec files use
-- to update their state

local emod = clcInfo.env

function emod:GetBuff(buff)
	local left = 0
	local __, __, __, __, __, __, expires = UnitBuff("player", buff, nil, "PLAYER")
	if expires then
		left = max(0, expires - s_ctime)
	end
	return left
end

function emod:GetBuffStacks(buff)
	local __, __, __, count = UnitBuff("player", buff, nil, "PLAYER")
	--print("je suis dans la fonction")
	if count == nil then
		return 0
	else
		return count
	end
end

function emod:GetTargetDebuff(debuff)
	local left = 0
	local name, __, __, __, __, __, expires, __, __, __, __ = UnitAura("target", debuff, nil, "PLAYER|HARMFUL")
	if expires and expires > 0 then
		left = max(0, expires - s_ctime)
	elseif name then
		-- debuffs without times (murder??!)
		left = 100
	end
	return left
end

function emod:GetTargetIsABoss()
	if (UnitLevel("target") == -1) then
		--print("is a boss")
		return true
	else
		return false
	end
end
