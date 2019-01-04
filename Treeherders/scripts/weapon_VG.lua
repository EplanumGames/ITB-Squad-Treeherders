Eplanum_TH_ViolentGrowth = Skill:new
{
    Class = "Science",
    Icon = "weapons/science_th_violentGrowth.png",
	Rarity = 1,
	
	Explosion = "",
	--TODO sounds
--	LaunchSound = "/weapons/titan_fist",
--	ImpactSound = "/impact/generic/tractor_beam",
	
	Range = 1,
	PathSize = 1,
    Damage = 1,
	
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 1, 1 },
	
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Enemy2 = Point(1,1),
		Forest = Point(2,2),
		Forest2 = Point(1,2),
	},
	
	ForestDamageBounce = -2,
	NonForestBounce = 2,
	ForestGenBounce = forestUtils.floraformBounce,
	
	PushTarget = false,
	SeekVek = true,
	SlowEnemyMaxMove = 2,
	
	ForestToExpand = 1,
	SlowEnemy = false,
	SlowEnemyAmount = 2,
	MinEnemyMove = 1,
	
}

Eplanum_TH_ViolentGrowth_A = Eplanum_TH_ViolentGrowth:new
{
	SlowEnemy = true,
}

Eplanum_TH_ViolentGrowth_B = Eplanum_TH_ViolentGrowth:new
{
	ForestToExpand = 3,
}

Eplanum_TH_ViolentGrowth_AB = Eplanum_TH_ViolentGrowth_A:new
{	
	ForestToExpand = 3,
}
			
--TODO make match new description
function Eplanum_TH_ViolentGrowth:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	
	
	----- For the main target ------
	local pushDir = nil
	if self.PushTarget then
		pushDir = attackDir
	end
		
	--if it is a forest, cancel the target's attack
	if forestUtils.isAForest(p2) then
		forestUtils:cancelAttack(p2, ret)
		ret:AddBounce(p2, self.NonForestBounce)
	
	--if it can be floraformed, do so
	elseif forestUtils.isSpaceFloraformable(p2) then
		forestUtils:floraformSpace(ret, p2, self.Damage, pushDir, false, true)
		
	--otherwise just damage it
	else
		ret:AddDamage(SpaceDamage(p2, self.Damage))
		ret:AddBounce(p2, self.NonForestBounce)
	end
	
	--small break to make the animation and move make more sense
	ret:AddDelay(0.4)
	
	
	----- For expansion ------
	
	--pick tiles to expand to and damage if appropriate
	--get tiles closest to enemies
	local expansionFocus = p1
	if self.SeekVek then
		local vekPositions = {}
		for _, v in pairs(extract_table(Board:GetPawns(TEAM_ENEMY))) do
			local vPos = v:GetSpace()
			vekPositions[forestUtils:getSpaceHash(vPos)] = vPos
		end
		
		if vekPositions ~= {} then
			expansionFocus = forestUtils:getClosestOfSpaces(p1, vekPositions)
		end
	end
	
	--Get all spaces in the grouping
	local forestGroup = forestUtils:getGroupingOfSpaces(p2, forestUtils.isAForest)
	--ensure the space we just formed is not in the boarding list - it will be in the group list
	forestGroup.boardering[forestUtils:getSpaceHash(p2)] = nil
	
	local newForests = {}
	for i = 1, self.ForestToExpand do
		if forestGroup.boardering ~= {} then
			--get the nearest point, and remove it from the candidates
			local expansion = forestUtils:getClosestOfSpaces(expansionFocus, forestGroup.boardering)
			forestGroup.boardering[forestUtils:getSpaceHash(expansion)] = nil
			newForests[forestUtils:getSpaceHash(expansion)] = expansion
			
			--floraform it
			forestUtils:floraformSpace(ret, expansion, self.Damage, nil, false, true)
		end
	end
	newForests[forestUtils:getSpaceHash(p2)] = p2
	
	
	----- for pushing target -----
	
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
	
	
	----- For slowing enemies -----
	
	--any enemy in the forest, slow down temporarily if the powerup is enabled
	if self.SlowEnemy then
		for _, v in pairs(forestGroup.group) do
			local pawn = Board:GetPawn(v)
			if pawn and pawn:IsEnemy() then
				local slow = -self.SlowEnemyAmount
				
				if (pawn:GetMoveSpeed() - self.SlowEnemyAmount) < self.MinEnemyMove then
					slow = self.MinEnemyMove - pawn:GetMoveSpeed()
				end 
				
				ret:AddScript([[Board:GetPawn(]]..pawn:GetId()..[[):AddMoveBonus(]]..slow..[[)]])
			end
		end
	end
	
	return ret
end