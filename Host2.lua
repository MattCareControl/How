
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
local LoadData2
local PlayGameStarted
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

local LoadGame = function(event)


	

end

local PlayGame = function(HostResponse)

	local s
	print(HostResponse.response)
	_G.NetworkCallOn = false
	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "COMPLETED") ~= nil then
			func.LoadScreen("PlayGame","crossFade",1000)
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end
	end	
end

local NowPlayGame = function()

	http.MakeNetworkCall(PlayGame,"PlayGame",_G.GameGuid) 

end

local StartGameAnyway = function(event)
	
	local PostData
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then	
			PlayGameStarted = 1
			timer.cancel( tmid )
			network.cancel( _G.NetworkID )
			tmid = timer.performWithDelay( 700, NowPlayGame  )
		end
	end
end

local StartGame = function(event)


	if event.phase == "ended" then

		local foundIssue = false

		for i = 1,#SelectList do
			if tonumber(SelectList[i][3]) == 0 then
				foundIssue = true
			end
		end

		if foundIssue == true then
			local alert = func.NativeReplaceQuestion( "Start Game?", "Not all players have confirmed.  Are you sure you want to start the game?", { "Yes", "No" }, StartGameAnyway )
		else
			PlayGameStarted = 1
			timer.cancel( tmid )
			network.cancel( _G.NetworkID )
			tmid = timer.performWithDelay( 700, NowPlayGame  )
			
		end
	end
	return true

end






local URowClick = function (event)
	
	if event.phase == "release" then
		local row = event.row
	   	local rowid = row.index

	   	http.MakeNetworkCall(LoadData2,"AddPlayer", _G.GameGuid,UserList[rowid-1][1] ) 
	   	UList:deleteRows( { rowid }, { slideLeftTransitionTime=500, slideUpTransitionTime=250 } )



	end
	return true
end

local  URowRender = function( event )

   local row = event.row
   local id = row.index

   		if id == 1 then
   			row:insert(func.StandardLabelBold("Available Players",20,30,40,91/255,155/255,213/255))
   		else
			row:insert(func.StandardLabelBold(UserList[id-1][2],20,30,38,255/255,255/255,0/255))
		end

	return true
end

local  SRowRender = function( event )

   local row = event.row
   local id = row.index

   		if id == 1 then
   			row:insert(func.StandardLabelBold("Selected Players",20,30,40,91/255,155/255,213/255))
   		else
			row:insert(func.StandardLabelBold(SelectList[id-1][2],20,30,38,255/255,255/255,0/255))
			if tonumber(SelectList[id-1][3]) == 1 then
				row:insert(func.StandardImage("tick.png",500,30,nil,nil,nil,0.6))
			elseif tonumber(SelectList[id-1][3]) == 0 then
				row:insert(func.StandardImage("wait.png",500,30,nil,nil,nil,0.6))
			else
				row:insert(func.StandardImage("cross.png",500,30,nil,nil,nil,0.6))
			end

		end

	return true
end

