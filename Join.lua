
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local widget = require( "widget" )
local url = require("socket.url")
local group
local MainGroup
local scView
local ExtraGrp
local UList, SList
local UserList = {}
local SelectList = {}
local LoadData
local PlayGameStarted
local CompleteJoin
local tmid

local ExitGame = function()
	func.LoadScreen("Welcome","crossFade",1000)
end

local ExitClick = function(event)

	if event.phase == "ended" then
		PlayGameStarted = 1
		timer.cancel( tmid )
		timer.performWithDelay( 500, ExitGame  )
	end
	return true

end

CompleteJoin = function(HostResponse)

	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "PLAYING") ~= nil then
			func.LoadScreen("PlayGame","crossFade",1000)
		elseif string.find(HostResponse.response, "STARTED") ~= nil then
			if Contents ~= nil then
				Contents:removeSelf()
				Contents = nil
			end

			Contents = display.newGroup()
			MainGroup:insert(Contents)
			Contents:insert(func.StandardLabelBold("Waiting on Other Players...",60,500,40,91/255,155/255,213/255))
			local CheckGame = function()
				http.MakeNetworkCall(CompleteJoin,"CheckGame", _G.GameGuid) 
			end
			if PlayGameStarted == nil then
				tmid = timer.performWithDelay( 500, CheckGame  )
			end
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end
	end


end


local CompleteExit = function(HostResponse)

	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "COMPLETED") ~= nil then
			_G.GameGuid = ""
			func.LoadScreen("Welcome","crossFade",1000)
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end
	end
end


local ExitClick = function(event)

	
	if event.phase == "ended" then

		http.MakeNetworkCall(CompleteExit,"ExitGame", _G.GameGuid,_G.UserCode ) 

	end
	return true
end

local JoinClick = function(event)

	
	if event.phase == "ended" then

		http.MakeNetworkCall(CompleteJoin,"FinishJoin", _G.GameGuid,_G.UserCode ) 

	end
	return true
end

local LoadGame = function(GameData)

	if Contents ~= nil then
		Contents:removeSelf()
		Contents = nil
	end

	Contents = display.newGroup()
	MainGroup:insert(Contents)

	func.LoadGameData( GameData.response)
	
	Contents:insert(func.StandardLabelBold("Found a Game!! Game Details: -",40,150,40,91/255,155/255,213/255))

	Contents:insert(func.StandardLabelBold("Hosted By: ",20,250,40,91/255,155/255,213/255))
	Contents:insert(func.StandardLabelBold(_G.GameStructure[1].HostName,270,250,40,255/255,255/255,0/255))

	Contents:insert(func.StandardLabelBold("Game Type: ",20,320,40,91/255,155/255,213/255))
	Contents:insert(func.StandardLabelBold(_G.GameStructure[1].GameType,270,320,40,255/255,255/255,0/255))

	Contents:insert(func.StandardLabelBold("Category: ",20,390,40,91/255,155/255,213/255))
	Contents:insert(func.StandardLabelBold(_G.GameStructure[1].Category,270,390,40,255/255,255/255,0/255))

	Contents:insert(func.StandardLabelBold("Time Limit: ",20,460,40,91/255,155/255,213/255))
	Contents:insert(func.StandardLabelBold(_G.GameStructure[1].TimeLimit .. " seconds",270,460,40,255/255,255/255,0/255))

	Contents:insert(func.StandardLabelBold("Number Q's: ",20,530,40,91/255,155/255,213/255))
	Contents:insert(func.StandardLabelBold(_G.GameStructure[1].NoQuestions ,270,530,40,255/255,255/255,0/255))
	if _G.GameStructure[1].GameType == "Winners & Losers" then
		Contents:insert(func.StandardLabelBold("Winner Wins: ",20,600,40,91/255,155/255,213/255))
		Contents:insert(func.StandardLabelBold(_G.GameStructure[1].WinnerGets ,20,660,40,255/255,255/255,0/255))
		Contents:insert(func.StandardLabelBold("Loser Forfiet: ",20,740,40,91/255,155/255,213/255))
		Contents:insert(func.StandardLabelBold(_G.GameStructure[1].Forfiet ,20,800,40,255/255,255/255,0/255))
	
	elseif _G.GameStructure[1].GameType == "Winners Only" then
		Contents:insert(func.StandardLabelBold("Winner Wins: ",20,600,40,91/255,155/255,213/255))
		Contents:insert(func.StandardLabelBold(_G.GameStructure[1].WinnerGets ,20,660,40,255/255,255/255,0/255))
	elseif _G.GameStructure[1].GameType == "Cash Game" then
		Contents:insert(func.StandardLabelBold("Stake: ",20,600,40,91/255,155/255,213/255))
		Contents:insert(func.StandardLabelBold("£" .. _G.GameStructure[1].Stake .. "p",270,600,40,255/255,255/255,0/255))
	end

	Contents:insert( func.StandardImage("Confirm1.png",500,1040,JoinClick,nil,nil,1.2))
	Contents:insert( func.StandardImage("NoWay.png",150,1040,ExitClick,nil,nil,1.2))

end

LoadData = function(HostResponse)

	
	if Contents ~= nil then
		Contents:removeSelf()
		Contents = nil
	end

	Contents = display.newGroup()
	MainGroup:insert(Contents)

	if string.find(HostResponse.response, "NOGAME") ~= nil then
		Contents:insert(func.StandardLabelBold("Waiting for Game Invitation...",60,500,40,91/255,155/255,213/255))
		Contents:insert( func.StandardImage("Exit.png",display.contentWidth/2,1080,ExitClick,nil,nil,1.4))
		local FindGame = function()
			http.MakeNetworkCall(LoadData,"FindGame", _G.UserCode) 
		end
		if PlayGameStarted == nil then
			tmid = timer.performWithDelay( 500, FindGame  )
		end	
	elseif string.find(HostResponse.response, "COMPLETED") ~= nil then
		s = func.split(HostResponse.response,";")
		_G.GameGuid = s[2]
		http.MakeNetworkCall(LoadGame,"DownloadGame",_G.GameGuid) 
	end


end

local FinishLoad = function()

	_G.HaltNav = nil
	local FindGame = function()
		http.MakeNetworkCall(LoadData,"FindGame", _G.UserCode) 
	end
	if PlayGameStarted == nil then
		tmid = timer.performWithDelay( 500, FindGame  )
	end
	

end

function scene:enterScene(event)


	_G.HaltNav = 1
	transition.to( MainGroup, { time=700, alpha=1, onComplete=listener1,transition=easing.outQuart,onComplete=FinishLoad } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )



	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("JoinGame.png",display.contentWidth/2,60,nil,nil,nil,0.7))
	group:insert(MainGroup)


end

function scene:destroyScene( event )
	
	if SList ~= nil then
		SList:deleteAllRows()
		SList:removeSelf()
		SList = nil
	end
	if UList ~= nil then
		UList:deleteAllRows()
		UList:removeSelf()
		UList = nil
	end
	timer.cancel( tmid )
	func.ClearGroup(scView)
	network.cancel( _G.NetworkID )
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