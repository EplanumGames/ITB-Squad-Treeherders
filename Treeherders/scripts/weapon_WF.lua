Eplanum_TH_Passive_WakeTheForest = PassiveSkill:new
{
	PowerCost = 1,
	Icon = "weapons/passives/passive_th_forestArmor.png",
	Upgrades = 2,
	UpgradeCost = {1, 2},
	
	Damage = 0,
	
	ForestArmor = true,
	ForestsToGen = 2,
	Evacuate = false,
	Revenge = false,
	SeekMech = false,
	
	TipImage = {
		Unit = Point(2, 1),
		CustomPawn = "Scorpion1",
		Enemy = Point(2, 2),
		Forest = Point(2, 2),
	}
}

Eplanum_TH_Passive_WakeTheForest_A = Eplanum_TH_Passive_WakeTheForest:new
{	
	TipImage = {
		Unit = Point(2, 1),
		CustomPawn = "Scorpion2",
		Enemy = Point(2, 2),
		Forest = Point(2, 2),
	},
	
	Evacuate = true,
}
Eplanum_TH_Passive_WakeTheForest_B = Eplanum_TH_Passive_WakeTheForest:new
{
	TipImage = {
		Unit = Point(2, 2),
		CustomPawn = "TH_ArbiformerMech",
		Forest = Point(2, 3),
	},
	
	SeekMech = true,
}

Eplanum_TH_Passive_WakeTheForest_AB = Eplanum_TH_Passive_WakeTheForest_A:new
{
	Evacuate = true,
	SeekMech = true,
}

------------------- UPGRADE PREVIEWS ---------------------------

--only a preview for passive skills
function Eplanum_TH_Passive_WakeTheForest:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	forestUtils:SetForestArmorIcon(Point(2, 2), false)
	
	local spaceDamage = SpaceDamage(Point(2, 2), DAMAGE_ZERO)
	spaceDamage.sAnimation = "SwipeClaw2"
	spaceDamage.sSound = "/enemy/scorpion_soldier_1/attack"
	ret:AddMelee(Point(2, 1), spaceDamage)
	return ret
end

--only a preview for passive skills
function Eplanum_TH_Passive_WakeTheForest_A:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	forestUtils:SetForestArmorIcon(Point(2, 2), true, 3)
	
	local spaceDamage = SpaceDamage(Point(2, 2), 2, 3)
	spaceDamage.sAnimation = "SwipeClaw2"
	spaceDamage.sSound = "/enemy/scorpion_soldier_2/attack"
	ret:AddMelee(Point(2, 1), spaceDamage)
	
	return ret
end

--only a preview for passive skills
--TODO Update
function Eplanum_TH_Passive_WakeTheForest_B:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	forestUtils:floraformSpace(ret, Point(2, 2))
	forestUtils:floraformSpace(ret, Point(1, 3))
	
	return ret
end

----------------------- TREEVENGE --------------------------------

function Eplanum_TH_Passive_WakeTheForest:ApplyRevenge()
	if self.Revenge then
		local spacesPushedTo = {}
		local enemyIds = Board:GetPawns(TEAM_ENEMY)
		for _, enemyId in pairs(extract_table(enemyIds)) do
			local enemy = Board:GetPawn(enemyId)
			local pushed = false
			for i, dir in pairs(DIR_VECTORS) do
				local enemySpace = enemy:GetSpace()
				local p = enemySpace + dir
				if (not pushed) and (not enemy:IsFire()) and forestUtils.isAForestFire(p) and 
							(not Board:IsPawnSpace(p)) and (not spacesPushedTo[forestUtils:getSpaceHash(p)]) then
							
					pushed = true
					local revengeEffect = SkillEffect()
					revengeEffect:AddDamage(SpaceDamage(enemySpace, DAMAGE_ZERO, i))		
					revengeEffect:AddBounce(p, forestUtils.floraformBounce)
					Board:AddEffect(revengeEffect)
					
					--keep track of what spaces have already been pushed to so we don't cause them to collide
					spacesPushedTo[forestUtils:getSpaceHash(p + DIR_VECTORS[i])] = p + DIR_VECTORS[i]
				end
			end
		end
	end
end

------------------- FLORAFORM SPACES ---------------------------

