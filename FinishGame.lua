
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local widget = require( "widget" )
local url = require("socket.url")
local socket = require("socket")
local group
local MainGroup
local scView
local CheckResults
local ResultData = {}


local Continue = function(event)

	if event.phase == "ended" then

		func.LoadScreen("Welcome","crossFade",1000)
	end
	return true

end

local DisplayResults = function()

	scView = widget.newScrollView
	{
		x = display.contentWidth/2,
		y = 1136/2 + 30,
		width = 640,
		height = 1136 - 240,
		bottomPadding = 150,
		topPadding = 20,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideBackground = true
	}

	local v = 30
	scView:insert(func.StandardImage("Tile.png",display.contentWidth/2,200,nil,nil,nil,1.5))

	if _G.GameStructure[1].GameType == "Cash Game" then
		scView:insert(func.StandardImage("Cash.png",display.contentWidth/2,120,nil,nil,nil,1))
		scView:insert(func.StandardLabelBold("Cash Prize of: " .. ResultData[1][5] ,display.contentWidth/2,200,45,6/255,4/255,74/255,nil,nil,1))
		scView:insert(func.StandardLabelBold("Won by: " .. ResultData[1][4] .. "!" ,display.contentWidth/2,270,45,6/255,4/255,74/255,nil,nil,1))	
	end

	if _G.GameStructure[1].GameType == "Winners Only" then
		scView:insert(func.StandardImage("WinnerIcon.png",display.contentWidth/2,120,nil,nil,nil,1))
		scView:insert(func.StandardLabelBold("Winner: " .. ResultData[1][4]  ,display.contentWidth/2,200,42,6/255,4/255,74/255,nil,nil,1))
		scView:insert(func.StandardLabelBold("Prize: " .. _G.GameStructure[1].WinnerGets ,display.contentWidth/2,270,38,6/255,4/255,74/255,nil,nil,1))	
	end

	if _G.GameStructure[1].GameType == "Winners & Losers" then
		scView:insert(func.StandardLabelBold("Winner : " .. ResultData[1][4]  ,display.contentWidth/2,100,45,6/255,4/255,74/255,nil,nil,1))
		scView:insert(func.StandardLabelBold("Prize: " .. _G.GameStructure[1].WinnerGets ,display.contentWidth/2,160,38,6/255,4/255,74/255,nil,nil,1))
		scView:insert(func.StandardLabelBold("Loser: " .. ResultData[2][4]  ,display.contentWidth/2,220,45,6/255,4/255,74/255,nil,nil,1))
		scView:insert(func.StandardLabelBold("Forfiet: " .. _G.GameStructure[1].Forfiet ,display.contentWidth/2,280,38,6/255,4/255,74/255,nil,nil,1))
	end

	scView:insert(func.DrawLine(40,410,600,410,6,255/255,255/255,0/255))
	scView:insert(func.StandardLabelBold("Overall Rankings"  ,display.contentWidth/2,450,45,91/255,155/255,213/255,nil,nil,1))
	scView:insert(func.StandardLabelBold("Pos.",40,520,38,91/255,155/255,213/255))
	scView:insert(func.StandardLabelBold("Player",150,520,38,91/255,155/255,213/255))
	scView:insert(func.StandardLabelBold("Score",450,520 ,38,91/255,155/255,213/255))
	v = 580
	local n = 1
	for i = 1, #ResultData do
		if ResultData[i][2] == "Section 2" then
			scView:insert(func.StandardLabelBold(n .. ".",40,v,38,255/255,255/255,0/255))
			scView:insert(func.StandardLabelBold(ResultData[i][3],150,v,38,255/255,255/255,0/255))
			scView:insert(func.StandardLabelBold(ResultData[i][4],460,v ,38,255/255,255/255,0/255))
			v = v + 70
			n = n  + 1
		end
		
	end
	scView:insert(func.DrawLine(40,v,600,v,6,255/255,255/255,0/255))
	scView:insert(func.StandardLabelBold("All The Detail!"  ,display.contentWidth/2,v + 50,45,91/255,155/255,213/255,nil,nil,1))

	
	local Sect = ""
	for i = 1, #ResultData do

		if string.find(ResultData[i][2], "Section 3") ~= nil then
			if Sect ~= ResultData[i][2] then
				Sect = ResultData[i][2]
				v = v + 120
				scView:insert(func.StandardLabelBoldW("Q " .. ResultData[i][3] .. "?",20,v,550,38,91/255,155/255,213/255))
				v = v + 90
				scView:insert(func.StandardLabelBold("Correct Answer: ".. ResultData[i][4],20,v,38,255/255,255/255,255/255))
				v = v + 90
				scView:insert(func.StandardLabelBold("Pos.",30,v,38,91/255,155/255,213/255))
				scView:insert(func.StandardLabelBold("Player",110,v,38,91/255,155/255,213/255))
				scView:insert(func.StandardLabelBold("Answer",300,v ,38,91/255,155/255,213/255))
				scView:insert(func.StandardLabelBold("Time",510,v ,38,91/255,155/255,213/255))
				n = 1
			end
		end
		if string.find(ResultData[i][2], "Section 4") ~= nil then
			v = v + 60
			print(ResultData[i][2])
			scView:insert(func.StandardLabelBold(n .. ".",40,v,38,255/255,255/255,0/255))
			scView:insert(func.StandardLabelBold(ResultData[i][3],110,v,38,255/255,255/255,0/255))
			scView:insert(func.StandardLabelBold(ResultData[i][4],300,v ,38,255/255,255/255,0/255))
			scView:insert(func.StandardLabelBold(ResultData[i][5],520,v ,38,255/255,255/255,0/255))
			n = n + 1
		end
		
	end

	-- 	if ResultData[i][2] == "Section 2" then
	-- 		scView:insert(func.StandardLabelBold(ResultData[i][3],20,v,38,91/255,155/255,213/255))
	-- 		scView:insert(func.StandardLabelBold(ResultData[i][4],400,v,38,255/255,255/255,0/255))
	-- 	end		
	-- end

	MainGroup:insert(scView)
	MainGroup:insert( func.StandardImage("ContinueButton.png",display.contentWidth/2,1080,Continue,nil,nil,1))
	_G.HaltNav = nil


