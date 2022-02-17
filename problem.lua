--
-- Project: CareControlMobile
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
local widget = require( "widget" )
local url = require("socket.url")
local http = require("httpwork")

local group 
local screen

local errorText, internetIssue,callType,currentScreen
local moreLabel
local ResetCount = 0
local FullErrorText




local RestartDevice2 = function(event)


	if event.phase == "ended" then

		local Options =
		{
		    effect = "slideLeft",
		    time = 800, 
		    params =""
		}

		storyboard.gotoScene( "splash", Options ) 
	end
	return true

end


local RestartQuestion = function(eventData)

	if eventData.button == 1 then 

		os.exit()

	end


	return true
end

local RestartDevice = function(event)


	if event.phase == "ended" then

		func.ShowSimpleQuestion("Restart App","When you select Yes the App will close.  You can then restart it from your device home screen.  Do you want to restart the app?", RestartQuestion)
		return true
	end
	return true

end

local ForceOnline = function(event)

	if "clicked" == event.action then
        local i = event.index
        if 1 == i then	
			CCDB.Initilise()
			CCDB.ClearOffline()
			CCDB.ClearLogin()
			_G.CanWorkOffline = 0
			_G.WorkingOffline = 0
			RestartDevice2({phase="ended"})
		end
	end

	return true

end


local ResetQuestion = function(event)
	
	if "clicked" == event.action then
        local i = event.index
        if 1 == i then	
 			CCDB.Initilise()
			CCDB.ClearOffline()
			CCDB.ClearLogin()
			_G.CanWorkOffline = 0
			_G.WorkingOffline = 0
			os.remove(system.pathForFile( "settings.txt", system.DocumentsDirectory  ))
			RestartDevice2({phase="ended"})
		end	
	end

end

local ResetTouch = function(event)


	if event.phase == "ended" then

		ResetCount = ResetCount + 1
		if ResetCount > 15 and _G.WorkingOffline == 0 then
			local alert = func.NativeReplaceQuestion( "Reset Device", "Are you sure you want to reset this device?", { "Yes", "No" }, ResetQuestion )
		end
		if ResetCount > 10 and _G.WorkingOffline == 1 then
			local alert = func.NativeReplaceQuestion( "Force Online", "If you force online you may lose any data not yet saved.  Select Yes to Continue?", { "Yes", "No" }, ForceOnline )
		end
	end
	return true

end



