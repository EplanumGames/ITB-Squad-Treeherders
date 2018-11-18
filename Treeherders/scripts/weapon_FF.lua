Eplanum_TH_ForestFire = ArtilleryDefault:new
{
    Class = "Ranged",
    Icon = "weapons/ranged_th_forestFirer.png",
	LaunchSound = "/weapons/artillery_volley",
	ImpactSound = "/impact/generic/explosion",
	UpShot = "effects/shotup_th_deadtree.png",
	OuterAnimation = "airpush_",
	Rarity = 1,
	
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
	
	ArtilleryStart = 2,
	ArtillerySize = 4,
	
	Damage = 1,
	DamageOuter = 1,
	BuildingDamage = true,
	BounceAmount = forestUtils.floraformBounce,
	BounceOuterAmount = 2,
	
	AdaptiveRecoilFlora = false,
}

Eplanum_TH_ForestFire_A = Eplanum_TH_ForestFire:new
{
	BuildingDamage = false,
}

--TODO make increase based on adjacent?
Eplanum_TH_ForestFire_B = Eplanum_TH_ForestFire:new
{
	UpShot = "effects/shotup_th_deadtree_3.png",
	Damage = 3,
	DamageOuter = 1,
}

Eplanum_TH_ForestFire_AB = Eplanum_TH_ForestFire_B:new
{
	BuildingDamage = false,
}

function Eplanum_TH_ForestFire:GetTargetArea(point)
	--Get all spaces in the grouping
	local forestGroup = forestUtils:getGroupingOfSpaces(point, forestUtils.isAForest)
	
	local ret = PointList()
	--cant attack next to us
	local points = {}
	points[forestUtils:getSpaceHash(point)] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[0])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[1])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[2])] = 0
	points[forestUtils:getSpaceHash(point + DIR_VECTORS[3])] = 0
		
	for k, v in pairs(forestGroup.group) do
		for dir = 0, 3 do
			for i = self.ArtilleryStart, self.ArtillerySize do
				local curr = Point(v + DIR_VECTORS[dir] * i)
				if not Board:IsValid(curr) then
					break
				end
				
				if not points[forestUtils:getSpaceHash(curr)] then
					points[forestUtils:getSpaceHash(curr)] = 0
					ret:push_back(curr)
				end
			end
		end
	end
	
	return ret
end

function Eplanum_TH_ForestFire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	
	--floraform space around the mech
	local pBack = p1 + DIR_VECTORS[(attackDir + 2) % 4]
	if Board:IsValid(pBack) and forestUtils.isSpaceFloraformable(pBack) then
		forestUtils:floraformSpace(ret, pBack)
	end

	local damage = forestUtils:getFloraformSpaceDamage(p2, self.Damage, nil, false, not self.BuildingDamage)
	if (not self.BuildingDamage) and Board:IsBuilding(p2) then
		damage.iDamage = DAMAGE_ZERO
	end
	
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, 1)
	
	for dir = 0, 3 do
		local currP = p2 + DIR_VECTORS[dir]
		local sideDamage = forestUtils:getSpaceDamageWithoutSettingFire(currP, self.DamageOuter, dir, false, not self.BuildingDamage)
		sideDamage.sAnimation = self.OuterAnimation..dir
		
		if (not self.BuildingDamage) and Board:IsBuilding(currP) then	
			sideDamage.iDamage = 0
		end
		
		ret:AddDamage(sideDamage)
		if self.BounceOuterAmount ~= 0 then	
			ret:AddBounce(currP, self.BounceOuterAmount) 
		end  
	end
	
	return ret
end