function Eplanum_TH_Passive_WakeTheForest:FloraformSpaces()
	
	local randId = "Eplanum_TH_Passive_WakeTheForest"..tostring(Pawn:GetId())
	
	local effect = SkillEffect()
	
	local candidates = forestUtils:getSpacesThatBorder(forestUtils.isAForest)
	
	--floraform and see if we floraformed enough
	local additionalNeeded = self.ForestsToGen - forestUtils.arrayLength(
				forestUtils:floraformNumOfRandomSpaces(effect, randId, candidates, self.ForestsToGen, DAMAGE_ZERO, nil, true, true, true, self.SeekMech))
	
	--If there are not enough spaces, do some random ones
	if additionalNeeded > 0 then
		--get all floraformable points to use as candidates
		local newCandidates = forestUtils:getSpaces(forestUtils.isSpaceFloraformable)
		
		local toRemove = {}
		--remove any points that are already forests or forest fires
		for k, v in pairs(newCandidates) do
			if forestUtils.isAForest(v) then
				table.insert(toRemove, k)
			end
		end

		--remove any of them that were in the old list
		for k, _ in pairs(candidates) do
			if newCandidates[k] then
				table.insert(toRemove, k)
			end
		end
		
		--do it in two loops to ensure the iterator isn't messed up by removing items mid iteration
		for _, v in pairs(toRemove) do
			newCandidates[v] = nil
		end
		
		--floraform the number left (or how ever many we can)
		forestUtils:floraformNumOfRandomSpaces(effect, randId, newCandidates, additionalNeeded, DAMAGE_ZERO, nil, true, true, true, self.SeekMech)
	end
	
	--add the effect to the board
	Board:AddEffect(effect)
end

------------------- FOREST ARMOR AND TREEVAC ---------------------------

function Eplanum_TH_Passive_WakeTheForest:ApplyForestArmorToSpaceDamage(spaceDamage)
	if self.ForestArmor then
		if spaceDamage.iDamage ~= DAMAGE_ZERO and spaceDamage.iDamage ~= DAMAGE_DEATH then
			if spaceDamage.iDamage ~= 1 then
				spaceDamage.iDamage = spaceDamage.iDamage - 1
			else
				spaceDamage.iDamage = DAMAGE_ZERO
			end
		end
	end
end

--TODO: prefer forests?
function Eplanum_TH_Passive_WakeTheForest:ApplyEvacuateToSpaceDamage(spaceDamage, damagedPawn, attackDir, isQueued, pToIgnore)
	--If the pawn is not on fire and on a forest and is taking damage
	if self.Evacuate and spaceDamage.iDamage > 0 and spaceDamage.iDamage ~= DAMAGE_ZERO and spaceDamage.iDamage ~= DAMAGE_DEATH and
					not (damagedPawn:IsShield() or damagedPawn:IsFire() or forestUtils.isAForestFire(spaceDamage.loc)) then
		local dirPreferences = { (attackDir - 1) % 4, (attackDir + 1) % 4, attackDir, (attackDir + 2) % 4 }
		for _, dir in pairs(dirPreferences) do
			--if we already found a spot then don't check
			if (not spaceDamage.iPush) or spaceDamage.iPush >= 4 then
				local p = spaceDamage.loc + DIR_VECTORS[dir]
				local terrain = Board:GetTerrain(p)
				
				--only push to it if we are not already pushing someone there
				if not pToIgnore[forestUtils:getSpaceHash(p)] then
					--If its a non blocking and non harmful terrain
					if terrain ~= TERRAIN_MOUNTAIN and terrain ~= TERRAIN_BUILDING and terrain ~= TERRAIN_ACID and terrain ~= TERRAIN_LAVA then
						--If its non harmful based on the units attributes
						if (terrain ~= TERRAIN_EMPTY or damagedPawn:IsFlying()) and (terrain ~= TERRAIN_WATER or damagedPawn.Massive) then
							--If its unocupied and not in danger
							if not (Board:IsPawnSpace(p) or Board:IsFire(p) or Board:IsAcid(p) or Board:IsSpawning(p) or Board:IsDangerous(p)) then
								--we found a good spot to push the pawn to
								spaceDamage.iPush = dir
								
								--if its a queued effect safe it off if its the first one so we can add the icon later
								if isQueued then
									forestUtils:AddQueuedEvacIfNotPresent(damagedPawn:GetId(), dir)
								end
								
								return p + DIR_VECTORS[dir]
							end
						end
					end
				end
			end
		end
	end
