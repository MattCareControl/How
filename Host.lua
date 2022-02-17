
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
local CatList = {}
local WinnerOptions = {}
local LoserOptions = {}
local NoQuestions = {}
local TimeLimit = {}
local GameTypes = {{"Winners & Losers","Winners & Losers"},{"Winners Only","Winners Only"},{"Cash Game","Cash Game"}}


local ExitClick = function(event)

	if event.phase == "ended" then

		func.LoadScreen("Welcome","crossFade",1000)
	end
	return true

end

local UserConfirm = function(HostResponse)

	local s

	_G.NetworkCallOn = false
	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "COMPLETED") ~= nil then
			func.LoadScreen("Host2","crossFade",1000)
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end
	end	
end

local LoadGame = function(GameData)

	func.LoadGameData( GameData.response)
	http.MakeNetworkCall(UserConfirm,"ConfirmPlayer",_G.GameGuid, _G.UserCode) 

end

local StartGame = function(HostResponse)

	local s

	_G.NetworkCallOn = false
	if (HostResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(HostResponse.response, "COMPLETED") ~= nil then
			s = func.split(HostResponse.response,";")
			_G.GameGuid = s[2]
			http.MakeNetworkCall(LoadGame,"DownloadGame",_G.GameGuid) 
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end
	end	
end

local Continue = function(event)

	local GameType
	local WinnerOption = ""
	local LoserOption = ""
	local StakeOption = 0

	if event.phase == "ended" then


		if func.GetListValue("CatList",0) == 0 then
			func.ShowSimpleAlert("Select a Category","No category selected.")
			return
		end 			

		if func.GetListText("GameType","") == "" then
			func.ShowSimpleAlert("Select a Game Type","No Game Type selected.")
			return
		end 

		GameType = func.GetListText("GameType","")

		if GameType == "Winners & Losers" then
			if string.len(_G.GUI.GetHandle("txtWinner"):getText()) < 3 then
				func.ShowSimpleAlert("Winner Prize Missing","Please enter a winning prize.")
				return
			end 

			if string.len(_G.GUI.GetHandle("txtLoser"):getText()) < 3 then
				func.ShowSimpleAlert("Loser Forfeit Missing","Please enter a loser forfeit.")
				return
			end 
			WinnerOption = _G.GUI.GetHandle("txtWinner"):getText()
			LoserOption = _G.GUI.GetHandle("txtLoser"):getText()
		end

		if GameType == "Winners Only" then
			if string.len(_G.GUI.GetHandle("txtWinner"):getText()) < 3 then
				func.ShowSimpleAlert("Winner Prize Missing","Please enter a winning prize.")
				return
			end 
			WinnerOption = _G.GUI.GetHandle("txtWinner"):getText()
		end

		if GameType == "Cash Game" then
			if tonumber(_G.GUI.GetHandle("txtStake"):getText()) == nil then
				func.ShowSimpleAlert("Valid Stake Missing","Please enter a valid stake.")
				return
			end 
			if tonumber(_G.GUI.GetHandle("txtStake"):getText()) == 0 then
				func.ShowSimpleAlert("Valid Stake Missing","Please enter a valid stake.")
				return
			end 
			StakeOption = _G.GUI.GetHandle("txtStake"):getText()
		end


		print("Run 1")
		http.MakeNetworkCall(StartGame,"StartGame",_G.UserCode,func.GetListValue("CatList",0),func.GetListValue("NoQs",0),func.GetListValue("TimeList",0),url.escape(GameType), url.escape(WinnerOption), url.escape(LoserOption), StakeOption) 

	end
	return true

end


local ClearExtra = function()

	--func.SuperDDRemoveListBox()
	func.ClearListValue("WinnerOptions")
	func.ClearListValue("LoserOptions")
	if _G.GUI.GetHandle("txtStake") ~= nil then
		_G.GUI.GetHandle("txtStake"):destroy()	
	end
	if _G.GUI.GetHandle("txtWinner") ~= nil then
		_G.GUI.GetHandle("txtWinner"):destroy()	
	end
	if _G.GUI.GetHandle("txtLoser") ~= nil then
		_G.GUI.GetHandle("txtLoser"):destroy()	
	end
	func.ClearGroup(ExtraGrp)

end


local GameSelect = function(Listname, xPos, yPos)

	local GameType
	GameType = func.GetListText(Listname)

	ClearExtra()
	ExtraGrp = display.newGroup()
	if GameType == "Winners & Losers" then
		ExtraGrp:insert(func.StandardImage("WinnerText.png",170,540,nil,nil,nil,0.6))
		--ExtraGrp:insert(func.SuperDropDown(ExtraGrp,600,20,600,WinnerOptions,"WinnerList"))
		func.CoolEdit("",80 ,600,480,25,"txtWinner",ExtraGrp,"restrict")	
		ExtraGrp:insert(func.StandardImage("LoserText.png",180,680,nil,nil,nil,0.6))
		--ExtraGrp:insert(func.SuperDropDown(ExtraGrp,600,20,740,LoserOptions,"LoserList"))
		func.CoolEdit("",80 ,740,480,25,"txtLoser",ExtraGrp,"restrict")
	end

	if GameType == "Winners Only" then
		ExtraGrp:insert(func.StandardImage("WinnerText.png",170,540,nil,nil,nil,0.6))
		--ExtraGrp:insert(func.SuperDropDown(ExtraGrp,600,20,600,WinnerOptions,"WinnerList"))
		func.CoolEdit("",80 ,600,480,25,"txtWinner",ExtraGrp,"restrict")
	end

	if GameType == "Cash Game" then
		ExtraGrp:insert(func.StandardImage("StakeText.png",190,540,nil,nil,nil,0.6))
		ExtraGrp:insert(func.StandardImage("Sterling.png",320,630,nil,nil,nil,0.6))
		func.CoolEdit(0,240 ,615,180,28,"txtStake",ExtraGrp,"decimal")	
		--ExtraGrp:insert(func.SuperDropDown(ExtraGrp,600,20,600,WinnerOptions,"WinnerList"))
	end
	scView:insert(ExtraGrp)
end

local LoadScreen = function()

	scView = widget.newScrollView
	{
		x = display.contentWidth/2,
		y = 1136/2 + 30,
		width = 640,
		height = 1136 - 230,
		bottomPadding = 150,
		topPadding = 20,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = true,
		hideBackground = true
	}
	scView:insert( func.StandardImage("CategoryText.png",130,40,nil,nil,nil,0.6))
	scView:insert(func.SuperDropDown(scView,320,300,40,CatList,"CatList"))
	scView:insert( func.StandardImage("NoQuestionText.png",190,160,nil,nil,nil,0.6))
	scView:insert(func.SuperDropDown(scView,220,400,160,NoQuestions,"NoQs"))
	scView:insert(func.SetListValue("NoQs","5", "5 Questions",400,160,30))

	scView:insert( func.StandardImage("AnswerText.png",180,280,nil,nil,nil,0.6))
	scView:insert(func.SuperDropDown(scView,220,400,280,TimeLimit,"TimeList"))
	scView:insert(func.SetListValue("TimeList","10", "10 Seconds",400,280,30))

	scView:insert( func.StandardImage("GameTypeText.png",160,400,nil,nil,nil,0.6))
	scView:insert(func.SuperDropDown(scView,300,320,400,GameTypes,"GameType",nil,GameSelect))
	MainGroup:insert(scView)
	MainGroup:insert( func.StandardImage("Exit.png",display.contentWidth/2 - 200,1080,ExitClick,nil,nil,1.4))
	MainGroup:insert( func.StandardImage("ContinueButton2.png",display.contentWidth/2 + 200,1080,Continue,nil,nil,1.4))
	_G.HaltNav = nil
end


local LoadData = function(Response)

	func.LoadDataSet(Response,CatList)
	LoadScreen()

end

local FinishLoad = function()


	http.MakeNetworkCall(LoadData,"GetCategoryList") 

end

function scene:enterScene(event)

	for i = 1,20 do
		NoQuestions[#NoQuestions+1] = {}
		NoQuestions[#NoQuestions][1] = i
		NoQuestions[#NoQuestions][2] = i .. " Question"
		if i > 1 then
			NoQuestions[#NoQuestions][2] = NoQuestions[#NoQuestions][2] .. "s"
		end
	end

	for i = 3,30 do
		TimeLimit[#TimeLimit+1] = {}
		TimeLimit[#TimeLimit][1] = i
		TimeLimit[#TimeLimit][2] = i .. " Seconds"
	end

	_G.HaltNav = 1
	transition.to( MainGroup, { time=700, alpha=1, onComplete=listener1,transition=easing.outQuart,onComplete=FinishLoad } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )



	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("HostTitle.png",display.contentWidth/2,60,nil,nil,nil,0.7))
	group:insert(MainGroup)


end

function scene:destroyScene( event )
	
	func.ClearListValue("WinnerOptions")
	func.ClearListValue("LoserOptions")
	func.ClearListValue("CatList")
	func.ClearListValue("NoQs")
	func.ClearListValue("TimeList")
	func.ClearListValue("GameType")

	if _G.GUI.GetHandle("txtStake") ~= nil then
		_G.GUI.GetHandle("txtStake"):destroy()	
	end
	if _G.GUI.GetHandle("txtWinner") ~= nil then
		_G.GUI.GetHandle("txtWinner"):destroy()	
	end
	if _G.GUI.GetHandle("txtLoser") ~= nil then
		_G.GUI.GetHandle("txtLoser"):destroy()	
	end
	func.ClearGroup(ExtraGrp)
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