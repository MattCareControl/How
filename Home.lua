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


local InitVariables = function()

	_G.VersionNumber = "1.0"
	_G.BackStructure = {}
end



function scene:enterScene(event)
	

-- Globals Init

end

function scene:createScene( event )
	
	group = self.view
	InitVariables()
	
	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )

	group:insert(func.StandardImage("Logo.png", display.contentWidth / 2,display.contentHeight / 2 - 150))

	group:insert(func.SuperLabel({Caption="Version: " .. _G.VersionNumber,Underline=1,FontSize=30,Bold=1,Left=640/ 2-80,Height=20,Top=960 / 2 + 500,Red=99/255,Green=37/255,Blue=35/255}))

	func.InitBackTable()
	func.PushBackEntry("splash",nil)
	
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