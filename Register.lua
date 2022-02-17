
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local widget = require( "widget" )
local group
local MainGroup
local scView


function scene:destroyScene( event )
	
	if _G.GUI.GetHandle("txtLogin") ~= nil then
		_G.GUI.GetHandle("txtLogin"):destroy()	
	end
end


local SaveLogin = function(SaveResponse)

	local s
	print(SaveResponse.response)
	_G.NetworkCallOn = false
	if (SaveResponse.isError) then
		func.ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(SaveResponse.response, "FAILED") ~= nil then
			func.ShowSimpleAlert("Login Exists","Sorry that login name already exists.")
		elseif string.find(SaveResponse.response, "COMPLETED") ~= nil then
			s = func.split(SaveResponse.response,";")
			_G.LoginName = _G.GUI.GetHandle("txtLogin"):getText()
			_G.UserCode = s[2]
			func.CreateUserFile()
			func.LoadScreen("Welcome","crossFade",1000)
		else
			func.ShowSimpleAlert("Unkown Error","There was an unkown error.  Please contact support.",{"OK"})
		end

	end	

end

local SaveLogin = function(event)


	if event.phase == "ended" then

		if string.len(_G.GUI.GetHandle("txtLogin"):getText()) < 3 then
			func.ShowSimpleAlert("Login Name Invalid","The login name is too short.")
			return
		end 

		http.MakeNetworkCall(SaveLogin,"RegisterUser",_G.GUI.GetHandle("txtLogin"):getText()) 

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
		topPadding = 20,
		id = "onBottom",
		horizontalScrollDisabled = true,
		verticalScrollDisabled = true,
		hideBackground = true
	}
	scView:insert( func.StandardImage("LoginText.png",260,80,nil,nil,nil,0.6))
	func.CoolEdit("",140 ,415,380,25,"txtLogin",scView,"restrict")	
	MainGroup:insert(scView)
	MainGroup:insert( func.StandardImage("ContinueButton.png",display.contentWidth/2,1080,SaveLogin,nil,nil,1))
	_G.HaltNav = nil
end




function scene:enterScene(event)

	_G.HaltNav = 1
	transition.to( MainGroup, { time=700, alpha=1, onComplete=listener1,transition=easing.outQuart,onComplete=LoadScreen } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )

	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("RegisterTitle.png",display.contentWidth/2,60,nil,nil,nil,0.7))

	group:insert(MainGroup)
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