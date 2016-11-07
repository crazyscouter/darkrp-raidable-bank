bankConfig = {};

bankConfig.bank = {
	Vector( -3024.888428, -3327.741211, 0.263596), 
	Vector(-4235.753906, -3577.024902, 332.977539)
};												// Where is the bank located.
bankConfig.vault = {
	Vector(-4235.753906, -3577.024902, 332.977539), 
	Vector(-3717.154541, -4346.132324, 18.334160)
}

bankConfig.bannerPos = Vector(-2816, -2930, 250.183456)
bankConfig.bannerAngle = Angle(0, 135, 90)

bankConfig.bankGuards = {TEAM_POLICE, TEAM_MAYOR}

bankConfig.bankGuardWeapons = {"weapon_ar2"};	// What weapons do bank security get.
bankConfig.initialMoney = 1000;						// How much money does the bank start out with.
bankConfig.moneyGrowth = 200;						// How much money does the bank get every interval of time.
bankConfig.moneyGrowthTime = 4;					// How long does it take for the bank to increase its worth. --Should be in seconds!
bankConfig.robTime = 10;
bankConfig.maxMoney = 20000;					//How high should the vault's storage go
bankConfig.minMoney = 2000;						//Min money required for raiding