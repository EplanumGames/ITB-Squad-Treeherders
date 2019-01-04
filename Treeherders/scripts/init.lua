Treeherders_ResourcePath = ""

local function init(self)	
    require(self.scriptPath.."FURL")(self, {
		{
			Type = "mech",
			Name = "Eplanum_TH_Entborg",
			Filename = "mech_th_entborg",
			Path = "img/units/player",
			ResourcePath = "units/player",

			Default =           { PosX = -17, PosY = -11 },
			Animated =          { PosX = -17, PosY = -11, NumFrames = 4 },
			Broken =            { PosX = -17, PosY = -9 },
			Submerged =         { PosX = -17, PosY = 2 },
			SubmergedBroken =   { PosX = -20, PosY = 4 },
			Icon =              {},
		},
	    {
			Type = "mech",
			Name = "Eplanum_TH_Floraformer",
			Filename = "mech_th_floraformer",
			Path = "img/units/player",
			ResourcePath = "units/player",

			Default =           { PosX = -22, PosY = -7 },
			Animated =          { PosX = -22, PosY = -7, NumFrames = 4 },
			Broken =            { PosX = -22, PosY = -6 },
			Submerged =         { PosX = -22, PosY = 2 },
			SubmergedBroken =   { PosX = -22, PosY = 5 },
			Icon =              {},
		},
		{
			Type = "mech",
			Name = "Eplanum_TH_ForestFirer",
			Filename = "mech_th_forestFirer",
			Path = "img/units/player",
			ResourcePath = "units/player",

			Default =           { PosX = -19, PosY = 5 },
			Animated =          { PosX = -19, PosY = 5, NumFrames = 4 },
			Broken =            { PosX = -19, PosY = 5 },
			Submerged =         { PosX = -19, PosY = 10 },
			SubmergedBroken =   { PosX = -19, PosY = 10 },
			Icon =              {},
		},
		{
				Type = "color",
				Name = "TreeherderColors",
				PawnLocation = self.scriptPath.."pawns",
			
				PlateHighlight = {144, 244, 255},
				PlateLight = {120, 151, 75},
				PlateMid = {77, 99, 56},
				PlateDark = {43, 58, 28},
				PlateOutline = {28, 21, 14},
				PlateShadow = {53, 35, 19},
				BodyColor = {102, 68, 40},
				BodyHighlight = {163, 112, 71},
		},
		{
			Type = "base",
			Filename = "prime_th_treevenge",
			Path = "img/weapons",
			ResourcePath = "weapons",
		},
		{
			Type = "base",
			Filename = "ranged_th_forestFirer",
			Path = "img/weapons",
			ResourcePath = "weapons",
		},
		{
			Type = "base",
			Filename = "science_th_violentGrowth",
			Path = "img/weapons",
			ResourcePath = "weapons",
		},
		{
			Type = "base",
			Filename = "passive_th_forestArmor",
			Path = "img/weapons/passives",
			ResourcePath = "weapons/passives",
		},
	});
	
	Treeherders_ResourcePath = self.resourcePath
	require(self.scriptPath.."images")

	--Appears we have to load mod api after the images or else they work sporadically
	treeherders_modApiExt = require(self.scriptPath.."modApiExt/modApiExt"):init()
	
	require(self.scriptPath.."predictableRandom")
	require(self.scriptPath.."passiveEffect")
	require(self.scriptPath.."forestUtils")
	require(self.scriptPath.."pawns")
	
	require(self.scriptPath.."weapon_T")
	require(self.scriptPath.."weapon_VG")
	require(self.scriptPath.."weapon_FF")
	require(self.scriptPath.."weapon_WF")
	
	modApi:addWeapon_Texts(require(self.scriptPath.."weapon_texts"))
end

local function load(self, options, version)
	treeherders_modApiExt:load(self, options, version)
	
	modApi:addSquadTrue(
		{"Treeherders", "TH_EntborgMech", "TH_ForestFirerMech", "TH_ArbiformerMech"}, "Treeherders", 
		"One with the forests, these mechs harness natures power to defend earth from the vek onslaught", 
		self.resourcePath.."img/squad.png")
	
	--todo remove when pulled into modUtils
	predictableRandom:registerAutoRollHook()
	passiveEffect:addHooks()
	passiveEffect:autoSetWeaponsPassiveFields()
end

return {
    id = "eplanum_treeherders",
    name = "Tree Herders",
    version = "0.9.0",
	requirements = { "kf_ModUtils" },
	icon = "img/mod_icon.png",
    init = init,
    load = load
}