local LoadScreen = function()

	scView = widget.newScrollView
	{
		x = display.contentWidth/2,
		y = 1136/2 + 30,
		width = 640,
		height = 1136 - 230,
		bottomPadding = 150,
		topPadding = 10,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = true,
		hideBackground = true
	}

	-- scView:insert( func.StandardImage("CategoryText.png",130,40,nil,nil,nil,0.6))
	-- scView:insert(func.SuperDropDown(scView,320,300,40,CatList,"CatList"))
	-- scView:insert( func.StandardImage("NoQuestionText.png",190,160,nil,nil,nil,0.6))
	-- scView:insert(func.SuperDropDown(scView,220,400,160,NoQuestions,"NoQs"))
	-- scView:insert(func.SetListValue("NoQs","5", "5 Questions",400,160,30))

	-- scView:insert( func.StandardImage("AnswerText.png",180,280,nil,nil,nil,0.6))
	-- scView:insert(func.SuperDropDown(scView,220,400,280,TimeLimit,"TimeList"))
	-- scView:insert(func.SetListValue("TimeList","5", "5 Seconds",400,280,30))

	-- scView:insert( func.StandardImage("GameTypeText.png",160,400,nil,nil,nil,0.6))
	-- scView:insert(func.SuperDropDown(scView,300,320,400,GameTypes,"GameType",nil,GameSelect))
	scView:insert(func.CreateBox2(39,210,555,405,0/255, 0/255, 0/255,nil,2,255/255,255/255,0/255))
	UList = func.CreateListView(40, 10, 550, 400,URowRender, URowClick, true,nil,true )
	scView:insert(UList)
	UList:insertRow
	{

		rowHeight  = 60,
		isCategory = true,
		lineColor={212/255,212/255, 212/255},
		rowColor = 
		{ 
			default = { 0/255,0/255, 0/255 },
		}, 
	}
	for i = 1, #UserList do
	
		UList:insertRow
		{
	
			rowHeight  = 60,
			lineColor={212/255,212/255, 212/255},
			rowColor = 
			{ 
				default = { 0/255,0/255, 0/255 },
			}, 
		}
	end
	scView:insert(func.CreateBox2(39,630,555,405,0/255, 0/255, 0/255,nil,2,149/255, 55/255, 73/255))

	--SList = func.CreateListView(40, 340, 550, 500,URowRender, URowClick, false )
	--MainGroup:insert(SList)
	MainGroup:insert( func.StandardImage("Exit.png",display.contentWidth/2 - 200,1080,ExitClick,nil,nil,1.4))
	MainGroup:insert( func.StandardImage("StartButton2.png",display.contentWidth/2 + 200,1080,StartGame,nil,nil,1.4))
	_G.HaltNav = nil
	http.MakeNetworkCall(LoadData2,"GetSelectList", _G.GameGuid) 
end


LoadData2 = function(Response)

	local mainList, sublist
	mainList = func.split(url.unescape(string.gsub(Response.response,"&amp;", "&")),"Æ")

	for i = 1,#SelectList do
		table.remove(SelectList)
	end

	for i = 1,#mainList do
		sublist = func.split(mainList[i],"ç")
		SelectList[i] = {}
		SelectList[i][1] = sublist[1]
		SelectList[i][2] = sublist[2]
		SelectList[i][3] = sublist[3]
	end
	_G.NetworkCallOn = false

	
	if SList ~= nil then
		SList:deleteAllRows()
		SList:removeSelf()
		SList = nil
	end

	SList = func.CreateListView(40, 430, 550, 400,SRowRender, nil, true,nil,true )
	scView:insert(SList)
	SList:insertRow
	{

		rowHeight  = 60,
		isCategory = true,
		lineColor={212/255,212/255, 212/255},
		rowColor = 
		{ 
			default = { 0/255,0/255, 0/255 },
		}, 
	}

	for i = 1, #SelectList do
	
		SList:insertRow
		{
	
			rowHeight  = 60,
			lineColor={212/255,212/255, 212/255},
			rowColor = 
			{ 
				default = { 0/255,0/255, 0/255 },
			}, 
		}
	end

	local LoadAgain = function()
		_G.HaltNav = 1
		http.MakeNetworkCall(LoadData2,"GetSelectList", _G.GameGuid) 
	end
	if PlayGameStarted == nil then
		tmid = timer.performWithDelay( 500, LoadAgain  )
	end
	_G.HaltNav = nil
end

local LoadData = function(Response)

	func.LoadDataSet(Response,UserList)
	LoadScreen()
	

end

local FinishLoad2 = function()


	--http.MakeNetworkCall(LoadData,"GetFriendList") 
	http.MakeNetworkCall(LoadData,"GetUserList", _G.GameGuid) 

end

function scene:enterScene(event)


	_G.HaltNav = 1
	transition.to( MainGroup, { time=700, alpha=1, onComplete=listener1,transition=easing.outQuart,onComplete=FinishLoad2 } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )



	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("AddPlayers.png",display.contentWidth/2,60,nil,nil,nil,0.7))
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