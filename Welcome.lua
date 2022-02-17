
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local group
local qMark
local QBlink
local QBlink2

local ImageList = {}

ImageList[1] = {}
ImageList[1].Image = "HowLogo1.png"
ImageList[1].x = 300
ImageList[1].y = 500

ImageList[2] = {}
ImageList[2].Image = "HowLogo2.png"
ImageList[2].x = 350
ImageList[2].y = 800

ImageList[3] = {}
ImageList[3].Image = "HowLogo3.png"
ImageList[3].x = 350
ImageList[3].y = 200

local InitVariables = function()

	_G.VersionNumber = "0.4"
	_G.BackStructure = {}
	_G.OverlayShow = false
	_G.NetworkCallOn = false
	_G.UseSSL = "s"
	_G.IPAddress = "media.carecontrolsystems.co.uk"
	_G.PortNumber = "443"
	_G.LoadStarting = 0
	_G.UserName = ""
	_G.CoachID = 0
	_G.LoginName = ""
	_G.UserCode = ""
	_G.GameGuid = ""
	_G.GameStructure = {}
	_G.CurrentQuestion = 0
	_G.NetworkID = 0
end

local HostClick = function(event)

	if event.phase == "ended" then

		func.LoadScreen("Host","crossFade",1000)
	end
	return true

end

local JoinClick = function(event)

	if event.phase == "ended" then

		func.LoadScreen("Join","crossFade",1000)
	end
	return true

end

local RegisterClick = function(event)

	if event.phase == "ended" then

		func.LoadScreen("Register","crossFade",1000)
	end
	return true

end

local ImgLoaded = {}

QBlink2 = function()

	
	transition.to( qMark, { time=1000, alpha=0,onComplete=QBlink } )
end

QBlink = function()

	
	transition.to( qMark, { time=1000, alpha=1,onComplete=QBlink2 } )
end

local FinishLoad = function()

	qMark = func.StandardImage("QMark.png",display.contentWidth/2,500)
	group:insert(qMark)

	qMark.alpha = 0
	local how = func.StandardImage("How.png",display.contentWidth/2,260)
	how.alpha = 0
	group:insert(how)

	func.LoadUserFile()

	local ButGrp = display.newGroup()
	ButGrp.alpha = 0
	if string.len(_G.LoginName) == 0 then
		ButGrp:insert( func.StandardImage("RegButton.png",display.contentWidth/2,800,RegisterClick,nil,nil,1.2))
	else
		ButGrp:insert(func.StandardLabelBold("Hi " .. _G.LoginName .. ",",60,790,50,91/255,155/255,213/255))
		ButGrp:insert( func.StandardImage("HostButton.png",display.contentWidth/2,920,HostClick,nil,nil,1.2))
		ButGrp:insert( func.StandardImage("JoinButton.png",display.contentWidth/2,1040,JoinClick,nil,nil,1.2))
	end
	group:insert(ButGrp)

	transition.to( qMark, { time=700, alpha=1,onComplete=QBlink } )
	transition.to( how, { time=2500,delay=1200, alpha=1 } )
	transition.to( ButGrp, { time=2500,delay=1500, alpha=1 } )
	_G.HaltNav = nil
end

function scene:enterScene(event)
	
	InitVariables()

	local listener1 = function()
		transition.to( ImgLoaded[1], { time=1000, alpha=0,transition=easing.outQuart } )
	end
	local listener2 = function()
		transition.to( ImgLoaded[2], { time=1000, alpha=0,transition=easing.outQuart } )
	end
	local listener3 = function()
		transition.to( ImgLoaded[3], { time=500, alpha=0,transition=easing.outQuart,onComplete=FinishLoad } )
	end
	transition.to( ImgLoaded[1], { time=700, alpha=1,xScale=1,yScale=1, onComplete=listener1,transition=easing.outQuart } )
	transition.to( ImgLoaded[2], { time=700, delay=300, alpha=1,xScale=1,yScale=1, onComplete=listener2,transition=easing.outQuart } )
	transition.to( ImgLoaded[3], { time=700, delay=600, alpha=1,xScale=1,yScale=1, onComplete=listener3,transition=easing.outQuart } )
end

function scene:createScene( event )
	
	group = self.view
	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )
	InitVariables()

	for i = 1, #ImageList do
		 ImgLoaded[i] = func.StandardImage(ImageList[i].Image,ImageList[i].x,ImageList[i].y,nil,nil,nil,0.95)
		 ImgLoaded[i].alpha = 0
		 ImgLoaded[i].xScale = 0.1
		 ImgLoaded[i].yScale = 0.1
		 group:insert(ImgLoaded[i])
	end

end

function scene:destroyScene( event )
	

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