end

function Eplanum_TH_Passive_WakeTheForest:ApplyForestArmorAndEvacuate(effect, attackDir, isQueued)
	if (self.ForestArmor or self.Evacuate) and not effect:empty() then
		local evacuatedToOrAttackedSpaces = {}
		
		--determine what spaces are being attacked
		for _, spaceDamage in pairs(extract_table(effect)) do	
			evacuatedToOrAttackedSpaces[forestUtils:getSpaceHash(spaceDamage.loc)] = spaceDamage.loc
		end
		
		for _, spaceDamage in pairs(extract_table(effect)) do		
			local damagedPawn = Board:GetPawn(spaceDamage.loc)
			if damagedPawn and forestUtils.isAForest(spaceDamage.loc) and spaceDamage.iDamage > 0 and damagedPawn:IsMech() then
				self:ApplyForestArmorToSpaceDamage(spaceDamage)
				
				local p = self:ApplyEvacuateToSpaceDamage(spaceDamage, damagedPawn, attackDir, isQueued, evacuatedToOrAttackedSpaces)
				if p then
					evacuatedToOrAttackedSpaces[forestUtils:getSpaceHash(p)] = p
				end
			end	
		end
	end
end

------------------- MAIN HOOK FUNCTIONS ---------------------------

--function to handle the postEnvironment hook functionality
function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_PostEnvironmentHook(mission)
	--always re-evaluate the icons - this covers environment effects like floods
	forestUtils:RefreshForestArmorIconToAllMechs(self.Evacuate)
	
	--StartEffect will be true for the first time and env effect is called
	--EndEffect will be false for the last time and env effect is called
	--if this is not the last environment effect, return
	if mission.LiveEnvironment.EndEffect then	
		return
	end
	
	--Revenge skill effect
	self:ApplyRevenge()

	--floraform the spaces
	self:FloraformSpaces()
end

--TODO track which ones are built vs which are executed to store which way the mechs should be pushed. Check how cancelled attacks work with this
local prevMoveLocation = nil
function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_SkillBuildHook(mission, pawn, weaponId, p1, p2, skillFx)
	
	--Forest armor and treevac effects for both immediate and queued attacks
	local attackDir = GetDirection(p2 - p1)
	self:ApplyForestArmorAndEvacuate(skillFx.effect, attackDir, false)
	self:ApplyForestArmorAndEvacuate(skillFx.q_effect, attackDir, true)
		
	--If we have a previous move location, clear it
	if prevMoveLocation then
		forestUtils:UnsetTerrainIcon(prevMoveLocation)
	end
	
	--skill build hooks 
	if weaponId == "Move" then
		forestUtils:ClearQueuedEvacs()
		prevMoveLocation = p2
		
	--if its not a move, refresh all mechs armor
	else
		forestUtils:RefreshForestArmorIconToAllMechs(self.Evacuate)
	end
end

--Clear the queued pushes. They will be re-added by the skill build hooks. We need to do this each time
--a move is executed, or the position is undone or the pawn is deselected (preview move cancelled). This 
--will allow the table to be repopulated with the recalculated queued effects
function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_SkillEndHook(mission, pawn, weaponId, p1, p2)
	forestUtils:ClearQueuedEvacs()
end

function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_QueuedSkillEndHook(mission, pawn, weaponId, p1, p2)
	forestUtils:ClearQueuedEvacs()
end

function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_PawnUndoMoveHook(mission, pawn)
	forestUtils:ClearQueuedEvacs()
end

function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_PawnDeselectedHook(mission, pawn)
	forestUtils:ClearQueuedEvacs()
end

--Each time the pawn changes positions, we need to make sure to clear the old location
function Eplanum_TH_Passive_WakeTheForest:GetPassiveSkillEffect_PawnPositionChangedHook(mission, pawn, oldPos)
	forestUtils:UnsetTerrainIcon(oldPos)
end

passiveEffect:addPassiveEffect("Eplanum_TH_Passive_WakeTheForest", 
		{"skillBuildHook", "skillEndHook", "queuedSkillEndHook", "pawnPositionChangedHook", "pawnUndoMoveHook", "pawnDeselectedHook", "postEnvironmentHook"})
