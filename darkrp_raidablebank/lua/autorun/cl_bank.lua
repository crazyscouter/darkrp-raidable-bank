include("sh_bank.lua")

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

end

hook.Add("HUDPaint", "ShowBankStuffWhileRobbing", function()
	if (not hooksAdded) then
		addndocHooks()

		hooksAdded = true
	end

	local lp = LocalPlayer()
	local tab = ndoc.table.rBank.players[ lp ]

	local isGuard = tab == 1
	local isRaiding = tab == 2

	local progress = currency / maxMoney
	local xpos = (!inVault) and (ScrW() / 2) - 100 or (ScrW() / 2) - 135
	local greenDepth = (progress) * 108
	local bgCol = Color(33, greenDepth, 42)

	local robTimeLeft = ndoc.table.rBank.robTime
	if (robTimeLeft < 0) then robTimeLeft = 0 end

	local barWidth = progress * 200
	local robProgress = robTimeLeft / robTime

	if (beingRaided) then	
		bgCol = math.Round(CurTime() % 2) == 0 and Color(179, 27, 27) or Color(33, greenDepth, 42)
	end
	
	if (isGuard or isRaiding) then
		draw.RoundedBox(0, xpos, 0, 200, 30, Color(0, 0, 0))
		draw.RoundedBox(0, xpos, 0, barWidth, 30, bgCol)
		draw.SimpleText('Vault: $'..string.Comma(currency), 'DermaLarge', xpos + 84, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if (inVault) then
		surface.SetFont('DermaLarge')
		local w, h = surface.GetTextSize(robTimeLeft)

		draw.RoundedBox(0, xpos + 200, 0, 35, 30, Color(0, 0, 0))
		draw.RoundedBox(0, xpos + 200, 0, 35, robProgress * 30, Color(60, 60, 60))
		draw.SimpleText(robTimeLeft, 'DermaLarge', xpos + 216, 15 , Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
