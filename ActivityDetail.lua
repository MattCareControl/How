--
-- Project: CareControlMobile2
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 . All Rights Reserved.
-- 

--
-- Project: CareControlPortal
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 . All Rights Reserved.
-- 
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local lfs = require("lfs")
--local CCDB = require("Offline")
local group
local RunDate, RunDateValue
local ShowCalendar
local ActivityID
local InPast
local LoadDataSet
local SaveButton
local fadeScreen
local calName
local KidData = {}
local KidList
local InfoScreen
local LockFlag
local LockSet
local LockFlagYN

local RefreshDataSet = function()


	http.MakeNetworkCall(LoadDataSet, "GetKidsActivity",RunDateValue,ActivityID )

end


local SaveDataSet = function(Response)

	if fadeScreen ~= nil then
		fadeScreen:removeSelf()
		fadeScreen = nil
	end
	if (Response.isError) then
		native.showAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else
		if Response.response == "COMPLETED" then
			func.ShowSimpleAlert("Save Completed","Everything Saved!")
			RefreshDataSet()	
		else
			func.ShowSimpleAlert("Something is Wrong","That save did not work.  Have you got a signal?")
		end
	end 
	


end


local SaveDataSet = function()

	local SaveString = ""
	fadeScreen = func.FadeScreen()
	group:insert(fadeScreen)
	for i = 1,#KidData do
		if tonumber(KidData[i][7]) == 1 then
			SaveString = SaveString .. KidData[i][1] .. ";"
		end
	end

	http.MakeNetworkCall(SaveDataSet, "SaveKidsActivity",RunDateValue,ActivityID,SaveString, _G.CoachID, LockFlag )

end

local SaveCheck = function(event)


	local PostData
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then	
			SaveDataSet()
		end
	end
	return true

end

local ActionButton = function(event)

	
	if event.phase == "ended" then

		if event.target.id == "BackBtn" then
			func.GoBack()
		end

		if event.target.id == "CloseBtn" then
			if InfoScreen ~= nil then
				InfoScreen:removeSelf()
				InfoScreen = nil
			end
			if fadeScreen ~= nil then
				fadeScreen:removeSelf()
				fadeScreen = nil
			end
		end

		if event.target.id == "SaveBtn" then
			if LockFlag == 1 then
				func.NativeReplaceQuestion( "Finalise Records", "If you finalise the records they cannot be changed?", { "Yes", "No" }, SaveCheck )
			else
				SaveDataSet()
			end
		end

	end
	return true


end


local lpad = function(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - string.len(str)) .. str 
end

local CalendarSelected = function(event)

local button = event.buttonPressed
local cal

cal = event.name
local newDate
	if fadeScreen ~= nil then
		fadeScreen:removeSelf()
		fadeScreen = nil
	end
	if button == "DAY" then
		newDate = lpad(event.day,2,'0') .. "/" .. lpad(event.month,2,'0') .. "/" ..event.year

		if string.find(cal, "RunDate") then
			if RunDate ~= nil then
				RunDate:removeSelf()
				RunDate = nil
			end
			RunDateValue = newDate
			RunDate = func.SuperLabel({Border=1,id="RunDate",listener=ShowCalendar,Caption=newDate,FontSize=30,Left=250,Width=170,Height=25,Top=110,Red=0/255,Green=0/255,Blue=0/255})
			group:insert(RunDate)
		end

		event.Widget:show(false, true)
		_G.GUI.GetHandle(cal):destroy() 
		RefreshDataSet()
	end
end

local ClearCal = function(event)

	if event.phase == "ended" then

		if _G.GUI.GetHandle(calName) ~= nil then
			_G.GUI.GetHandle(calName):destroy() 
		end
		if fadeScreen ~= nil then
			fadeScreen:removeSelf()
			fadeScreen = nil
		end
	end
	return true

end

