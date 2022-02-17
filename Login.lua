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
local http = require("httpwork")

local group 
local buttonGroup 
local PinEntered
local pinCircles = {}
local timerID, holdc

local PreviousButtonx
local paramData1, paramData2
local BypassMessageSignIn
local SignInMethod
local ManageLogin



ManageLogin = function (ResponseMessage)

	for i = 1, 6 do
		if pinCircles[i] ~= nil then
			pinCircles[i]:removeSelf()
			pinCircles[i] = nil
		end

		pinCircles[i] = display.newCircle( 60+((i-1)*100), 200, 40 )
		pinCircles[i]:setStrokeColor( 23/255, 185/255, 178/255 )
		pinCircles[i].strokeWidth = 2
		buttonGroup:insert(pinCircles[i])
	end

	PinEntered = ""
	if (ResponseMessage.isError) then
		native.showAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else
		if ResponseMessage.response == "Incorrect Pin Number" then
			func.ShowSimpleAlert("Incorrect Pin Number","Your pin number is not correct.")
		elseif string.find(ResponseMessage.response, "PINOK") ~= nil  then
			dt = func.split(ResponseMessage.response,";")
			_G.CoachID = dt[2]
			func.LoadScreen("Activity","slideLeft")		
		else
			func.ShowSimpleAlert("Something is Wrong","You may have an internet connection issue.")
		end
	end 
end

local DeletePin = function(event)

	if event.phase == "ended"  and _G.OverlayShow == false then

		local pinLen = string.len(PinEntered)

		for i = 1, 6 do
			if pinCircles[i] ~= nil then
				pinCircles[i]:removeSelf()
				pinCircles[i] = nil
			end

		pinCircles[i] = display.newCircle( 60+((i-1)*100), 200, 40 )
		pinCircles[i]:setStrokeColor( 23/255, 185/255, 178/255 )
		if pinLen > i then
			pinCircles[i]:setFillColor( 23/255, 185/255, 178/255 )
		end
		pinCircles[i].strokeWidth = 2
		buttonGroup:insert(pinCircles[i])
		end

		if string.len(PinEntered) > 0 then
		PinEntered = PinEntered:sub(1, -2)
	end
	end 
end

local buttonHandler = function( event )
	
	if event.phase == "ended"  and _G.OverlayShow == false then
		PinEntered = PinEntered .. event.target.id

		local pinLen = string.len(PinEntered)

		for i = 1, pinLen do
			if pinCircles[i] ~= nil then
				pinCircles[i]:removeSelf()
				pinCircles[i] = nil
			end

			if i < 7 then
				pinCircles[i] = display.newCircle( 60+((i-1)*100), 200, 40 )
				pinCircles[i]:setStrokeColor( 23/255, 185/255, 178/255 )
				pinCircles[i]:setFillColor( 23/255, 185/255, 178/255 )
				pinCircles[i].strokeWidth = 2
				buttonGroup:insert(pinCircles[i])
			end
		end

		if string.len(PinEntered)==6 then
			PreviousButtonx = buttonGroup.x;
			_G.PinEntered = PinEntered
    		http.MakeNetworkCall(ManageLogin, "PinCheck",PinEntered)
		end 
	end 
end






function scene:enterScene(event)
	_G.HaltNav = nil

end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	
	group = self.view
	buttonGroup = display.newGroup()

	PinEntered = ""

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )
			
	
	local head = func.CreateStandardHeader(nil, nil, nil)
	group:insert(head)	
			
	
	local buttons = {}

	local c = 0
	local offsetx =  -120
	local offsety =  380
	

	for i = 1, 6 do
		local paint = { 23/255, 185/255, 178/255}
		pinCircles[i] = display.newCircle( 60+((i-1)*100), 200, 40 )
		pinCircles[i]:setStrokeColor( 23/255, 185/255, 178/255 )
		pinCircles[i].strokeWidth = 2
		buttonGroup:insert(pinCircles[i])
		--buttonGroup:insert(func.StandardImage("PINOff.png", 60+(i*100),200))
	end

	local EnterPin = func.SuperLabel({Caption="Enter PIN",Left=display.contentWidth / 2-90,Top=100,FontSize=40, Bold=1, Red=23/255, Green=185/255, Blue=178/255, Underline=0 })
	buttonGroup:insert( EnterPin )	

	for j = 0,10 do

		if j <= 9 then
			buttons[j] = widget.newButton
			{
				id = j,
				defaultFile = "Images/buttonDef.png",
				overFile = "Images/buttonOver.png",
				label = j,
				labelColor = 
				{ 
					default = { 51, 51, 51, 255 },
				},

				font="arial",
				fontSize = 26,
				emboss = true,
				onEvent = buttonHandler,
			}
		else if j == 10 then

			buttons[j] = widget.newButton
			{
				id = j,
				defaultFile = "Images/buttonDef.png",
				overFile = "Images/buttonOver.png",
				label = "X",
				labelColor = 
				{ 
					default = { 51, 51, 51, 255 },
				},

				font="arial",
				fontSize = 26,
				emboss = true,
				onEvent = DeletePin,
			}	
		end
	end

		if j == 0 then
			buttons[j].x = (display.contentWidth / 2) 
			buttons[j].y =(display.contentHeight /2 ) + 420
			buttons[j].width=200
			buttons[j].height =180
		elseif j == 10 then
			buttons[j].x = (display.contentWidth / 2)+220 
			buttons[j].y =(display.contentHeight /2 ) + 420
			buttons[j].width=200
			buttons[j].height =180	
		else
			buttons[j].x = ((j-(c*3))*220		) + offsetx
			buttons[j].y =(c * 200) + offsety
			buttons[j].width=200
			buttons[j].height =180
			if j % 3 == 0 then
				c = c + 1		
			end
		end
		buttonGroup:insert(buttons[j])
	end
	buttonGroup:insert(func.StandardImage("PinDeleteBox.png", display.contentWidth / 2+205 ,display.contentHeight /2 + 420,nil,nil,nil,0.4))
	group:insert(buttonGroup)
end





---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

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