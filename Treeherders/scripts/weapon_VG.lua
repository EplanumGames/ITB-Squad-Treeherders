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

local function gameExistsAndEnsureGameVarsSetUp()
	if not GAME then
		return false
	end
	
	if not GAME.Eplanum_TH_ViolentGrowth then
		GAME.Eplanum_TH_ViolentGrowth = {}
		GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed = {}
	elseif not GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed then
		GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed = {}
	end
	return true
end
			
function Eplanum_TH_ViolentGrowth:GetSkillEffect(p1, p2)
	local randId = "Eplanum_TH_ViolentGrowth"..tostring(Pawn:GetId())

	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	
	--generate forest on target and damage it
	local pushDir = nil
	if self.PushTarget then
		pushDir = attackDir
	end
	
	--if it is a forest, cancel the target's attack
	if forestUtils.isAForest(p2) then
		forestUtils:cancelAttack(p2, ret)
		ret:AddBounce(p2, self.NonForestBounce)
		
	--otherwise if it can be floraformed, do so
	elseif forestUtils.isSpaceFloraformable(p2) then
		forestUtils:floraformSpace(ret, p2, self.Damage, pushDir, false, true)
	end
	
	--small break to make the animation and move make more sense
	ret:AddDelay(0.4)
	
	--Get all spaces in the grouping
	local forestGroup = forestUtils:getGroupingOfSpaces(p2, forestUtils.isAForest)
	--ensure the space we just formed is not in the boarding list - it will be in the group list
	forestGroup.boardering[forestUtils:getSpaceHash(p2)] = nil
	
	--pick tiles to expand to and damage if appropriate
	local newForests = forestUtils:floraformNumOfRandomSpaces(ret, randId, forestGroup.boardering, self.ForestToExpand,
								self.Damage, nil, true, true, true, nil, self.SeekVek, forestUtils:getSpaceHash(p1) + (forestUtils:getSpaceHash(p2) * 100))
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
	
	--any enemy in the forest, slow down temporarily if the powerup is enabled
	if self.SlowEnemy and gameExistsAndEnsureGameVarsSetUp() then
		for _, v in pairs(forestGroup.group) do
			local enemy = Board:GetPawn(v)
			if enemy and enemy:IsEnemy() and enemy:GetMoveSpeed() > self.SlowEnemyMaxMove then
				--TODO AddMoveBonus --try this
				GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed[v] = enemy:GetMoveSpeed()
				ret:AddScript([[Board:GetPawn(]]..enemy:GetId()..[[):SetMoveSpeed(]]..self.SlowEnemyMaxMove..[[)]])
			end
		end
	end
	
	return ret
end

--ensure we start the mission with none slowed
function Eplanum_TH_ViolentGrowth:GetPassiveSkillEffect_MissionStartHook()
	if gameExistsAndEnsureGameVarsSetUp() then
		GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed = {}
	end
end

--undoes any temporarily speed modification of vek
function Eplanum_TH_ViolentGrowth:GetPassiveSkillEffect_NextTurnHook()
	if Game:GetTeamTurn() == TEAM_PLAYER and gameExistsAndEnsureGameVarsSetUp() then
		for k, v in pairs(GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed) do
			Board:GetPawn(k):SetMoveSpeed(v)
		end
		GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed = {}
	end
end

--applies any temporarily speed modification to vek
function Eplanum_TH_ViolentGrowth:GetPassiveSkillEffect_PostLoadGameHook()
	if gameExistsAndEnsureGameVarsSetUp() then
		for k, v in pairs(GAME.Eplanum_TH_ViolentGrowth.SlowedPawnsOrigSpeed) do
			Board:GetPawn(k):SetMoveSpeed(self.SlowEnemyMaxMove)
		end
	end
end

--True means its not passive only weapon
passiveEffect:addPassiveEffect("Eplanum_TH_ViolentGrowth", {"nextTurnHook", "postLoadGameHook", "missionStartHook"}, true)