end

local StartTimer = function()

	
	tmID = timer.performWithDelay( 1000, DisplayTimer, 0 )

end

local CheckonTimer = function()

	http.MakeNetworkCall(CheckResults,"GetResults",_G.GameGuid, _G.UserCode ) 

end


CheckResults = function(HostResponse)

	print(HostResponse.response)
	_G.NetworkCallOn = false
	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "WAITING987654321") ~= nil then
			tmID = timer.performWithDelay( 500, CheckonTimer )
		else
			func.LoadDataSet(HostResponse,ResultData)
			DisplayResults()
		end
	end	

end

local LoadPage = function()

	local SaveString = ""

	for i = 1,#_G.GameStructure[1].Questions do
		SaveString = SaveString ..  _G.GameStructure[1].Questions[i].UserAnswer .. "~" .. _G.GameStructure[1].Questions[i].AnswerTime .. "~"
	end
	http.MakeNetworkCall(CheckResults,"SaveGame",_G.GameGuid, _G.UserCode , SaveString) 
	--http.MakeNetworkCall(CheckResults,"GetResults",'952C77E8F05B453C8985C48BD993ADA0','99670B15CE2347D5B609C4F9723CC2E0')
	_G.HaltNav = nil
end

function scene:enterScene(event)


	_G.HaltNav = 1
	_G.CurrentQuestion = 1
	transition.to( MainGroup, { time=700, alpha=1, transition=easing.outQuart,onComplete=LoadPage } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )



	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("Results.png",display.contentWidth/2,60,nil,nil,nil,0.7))

	group:insert(MainGroup)


end

function scene:destroyScene( event )
	
	func.ClearGroup(scView)

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