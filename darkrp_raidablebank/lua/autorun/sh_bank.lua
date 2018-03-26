bankConfig = {};


bankConfig.bank = {
	Vector( -779.466736, 1220.188843, -200.307022), 
	Vector(-1155.516113, 1353.531982, -52.040535)
}												// Where is the bank located.
bankConfig.vault = {
	Vector(-1154.817139, 1401.917480, -25.699097), 
	Vector(-1372.119385, 1135.647217, -200.667740)
}

bankConfig.bannerPos = Vector(-1100.998901, 958.953064, -50.336380)
bankConfig.bannerAngle = Angle(0, 0, 90)

bankConfig.bankGuards = {TEAM_POLICE, TEAM_MAYOR}

bankConfig.bankGuardWeapons = {"weapon_ar2"};	// What weapons do bank security get.
bankConfig.initialMoney = 1000					// How much money does the bank start out with.
bankConfig.moneyGrowth = 200					// How much money does the bank get every interval of time.
bankConfig.moneyGrowthTime = 4					// How long does it take for the bank to increase its worth. --Should be in seconds!
bankConfig.robTime = 120
bankConfig.maxMoney = 20000						//How high should the vault's storage go
bankConfig.minMoney = 2000						//Min money required for raiding

bankConfig.restrictedTeams = {
	TEAM_ADMIN,
}

-- Don't include models/ or .mdl
-- {Path, Offest, Angle, Scale}
bankConfig.masks = {
	{"rinfect/payday/PAYDAY_AME", Vector(-3, 0, -67), Angle(0, 90, 0), 1},
	{"rinfect/payday/PAYDAY_DINO", Vector(-2, 0, -65), Angle(0, 90, 0), 1},
	{"rinfect/payday/PAYDAY_GAS", Vector(-2, 0, -67), Angle(0, 90, 0), 1}
}