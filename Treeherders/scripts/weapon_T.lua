Eplanum_TH_Treevenge = Skill:new
{
	Class = "Prime",
	Icon = "weapons/prime_th_treevenge.png",
	Rarity = 1,
	
	Explosion = "",
	LaunchSound = "/weapons/titan_fist",
	
	Range = 1,
	PathSize = 1,
	Projectile = false,
    Damage = 2,
	
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 1, 2 },
	
    TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(3,2),
		Forest = Point(3,1),
		Fire = Point(3,1),
	},
	
	BouncePerDamage = 3,
	
	DoesSplashDamage = false,
	GenForestTarget = true,
	ForestsPerDamage = 1,
	DamageCap = 4,
	BuildingImmune = false,
}

Eplanum_TH_Treevenge_A = Eplanum_TH_Treevenge:new
{
	BuildingImmune = true,
}

Eplanum_TH_Treevenge_B = Eplanum_TH_Treevenge:new
{
	DoesSplashDamage = true,
}

Eplanum_TH_Treevenge_AB = Eplanum_TH_Treevenge_A:new
{
	DoesSplashDamage = true,
}

function Eplanum_TH_Treevenge:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	--determine the damage
	local damage = self.Damage + math.floor(forestUtils.arrayLength(forestUtils:getSpaces(forestUtils.isAForestFire)) / self.ForestsPerDamage)
	
	--cap it
	if damage > self.DamageCap then
		damage = self.DamageCap
	end
	
	--detemine the splash damage
	local splashDamage = 0
	if self.DoesSplashDamage then
		splashDamage = math.floor(damage / 2)
	end
	
	--do the main damage
	local currDamage = nil
	if self.GenForestTarget then
		currDamage = forestUtils:getFloraformSpaceDamage(p2, damage, nil, false, self.BuildingImmune)
	else
		currDamage = forestUtils:getSpaceDamageWithoutSettingFire(p2, damage, nil, false, self.BuildingImmune)
	end
	
	ret:AddDamage(currDamage)
	ret:AddBounce(p2, damage * self.BouncePerDamage)
	ret:AddDelay(0.2)
	
	--do the splash damage
	local attackDir = GetDirection(p2 - p1)
	for i = -1, 1 do
		local splashPoint = p2 + DIR_VECTORS[(attackDir + i) % 4]
	
		--in case we have building immune
		local currDamage = splashDamage
	
		--for some reason this won't work if i put (attackDir + i) % 4 in a variable and try to use that
		local splash = forestUtils:getSpaceDamageWithoutSettingFire(splashPoint, currDamage, (attackDir + i) % 4, false, self.BuildingImmune)
		splash.sAnimation = "airpush_"..((attackDir + i) % 4)
		if splashDamage > 0 then
			ret:AddBounce(splashPoint, splashDamage * self.BouncePerDamage)
		else
			--So that it doesn't display on the tiles
			splash.iDamage = 0
		end
		ret:AddDamage(splash) 
	end
	
	return ret
end