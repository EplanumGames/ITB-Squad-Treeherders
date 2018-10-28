Eplanum_TH_ForestFire = ArtilleryDefault:new
{
    Class = "Ranged",
    Icon = "weapons/ranged_th_forestFirer.png",
	UpShot = "effects/shotup_th_deadtree.png",
	UpShotMain = "effects/shotup_th_deadtree.png",
	Rarity = 1,
	
	Damage = 1,
	
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 1, 3 },
	
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Building = Point(3,1),
		Forest = Point(3,3),
		Forest2 = Point(2,4),
	},
	
	MainBounce = forestUtils.floraformBounce,
	SplashBounce = 2,
	ProjDelay = PROJ_DELAY,
	AnimSpacingDelay = 0.01,
	
	AdaptiveRecoilFlora = false,
	AddDamage = 0,
	PushAll = true,
	AllyImmune = false,
	BuildingImmune = false,
	
	MainImmune = false,
	SideImmune = false,
}

Eplanum_TH_ForestFire_A = Eplanum_TH_ForestFire:new
{
	AllyImmune = true,
	BuildingImmune = true,
	SideImmune = true,
}

Eplanum_TH_ForestFire_B = Eplanum_TH_ForestFire:new
{
	UpShotMain = "effects/shotup_th_deadtree_3.png",
	AddDamage = 2,
	MainBounce = 6,
}

Eplanum_TH_ForestFire_AB = Eplanum_TH_ForestFire_A:new
{
	UpShotMain = "effects/shotup_th_deadtree_3.png",
	AddDamage = 2,
	MainBounce = 6,
}

function Eplanum_TH_ForestFire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--determine what forests are around us and mirror them
	local forwardDir = GetDirection(p2 - p1)
	local sideDir1 = (forwardDir + 1) % 4
	local backDir = (forwardDir + 2) % 4
	local sideDir2 = (forwardDir + 3) % 4
	
	local forwardVect = DIR_VECTORS[forwardDir]
	local sideVect1 = DIR_VECTORS[sideDir1]
	local backVect = DIR_VECTORS[backDir]
	local sideVect2 = DIR_VECTORS[sideDir2]
	
	local pBack =  p1 + backVect

	--floraform space around the mech
	if self.AdaptiveRecoilFlora then
		local surrounding = { p1 + forwardVect, p1 + sideVect1, p1 + backVect, p1 + sideVect2 }
		local looking = true
		for _, p in pairs(surrounding) do
			if looking and Board:IsValid(p) and forestUtils.isSpaceFloraformable(p) then
				forestUtils:floraformSpace(ret, p)
				looking = false
			end
		end
	else
		if Board:IsValid(pBack) and forestUtils.isSpaceFloraformable(pBack) then
			forestUtils:floraformSpace(ret, pBack)
		end
	end
	
	local attackDirs = {}
	if forestUtils.isAForest(pBack) then
		table.insert(attackDirs, forwardDir)
	end
	
	table.insert(attackDirs, "target")
	
	if forestUtils.isAForest(p1 + sideVect1) then
		table.insert(attackDirs, sideDir1)
	end
	if forestUtils.isAForest(p1 + sideVect2) then
		table.insert(attackDirs, sideDir2)
	end
	
	if forestUtils.isAForest(p1 + forwardVect) then
		table.insert(attackDirs, backDir)
	end
	
	--for each forest around us, damage it, potentially pushing if the upgrade is set
	--stagger a little from farthest to closest to help potray the effect correctly
	local mainBounce = true
	local splashBounces = {}
	for _, dir in pairs(attackDirs) do
		local isTarget = (dir == "target")
		local spaceDamage = nil
		local projImg = self.UpShot
		
		if isTarget then
			projImg = self.UpShotMain
			
			ret:AddDelay(self.AnimSpacingDelay)
			spaceDamage = forestUtils:getFloraformSpaceDamage(p2, self.Damage + self.AddDamage, forwardDir, self.MainImmune and self.AllyImmune, self.MainImmune and self.BuildingImmune)
		else
			local splashP = p2 + DIR_VECTORS[dir]
			if self.BuildingImmune and Board:IsBuilding(splashP) then
				projImg = ""
			else
				table.insert(splashBounces, splashP)
			end
			
			local pushDir = nil
			if self.PushAll then
				pushDir = dir
			end
			
			spaceDamage = forestUtils:getSpaceDamageWithoutSettingFire(splashP, self.Damage, pushDir, self.SideImmune and self.AllyImmune, self.SideImmune and self.BuildingImmune)
		end
		
		ret:AddArtillery(spaceDamage, projImg, NO_DELAY)
	end
	
	--add a delay while the projectiles are firing
	ret:AddDelay(self.ProjDelay)
	
	--add the damage bounces as appropriate
	if doMainBounce then
		ret:AddBounce(p2, self.MainBounce)
	end
		
	for _, p in pairs(splashBounces) do
		ret:AddBounce(p, self.SplashBounce)
	end
	
	return ret
end