ShowCalendar = function(event)

	if event.phase == "ended" then

		fadeScreen = func.FadeScreen(nil,ClearCal)
		group:insert(fadeScreen)
		--_G.GUI.GetHandle(cal):destroy() 
		calName = "MY_CALENDAR_" .. event.target.id
		_G.GUI.NewCalendar(
			{
			x               = display.contentWidth/2 -290,                
			y               = "center", 
			scale           = 2,
			name            = calName,            
			parentGroup     = nil,   
			theme           = _G.theme, 
			border          = {"shadow", 8,8, .25},
			onRelease = CalendarSelected,
		}
		)

		_G.GUI.GetHandle(calName):setDate()		
		
	end
	return true
end

local TickKid = function(event)

	if event.phase == "ended" then
		local id
		id = tonumber(event.target.id)
		if tonumber(KidData[id][7]) == 1 then
			KidData[id][7] = 0
		else
			KidData[id][7] = 1
		end
		KidList:reloadData()

	end
	return true
end

local RingNumber2 = function(event)

	local ev = event.target
	if event.phase == "ended" then

		local id = tonumber(ev.id)
		local tel = KidData[id][5]
		system.openURL( "tel:" .. tel )
	end
	return true

end

local RingNumber1 = function(event)

	local ev = event.target
	if event.phase == "ended" then

		local id = tonumber(ev.id)
		local tel = KidData[id][4]
		system.openURL( "tel:" .. tel )
	end
	return true

end

local LoadInfo = function(event)


	if event.phase == "ended" then

		local id = event.target.id
		fadeScreen = func.FadeScreen()
		group:insert(fadeScreen)

		InfoScreen = display.newGroup()
		InfoScreen:insert(func.StandardImage("editText2.png",320,300))
		group:insert(InfoScreen)

		InfoScreen:insert(func.SuperLabel({Caption="Child Details",Underline=1,FontSize=36,Bold=1,Left=30,Height=20,Top=150,Red=99/255,Green=37/255,Blue=35/255}))
		InfoScreen:insert(func.SuperLabel({Caption="Emgergency Contact:",Underline=0,FontSize=30,Bold=0,Left=30,Height=20,Top=250,Red=99/255,Green=37/255,Blue=35/255}))
		InfoScreen:insert(func.SuperLabel({Caption=KidData[id][3],Underline=0,FontSize=30,Bold=0,Left=140,Height=20,Top=300,Red=99/255,Green=37/255,Blue=35/255}))
		InfoScreen:insert(func.SuperLabel({id=id,Caption=KidData[id][4],Underline=1,FontSize=30,Bold=0,Left=140,Height=20,Top=350,Red=0/255,Green=0/255,Blue=255/255,listener=RingNumber1}))
		InfoScreen:insert(func.SuperLabel({id=id,Caption=KidData[id][5],Underline=1,FontSize=30,Bold=0,Left=140,Height=20,Top=400,Red=0/255,Green=0/255,Blue=255/255, listener=RingNumber2}))

		InfoScreen:insert(func.WideButton2("Close",ActionButton,"CloseBtn", 550, 400))	
	end
	return true

end


local  ResRowRender = function( event )

   local row = event.row
   local id = row.index

	row:insert(func.StandardImage("info.png", 35,40,LoadInfo,id))
	if string.len(KidData[id][9]) > 0 then
		row:insert(func.StandardLabelBold(KidData[id][2] .. " (" .. KidData[id][9] .. ")",70,40,24,0,0,0))
	else
		row:insert(func.StandardLabelBold(KidData[id][2] ,70,40,24,0,0,0))
	end 
	row:insert(func.CreateYesNoButton(550,25,id,KidData[id][7],TickKid))
	return true
end

local ResRowClick = function(event)

	if event.phase == "release" then
		local row = event.row
		local id = tonumber(row.index)


		if tonumber(KidData[id][7]) == 1 then
			KidData[id][7] = 0
		else
			KidData[id][7] = 1
		end
		KidList:reloadData()

	end
	return true


