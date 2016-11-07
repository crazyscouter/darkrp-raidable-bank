if (CLIENT) then return; end

ndoc.table.rBank = ndoc.table.rBank or {}
ndoc.table.rBank.players = {}
ndoc.table.rBank.currency = ndoc.table.rBank.currency or bankConfig.initialMoney
ndoc.table.rBank.beingRobbed = 0
ndoc.table.rBank.inVault = 0

local inVault, beingRobbed = false, false

AddCSLuaFile("cl_bank.lua");
AddCSLuaFile("sh_bank.lua");
include("sh_bank.lua");

local meta = FindMetaTable("Player")

function meta:isBankGuard()
	return table.HasValue(bankConfig.bankGuards, self:Team()) or self:isCP()
end

function meta:giveGuardWeapons()
	if (self.hasGuardWeapons) then return end

	for k,v in pairs(bankConfig.bankGuardWeapons) do
		self:Give(v)
	end

	self.hasGuardWeapons = true
end

function meta:stripGuardWeapons()
	if (!self.hasGuardWeapons) then return end

	for k,v in pairs(bankConfig.bankGuardWeapons) do
		self:StripWeapon(v)
	end

	self.hasGuardWeapons = false
end

hook.Add("InitPostEntity", "StartBankStuff", function()
	
	timer.Create("bank_growthTimer", bankConfig.moneyGrowthTime, 0, function()
		local moneyCur = ndoc.table.rBank.currency + bankConfig.moneyGrowth //We can continue to update as long as it is still good.
		
		if (moneyCur > bankConfig.maxMoney) then return end
		
		ndoc.table.rBank.currency = moneyCur
		
	end)
end)

/* From Facepunch */
local function WithinAABB( Start, Stop, Point )
	local x = (Point.x > Stop.x and Point.x < Start.x ) or ( Point.x < Stop.x and Point.x > Start.x);
	local y = (Point.y > Stop.y and Point.y < Start.y ) or ( Point.y < Stop.y and Point.y > Start.y);
	local z = (Point.z > Stop.z and Point.z < Start.z ) or ( Point.z < Stop.z and Point.z > Start.z);

	return (x and y and z);
end

/*
	Returns: players in vault, players in bank, guards in bank
*/
local function getPlayersInBank()	
	local pos1 = bankConfig.bank[1];
	local pos2 = bankConfig.bank[2];
	local pos3 = bankConfig.vault[1];
	local pos4 = bankConfig.vault[2];

	local pInBank  = {}
	local pInVault = {}
	local guardsInBank = {}
	
	for k,v in pairs(player.GetAll()) do
		if (WithinAABB(pos3, pos4, v:GetPos())) then
			
			if (v:isBankGuard()) then
				table.insert(guardsInBank, v)
			else
				table.insert(pInVault, v)
			end

			if (ndoc.table.rBank.players[ v ] == nil) then
				ndoc.table.rBank.players[ v ] = v:isBankGuard() and 1 or 2
			end

			continue
		elseif (WithinAABB(pos1, pos2, v:GetPos())) then

			if (v:isBankGuard()) then
				table.insert(guardsInBank, v)
			else
				table.insert(pInBank, v)
			end

			if (ndoc.table.rBank.players[ v ] == nil) then
				ndoc.table.rBank.players[ v ] = v:isBankGuard() and 1 or 2
			end

			continue
		elseif (ndoc.table.rBank.players[ v ] ~= nil) then

			if (v:isBankGuard()) then
				v:stripGuardWeapons()
			end

			ndoc.table.rBank.players[ v] = nil
		end
	end
	
	return pInVault, pInBank, guardsInBank
end

local function doBreakInto()
	local robTime = bankConfig.robTime

	ndoc.table.rBank.robTime = robTime
	beingRobbed = true

	if (timer.Exists('bankTimeLeft')) then timer.Destroy('bankTimeLeft') end

	
	timer.Create('bankTimeLeft', 1, robTime + 1, function()
		if (ndoc.table.rBank.robTime == 0) then

			local inVault, inBank = getPlayersInBank()
			local combined = table.Merge(inVault, inBank)
			local money = ndoc.table.rBank.currency
			local moneyPP = money / #combined

			for k,v in pairs(combined) do
				v:addMoney(moneyPP)
			end

			ndoc.table.rBank.currency = bankConfig.initialMoney
		end
		
		ndoc.table.rBank.robTime = ndoc.table.rBank.robTime - 1
	end)
end

hook.Add("Think", "DetectPlayerInBank", function()
	local pInVault, pInBank, guardsInBank = getPlayersInBank()

	for k,v in pairs(guardsInBank) do
		v:giveGuardWeapons()
	end

	if (#pInVault > 0) then
		if (ndoc.table.rBank.currency < bankConfig.minMoney) then return end
		
		if (!inVault) then
			
			ndoc.table.rBank.inVault = 1
			inVault = true
			doBreakInto()

		end
		
	elseif (#pInBank > 0) then
		if (ndoc.table.rBank.currency < bankConfig.minMoney) then return end

		if (!beingRobbed) then

			beingRobbed = true
			ndoc.table.rBank.beingRobbed = 1

		end

	else
		if (inVault && #pInVault == 0) then
			inVault = false
			ndoc.table.rBank.inVault = 0
		end

		if (beingRobbed && #pInBank == 0) then
			beingRobbed = false
			ndoc.table.rBank.beingRobbed = 0
		end

		if (!beingRobbed && !inVault) then
			--DONE RAIDING
			timer.Destroy('bankTimeLeft')
		end
	end
end)