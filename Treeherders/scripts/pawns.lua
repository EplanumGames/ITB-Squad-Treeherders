TH_EntborgMech = {
	Name = "Entborg",
	Class = "Prime",
	Health = 3,
	MoveSpeed = 4,
	Image = "Eplanum_TH_Entborg",
	ImageOffset = FURL_COLORS.TreeherderColors,
	SkillList = { "Eplanum_TH_Treevenge" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
AddPawn("TH_EntborgMech")

TH_ForestFirerMech = {
	Name = "Forest Firer",
	Class = "Ranged",
	Health = 3,
	MoveSpeed = 3,
	Image = "Eplanum_TH_ForestFirer",
	ImageOffset = FURL_COLORS.TreeherderColors,
	SkillList = { "Eplanum_TH_ForestFire" },
	SoundLocation = "/mech/distance/artillery/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
AddPawn("TH_ForestFirerMech")

TH_ArbiformerMech = {
	Name = "Arbiformer",
	Class = "Science",
	Health = 2,
	MoveSpeed = 3,
	Image = "Eplanum_TH_Floraformer",
	ImageOffset = FURL_COLORS.TreeherderColors,
	SkillList = { "Eplanum_TH_ViolentGrowth", "Eplanum_TH_Passive_WakeTheForest" },
	SoundLocation = "/mech/science/pulse_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true
}
AddPawn("TH_ArbiformerMech")
