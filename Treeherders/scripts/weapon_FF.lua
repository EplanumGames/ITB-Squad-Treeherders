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
    UpgradeCost = { 2, 2 },
	
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Building = Point(3,1),
		Forest = Point(3,3),
		Forest2 = Point(2,4),
	},
	
	ArtilleryStart = 2,
	ArtillerySize = 8,
	
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

--make increase based on adjacent?
Eplanum_TH_ForestFire_B = Eplanum_TH_ForestFire:new
{
	UpShot = "effects/shotup_th_deadtree_3.png",
	Damage = 2,
	BounceAmount = forestUtils.floraformBounce * 2,
}

Eplanum_TH_ForestFire_AB = Eplanum_TH_ForestFire_B:new
{
	BuildingDamage = false,
}

function Eplanum_TH_ForestFire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local attackDir = GetDirection(p2 - p1)
	local adjForestCount = forestUtils:getNumForestsInPlus(p2)

	local additionalMain = 0
	local outerDirs = {}
	if adjForestCount > 0 then
		table.insert(outerDirs, (attackDir + 2) % 4)
		
		if adjForestCount > 1 then
			table.insert(outerDirs, attackDir % 4)
			table.insert(outerDirs, (attackDir + 1) % 4)
			table.insert(outerDirs, (attackDir + 3) % 4)
			
			--TODO keep?
			if adjForestCount > 2 then
				additionalMain = (adjForestCount - 1) / 2
			end
		end
	end
	
	--floraform space around the mech
	local pBack = p1 + DIR_VECTORS[(attackDir + 2) % 4]
	if Board:IsValid(pBack) and forestUtils.isSpaceFloraformable(pBack) then
		forestUtils:floraformSpace(ret, pBack)
	end

	local damage = SpaceDamage(p2, self.DamageCenter)
	if not self.BuildingDamage and Board:IsBuilding(p2) then
		damage.iDamage = DAMAGE_ZERO
	end
	
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, 1)
	
	for _, dir in pairs(outerDirs) do
		local currP = p2 + DIR_VECTORS[dir]
		damage = SpaceDamage(currP,  self.DamageOuter)
		damage.sAnimation = self.OuterAnimation..dir
		
		if not self.BuildingDamage and Board:IsBuilding(currP) then	
			damage.iDamage = 0
		end
		
		ret:AddDamage(damage)
		if self.BounceOuterAmount ~= 0 then	
			ret:AddBounce(currP, self.BounceOuterAmount) 
		end  
	end
	
	return ret
end