end

LockSet = function(event)


	if event.phase == "ended" then

		if LockFlag == 0 then
			LockFlag = 1
		else
			LockFlag = 0
		end

		if LockFlagYN ~= nil then
			LockFlagYN:removeSelf()
			LockFlagYN = nil
		end

		LockFlagYN = func.CreateYesNoButton(220,1075,id,LockFlag,LockSet)
		group:insert(LockFlagYN)
	end
	return true

end

local LoadSaveOption = function()

	if SaveButton ~= nil then
		SaveButton:removeSelf()
		SaveButton = nil
	end

	if #KidData == 0 then
		func.ShowSimpleAlert("No Activity","There was no activity for this day.")
		func.GoBack()
	else
		if tonumber(KidData[1][8]) == 0 then

			LockFlagYN = func.CreateYesNoButton(220,1075,id,LockFlag,LockSet)
			group:insert(LockFlagYN)
			group:insert(func.StandardLabelBold("Finalise Records" ,270,1090,24,0,0,0))
			SaveButton = func.WideButton2("Save Details",ActionButton,"SaveBtn", 550, 1090)
			group:insert(SaveButton)	
		else
			func.ShowSimpleAlert("Data Set Locked","You cannot make changes to this data set.")
		end
	end


end

local LoadList = function()

		if KidList ~= nil then
			KidList:deleteAllRows()	
			KidList:removeSelf()
			KidList = nil

		end

		KidList = func.CreateListView(20, 190, 610, 830,ResRowRender, ResRowClick, true )
		group:insert(KidList)	

			
		local MaleCol = {133/255,170/255,186/255}
		local FemaleCol = {228/255,160/255,234/255}
		local RowCol
		for i = 1, #KidData do
			if KidData[i][6] == "Male" then
				RowCol = MaleCol
			else
				RowCol = FemaleCol
			end
			KidList:insertRow
			{
		
				rowHeight  = 80,
				lineColor={212/255,212/255, 212/255},
				rowColor = 
				{ 
					default = RowCol,
				}, 
			}
		end

	LoadSaveOption()
	_G.HaltNav = nil
end

LoadDataSet = function(DataSet)

	func.LoadDataSet(DataSet,KidData,"|","¬")
	LoadList()
end

function scene:enterScene(event)

	LockFlag = 0
	RunDateValue = os.date("%d/%m/%Y")
	group:insert(func.SuperLabel({Caption="Activity Date:",Underline=0,FontSize=30,Bold=1,Left=20,Height=20,Top=110,Red=99/255,Green=37/255,Blue=35/255}))
	
	RunDate = func.SuperLabel({Border=1,id="RunDate",listener=ShowCalendar,Caption=RunDateValue,FontSize=30,Left=250,Width=170,Height=25,Top=110,Red=0/255,Green=0/255,Blue=0/255})
	group:insert(RunDate)

	group:insert(func.CreateBox2(10,1090,display.contentWidth-20,90,242/255,242/255,242/255,nil,1,0,0,0))
	group:insert(func.WideButton2("<< Back",ActionButton,"BackBtn", 100, 1090))	


	if ActivityID == 1 then
		group:insert(func.StandardImage("SaturdayCoachingSmall.png", 570,90))
	elseif ActivityID == 2 then
		group:insert(func.StandardImage("SaturdayRideSmall.png", 570,90))
	elseif ActivityID == 3 then
		group:insert(func.StandardImage("RollersSmall.png", 570,90))
	end
	--group:insert(func.DrawLine(40,190,600,190,2,0,0,0))

	InPast = 0
	RefreshDataSet()

	
end

function scene:createScene( event )
	
	group = self.view
	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )

	ActivityID = tonumber(event.params.ActivityID)

	group:insert(func.CreateStandardHeader(nil, nil))


	
end

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.removeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene