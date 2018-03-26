include("sh_bank.lua");

local maxMoney = bankConfig.maxMoney

hook.Add("PostDrawOpaqueRenderables", "ShowBankAmt", function()
	if (not ndoc.table.rBank) then return end

	local bankAmt = ndoc.table.rBank.currency
	if (not bankAmt) then return end

	local progress = (bankAmt / maxMoney)

	local bPos, bAng = bankConfig.bannerPos, bankConfig.bannerAngle

	local text = "Vault: $" .. string.Comma(bankAmt)
	surface.SetFont("DermaLarge")
	local textW, textH = surface.GetTextSize(text)
	local textW = textW + 10
	local textH = textH + 10

	local textPosX = textW / 2
	local textPosY = textH / 2

	local greenDepth = progress * 108
	local color = Color(33, greenDepth, 42)

	local isBeingRobbed = ndoc.table.rBank.beingRobbed
	
	if (isBeingRobbed == 1) then
		color = math.Round(CurTime() % 2) == 0 and Color(179, 27, 27) or Color(33, greenDepth, 42)
	end

	cam.Start3D2D(bPos, bAng, 1)
		draw.RoundedBox(0, 0, 0, textW, textH, Color(0, 0, 0))
		draw.RoundedBox(0, 0, 0, progress * textW, textH, color)
   		draw.SimpleText(text, "DermaLarge", textPosX, textPosY, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end)

local hooksAdded = false
local currency = 0
local beingRaided = false
local inVault = false
local robTime = bankConfig.robTime
local robbers = {}

bankConfig.masks = {
	{"rinfect/payday/PAYDAY_AME", Vector(0, 0, 0), Angle(0, 0, 0), 1},
	{"rinfect/payday/PAYDAY_DINO", Vector(0, 0, 0), Angle(0, 0, 0), 1},
	{"rinfect/payday/PAYDAY_GAS", Vector(0, 0, 0), Angle(0, 0, 0), 1}
}
/* Type in bank: 1 = a guard, 2 = a raider */
local function addndocHooks()
	ndoc.observe(ndoc.table, 'rBank.currency', function(money)
		currency = money
	end, ndoc.compilePath('rBank.currency'))

	ndoc.observe(ndoc.table, 'rBank.beingRaided', function(status)
		beingRaided = (status == 1)
	end, ndoc.compilePath('rBank.beingRobbed'))

	ndoc.observe(ndoc.table, 'rBank.inVault', function(status)
		inVault = (status == 1)
	end, ndoc.compilePath('rBank.inVault'))

	ndoc.observe(ndoc.table, 'rBank.players.?', function(pl, status)
		if (status == 2 or status == nil) then
			robbers[pl] = status

			if (status and #pl:catEquipped("Hats") == 0 and not pl.raidHat) then
				local hatInfo = bankConfig.masks[math.random(1, #bankConfig.masks)]
				pl.raidHat = ClientsideModel("models/" ..hatInfo[1].. ".mdl", RENDER_GROUP_OPAQUE_ENTITY)
				pl.raidHat:SetModelScale(hatInfo[4], 0)

				local v, a = LocalToWorld(hatInfo[2], hatInfo[3], pl:GetPos(), pl:GetAngles())
				pl.raidHat:SetPos(v)
				pl.raidHat:SetAngles(a)
				pl.raidHat:SetParent(pl, pl:LookupAttachment("eyes"))

				hook.Add("Think", "ViewEntityRaid"..pl:SteamID(), function()
					if GetViewEntity() == pl and pl == LocalPlayer() then
		               pl.raidHat:SetNoDraw(true)
		            else
		                pl.raidHat:SetNoDraw(false)
		            end
				end)
			elseif (status == nil and pl.raidHat) then
				hook.Remove("Think", "ViewEntityRaid"..pl:SteamID())

				if (IsValid(pl.raidHat)) then
					pl.raidHat:Remove()
				end

				pl.raidHat = nil
			end
			
		end
	end, ndoc.compilePath('rBank.players.?'))
end

hook.Add("HUDPaint", "ShowBankStuffWhileRobbing", function()
	if (not hooksAdded) then
		addndocHooks()

		hooksAdded = true
	end

	if (!ndoc.table.rBank or !ndoc.table.rBank.players) then return end

	local lp = LocalPlayer()
	local tab = ndoc.table.rBank.players[ lp ]

	local isGuard = tab == 1
	local isRaiding = tab == 2

	local progress = currency / maxMoney
	local greenDepth = (progress) * 108
	local bgCol = Color(33, greenDepth, 42)

	local robTimeLeft = ndoc.table.rBank.robTime or 0
	if (robTimeLeft < 0) then robTimeLeft = 0 end

	local barWidth = progress * 200
	local robProgress = robTimeLeft / robTime

	if (beingRaided or inVault) then	
		bgCol = math.Round(CurTime() % 2) == 0 and Color(179, 27, 27) or Color(33, greenDepth, 42)
	end

	surface.SetFont("DermaLarge")
	local text = "Vault: $" .. string.Comma(currency)
	local textW, textH = surface.GetTextSize(text)
	
	local xpos = inVault and (ScrW() / 2) - (textW + 10) / 2 - 17 or ScrW() / 2 - (textW + 10) / 2

	if (isGuard or isRaiding) then
		draw.RoundedBox(0, xpos, 0, textW + 10, 30, Color(0, 0, 0))
		draw.RoundedBox(0, xpos, 0, progress * (textW + 5), 30, bgCol)
		draw.SimpleText(text, 'DermaLarge', xpos + textW / 2 + 5, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if (isRaiding and inVault) then
		if (robTimeLeft > 60) then
			robTimeLeft = (math.Round(robTimeLeft / 60) ).. 'm'
		end

		local pCount = table.Count(robbers)
		local takeText = "Take: $"..string.Comma(math.Round(currency / pCount))
		local takeW = surface.GetTextSize(takeText)

		draw.RoundedBox(0, ScrW() / 2 - (takeW + 5) / 2 , 30, (takeW + 10), 30, Color(0, 0, 0))
		draw.SimpleText(takeText, "DermaLarge", ScrW() / 2 + 2, 45, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.RoundedBox(0, xpos + textW + 10, 0, 40, 30, Color(0, 0, 0))
		draw.RoundedBox(0, xpos + textW + 10, 0, 40, robProgress * 30, Color(60, 60, 60))
		draw.SimpleText(robTimeLeft, 'DermaLarge', xpos + textW + 30, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end)
