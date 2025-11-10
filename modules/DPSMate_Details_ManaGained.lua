-- Global Variables
DPSMate.Modules.DetailsManaGained = {}

-- Local variables
local DetailsArr, DetailsTotal, ManaArr, DetailsUser, DetailsSelected  = {}, 0, {}, "", 1
local DetailsArrComp, DetailsTotalComp, ManaArrComp, DetailsUserComp, DetailsSelectedComp  = {}, 0, {}, "", 1

local g          -- main pie graph
local gComp      -- compare pie graph (optional)
local curKey = 1
local db, cbt = {}, 0

local _G        = getglobal
local tinsert   = table.insert
local strformat = string.format

----------------------------------------------------
-- MAIN DETAILS
----------------------------------------------------
function DPSMate.Modules.DetailsManaGained:UpdateDetails(obj, key)
	curKey = key
	db, cbt = DPSMate:GetMode(key)
	DetailsUser = obj.user
	DetailsUserComp = nil

	if DPSMate_Details_ManaGained_Title then
		DPSMate_Details_ManaGained_Title:SetText("Mana gained by "..obj.user)
	end

	DetailsArr, DetailsTotal, ManaArr = DPSMate.Modules.ManaGained:EvalTable(DPSMateUser[DetailsUser], curKey)

	if DPSMate_Details_ManaGained then
		DPSMate_Details_ManaGained:Show()
	end

	self:ScrollFrame_Update()
	self:SelectDetailsButton(1)

	if not g and DPSMate_Details_ManaGained_Diagram then
		g = DPSMate.Options.graph:CreateGraphPieChart(
			"ManaGainedPieChart",
			DPSMate_Details_ManaGained_Diagram,
			"CENTER", "CENTER",
			0, 0, 200, 200
		)
	end

	if g then
		self:UpdatePieGraph(g)
	end
end

----------------------------------------------------
-- COMPARE WINDOW (SIMPLE)
----------------------------------------------------
function DPSMate.Modules.DetailsManaGained:UpdateCompare(obj, key, comp)
	-- 'comp' here is actually the compared user name
	self:UpdateDetails(obj, key)

	DetailsUserComp = comp
	if DPSMate_Details_CompareManaGained_Title then
		DPSMate_Details_CompareManaGained_Title:SetText("Mana gained by "..comp)
	end

	DetailsArrComp, DetailsTotalComp, ManaArrComp =
		DPSMate.Modules.ManaGained:EvalTable(DPSMateUser[DetailsUserComp], curKey)

	if not gComp and DPSMate_Details_CompareManaGained_Diagram then
		gComp = DPSMate.Options.graph:CreateGraphPieChart(
			"ManaGainedPieChartComp",
			DPSMate_Details_CompareManaGained_Diagram,
			"CENTER", "CENTER",
			0, 0, 200, 200
		)
	end

	if gComp then
		self:UpdatePieGraph(gComp, true)
	end

	if DPSMate_Details_CompareManaGained then
		DPSMate_Details_CompareManaGained:Show()
	end
	if DPSMate_Details_CompareManaGained_Graph then
		DPSMate_Details_CompareManaGained_Graph:Show()
	end
end

----------------------------------------------------
-- SCROLL FRAME: list of abilities + mana %
----------------------------------------------------
function DPSMate.Modules.DetailsManaGained:ScrollFrame_Update()
	if not DPSMate_Details_ManaGained_Log_ScrollFrame then
		return
	end

	local obj = DPSMate_Details_ManaGained_Log_ScrollFrame
	local len = DPSMate:TableLength(DetailsArr)
	FauxScrollFrame_Update(obj, len, 10, 24)

	for line = 1, 10 do
		local lineplusoffset = line + (FauxScrollFrame_GetOffset(obj) or 0)
		local btn   = _G("DPSMate_Details_ManaGained_Log_ScrollButton"..line)
		local nameF = _G("DPSMate_Details_ManaGained_Log_ScrollButton"..line.."_Name")
		local valF  = _G("DPSMate_Details_ManaGained_Log_ScrollButton"..line.."_Value")
		local iconF = _G("DPSMate_Details_ManaGained_Log_ScrollButton"..line.."_Icon")

		if DetailsArr[lineplusoffset] ~= nil then
			local ability = DPSMate:GetAbilityById(DetailsArr[lineplusoffset])

			if nameF then nameF:SetText(ability or "Unknown") end
			if valF and DetailsTotal > 0 then
				local value = ManaArr[lineplusoffset] or 0
				valF:SetText(value.." ("..strformat("%.2f", (value * 100 / DetailsTotal)).."%)")
			end
			if iconF and ability then
				iconF:SetTexture(DPSMate.BabbleSpell:GetSpellIcon(ability))
			end
			if btn then btn:Show() end
		else
			if btn then btn:Hide() end
		end
	end
end

----------------------------------------------------
-- PIE GRAPH
----------------------------------------------------
function DPSMate.Modules.DetailsManaGained:UpdatePieGraph(gg, isCompare)
	if not gg then return end

	local uArr, mArr, tTot = DetailsArr, ManaArr, DetailsTotal
	if isCompare then
		uArr, mArr, tTot = DetailsArrComp, ManaArrComp, DetailsTotalComp
	end

	if not uArr or not mArr or tTot == 0 then
		return
	end

	local pieData = {}
	for i, abilityId in ipairs(uArr) do
		local ability = DPSMate:GetAbilityById(abilityId)
		local value   = mArr[i] or 0
		if ability and value > 0 then
			tinsert(pieData, {ability, value})
		end
	end

	if table.getn(pieData) == 0 then
		return
	end

	gg:Show()
end

----------------------------------------------------
-- SELECT (stub, here mostly for future use / parity)
----------------------------------------------------
function DPSMate.Modules.DetailsManaGained:SelectDetailsButton(i)
	local obj = DPSMate_Details_ManaGained_Log_ScrollFrame
	if not obj then return end
	local lineplusoffset = i + (FauxScrollFrame_GetOffset(obj) or 0)
	DetailsSelected = lineplusoffset
end