local IssuePost = function(SaveRep)
	print(" === "..SaveRep.response)
	if (SaveRep.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(SaveRep.response, "User Not Active") ~= nil then
			func.ShowSimpleAlert("Account Not Active","Your account is not active.  Please check with your administrator with regards access through the Care Control Portal.",{"OK"})
		elseif string.find(SaveRep.response, "COMPLETED") ~= nil then
			_G.NetworkCallOn = false
			local r = {}
			r = func.split(SaveRep.response,";")
			func.ShowSimpleAlert("Issue Logged","You issue has been logged with the following reference: " .. r[2] .. ". A message containing this reference has also been sent to you.")
			--RestartDevice({phase="ended"})
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error saving your record.  Please contact support.",{"OK"})
			_G.NetworkCallOn = false
		end
	end
		
end

local LogIssue = function(event)


	if event.phase == "ended" then
		local backTrace = ""

		for i = 1, #_G.BackStructure do
			backTrace = backTrace .. _G.BackStructure[i].ScreenName ..";"
		end
		--_G.IPAddress = "strong.carecontrolsystems.co.uk"
    	local PostData
		PostData = "IssueTitle=" .. url.escape("Runtime Error - Care Control Pocket")	
		PostData = PostData .. "&Comments=" .. url.escape(FullErrorText)  .. "\nPage Params: " .. url.escape(func.printTable(_G.Params)).. "\n###BACK TRACE###:" .. url.escape(backTrace)
		PostData = PostData .. "&StaffID=" .. _G.StaffIndex	
		PostData = PostData .. "&Version=" .. url.escape(_G.VersionNumber)
		PostData = PostData .. "&PreviousScreen=" .. url.escape(currentScreen)
		http.PostNetworkData(IssuePost,PostData,"LogSupportIssue") 


	end

	return true


end




local ForceOnlineQ = function(event)


	if event.phase == "ended" then
		local alert = func.NativeReplaceQuestion( "Force Online", "If you force online you may lose any data not yet saved.  Select Yes to Continue?", { "Yes", "No" }, ForceOnline )
	end
	return true

end

local OpenBrowser = function(event)

	if event.phase == "ended" then
		system.openURL("http://www.google.com")
	end
	return true

end

local ShowMoreInfo = function(event)

	if event.phase == "ended" then
		 
		screen:insert(func.CreateBox(350,800,551,155,nil,nil,3))
		--lb2 = func.MultilineLabel(medicationRecord.medicineDescription,50,272,450,56,14,0,0,0,1)
		--row:insert()
		moreLabel = func.SuperLabel({Caption=FullErrorText,Left=80,Top=800,FontSize=18, Bold=1, Width=550, Height=150,Scroll=1 })		
		screen:insert(moreLabel)
	end
	return true

end



function scene:destroyScene(event)


	
end

function scene:enterScene(event)
	_G.HaltNav = nil
	transition.to( screen, { time=500,  alpha=1 } )
end


function scene:createScene( event )
	
	group = self.view
	
	screen = display.newGroup()
	screen.alpha = 1
	group:insert(screen)
	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )
	
	ResetCount = 0

	local p = event.params
	errorText = p.eventError
	internetIssue = p.httpWork		
	callType = p.callType
	currentScreen = p.screen

	FullErrorText = "The following error has occurred at " .. os.date("%d/%m/%Y %H:%M:%S") .. ":\r\n"
	FullErrorText = FullErrorText .. errorText .. "\r\n"
	if tonumber(internetIssue) == 1 then
		FullErrorText = FullErrorText .. "Internet Issue: Yes\r\n"
	else
		FullErrorText = FullErrorText .. "Internet Issue: No\r\n"
	end
	FullErrorText = FullErrorText .. "Call Type: " .. callType .. "\r\n"
	FullErrorText = FullErrorText .. "Current Screen: " .. currentScreen .. "\r\n"

	local head = func.CreateStandardHeader(nil, nil,nil,1)
	screen:insert(head)
	screen:insert(func.CreateBox2(10,1090,display.contentWidth-20,90,242/255,242/255,242/255,nil,1,0,0,0))	
	if tonumber(internetIssue) == 1 then
		screen:insert(func.StandardLabelBold("Internet Connection Issue",130, 430,30,40/255,40/255,40/255))
		screen:insert(func.StandardLabel2w("This device has struggled to get a connection to the internet to retrieve some information.\r\rPlease check that it is connected to the Internet through either WiFi or a 3/4g connection.",80, 610,500,26,40/255,40/255,40/255))
		screen:insert(func.WideButton2("Test",OpenBrowser,"3", 550, 1090))
	else
		screen:insert(func.StandardLabelBold("Error Occurred with HOW",130, 430,30,40/255,40/255,40/255))
		screen:insert(func.StandardLabel2w(FullErrorText,80, 610,500,26,40/255,40/255,40/255))
		screen:insert(func.WideButton2("Restart",RestartDevice,"2", display.contentWidth / 2, 1090))
	end
	--screen:insert(func.StandardImage("sadCloud.png",display.contentWidth/2,250,ResetTouch))

	--screen:insert(func.SuperLabel({Caption="More Information",FontSize=20,Bold=0,Underline=1,Left=460,Top=640, Red=0, Green=0, Blue=1, listener=ShowMoreInfo}))	
	
	--screen:insert(func.WideButton2("Restart",RestartDevice,"1", 110, 1090))	
	screen.alpha = 1
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