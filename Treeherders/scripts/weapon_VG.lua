Eplanum_TH_ViolentGrowth = Skill:new
{
    Class = "Science",
    Icon = "weapons/science_th_violentGrowth.png",
	Rarity = 1,
	
	Explosion = "",
--	LaunchSound = "/weapons/titan_fist",
--	ImpactSound = "/impact/generic/tractor_beam",
	
	Range = 1,
	PathSize = 1,
    Damage = 1,
	
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 2, 1 },
	
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Forest = Point(1,2),
	},
	
	ForestDamageBounce = -2,
	NonForestBounce = 2,
	ForestGenBounce = forestUtils.floraformBounce,
	
	ForestToExpand = 2,
	ForestGenDamage = 0,
	SurroundedDamage = 0,
	RallyCap = 0,
	
	ExtraIfTargetForest = false,
	SeekVek = false,
	PushTarget = true,
}

Eplanum_TH_ViolentGrowth_A = Eplanum_TH_ViolentGrowth:new
{
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Enemy2 = Point(1,1),
		Forest = Point(2,2),
		Forest2 = Point(1,2),
	},
	
	ForestGenDamage = 1,
	ExtraIfTargetForest = true,
	SeekVek = true,
}

Eplanum_TH_ViolentGrowth_B = Eplanum_TH_ViolentGrowth:new
{
	RallyCap = 1,
}

Eplanum_TH_ViolentGrowth_AB = Eplanum_TH_ViolentGrowth_A:new
{	
	RallyCap = 1,
}
local function forestOrFutureForestFn(p, ...)
	local toCount = select(1, ...)
	return forestUtils.isAForest(p) or toCount[forestUtils:getSpaceHash(p)]
end 

local function forestSurroundsFn(p, ...)
	if forestOrFutureForestFn(p, ...) then
		return true
	end
	
	local terrian = Board:GetTerrain(p)
	local pawn = Board:GetPawn(p)
	if terrian == TERRAIN_MOUNTAIN or terrian == TERRAIN_BUILDING then
		return true
	elseif pawn then
		if pawn.Massive and (terrian == TERRAIN_WATER or terrian == TERRAIN_ACID or terrian == TERRAIN_LAVA) then
			return false
		elseif pawn:IsFlying() and (terrian == TERRAIN_WATER or terrian == TERRAIN_ACID or terrian == TERRAIN_LAVA or terrian == TERRAIN_HOLE) then
			return false
		elseif terrian == TERRAIN_WATER or terrian == TERRAIN_ACID or terrian == TERRAIN_LAVA or terrian == TERRAIN_HOLE then
			return true
		end
	end
end
			
function Eplanum_TH_ViolentGrowth:GetSkillEffect(p1, p2)

	local randId = "Eplanum_TH_ViolentGrowth"..tostring(Pawn:GetId())

	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	local leftToGen = self.ForestToExpand
	
	local rallyDamage = forestUtils:getNumForestsInPlus(p2)
	if rallyDamage > self.RallyCap then
		rallyDamage = self.RallyCap
	end
	
	--generate forest on target and damage it
	local pushDir = nil
	if self.PushTarget then
		pushDir = attackDir
	end
	
	local damage = self.Damage
	
	if forestUtils.isAForest(p2) then
		ret:AddDamage(forestUtils:getSpaceDamageWithoutSettingFire(p2, self.Damage + rallyDamage, pushDir, false, false))
		ret:AddBounce(p2, self.NonForestBounce)
	elseif forestUtils.isSpaceFloraformable(p2) then
		forestUtils:floraformSpace(ret, p2, self.Damage + self.ForestGenDamage + rallyDamage, pushDir, false, false)
		leftToGen = leftToGen - 1
	end
	
	--small break to make the animation and move make more sense
	ret:AddDelay(0.4)
	
	--Get all spaces in the grouping
	local forestGroup = forestUtils:getGroupingOfSpaces(p2, forestUtils.isAForest)
	--ensure the space we just formed is not in the boarding list - it will be in the group list
	forestGroup.boardering[forestUtils:getSpaceHash(p2)] = nil
	
	--pick tiles to expand to and damage if appropriate
	local expansionDamage = DAMAGE_ZERO
	if self.ForestGenDamage > 0 then
		expansionDamage = self.ForestGenDamage
	end
	
	local newForests = forestUtils:floraformNumOfRandomSpaces(ret, randId, forestGroup.boardering, leftToGen,
								expansionDamage, nil, true, true, true, nil, self.SeekVek, forestUtils:getSpaceHash(p1) + forestUtils:getSpaceHash(p2))
	newForests[forestUtils:getSpaceHash(p2)] = p2
	
			
	--evaluate if we are pushing a fire unit onto a space we are floraforming because otherwise
	--we will put out the enemy
	if self.PushTarget then
		local pawn = Board:GetPawn(p2)
		
		if pawn and pawn:IsFire() and not ret.effect:empty() then
			for _, spaceDamage in pairs(extract_table(ret.effect)) do	
				if spaceDamage.loc == p2 + DIR_VECTORS[pushDir] then
					spaceDamage.iFire = EFFECT_NONE
				end
			end
		end
	end
	
	--small break to make the animation and move make more sense
	ret:AddDelay(0.4)
	
	--damage any enemies surrounded by forest
	--dont forget to check the target when it is pushed
	if self.SurroundedDamage > 0 then
		local pushSpace = p2 + DIR_VECTORS[pushDir]
		local surroundedEnemies = {}
		for k, v in pairs(forestGroup.group) do
			local unit = Board:GetPawn(v)
			if unit and unit:IsEnemy() then
				--The target pawn has special logic if we are pushing
				if (not self.PushTarget) or unit:GetSpace() ~= p2 then
					--we already know the unit is on the space
					if unit:IsEnemy() and forestUtils:isSpaceSurroundedBy(v, forestSurroundsFn, newForests) then	
						ret:AddDamage(forestUtils:getSpaceDamageWithoutSettingFire(v, self.SurroundedDamage, nil, true, true))
						ret:AddBounce(v, self.NonForestBounce)
					end
				end
			end
		end
		
		if (self.PushTarget and forestOrFutureForestFn(pushSpace, newForests) and forestUtils:isSpaceSurroundedBy(pushSpace, forestSurroundsFn, newForests)) then
			ret:AddDamage(forestUtils:getSpaceDamageWithoutSettingFire(pushSpace, self.SurroundedDamage, nil, true, true))
			ret:AddBounce(pushSpace, self.NonForestBounce)
		end
	end
	
	return ret
end