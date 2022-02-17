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

local LoadDetail = function(event)
	
	local id

	if event.phase == "ended" then
		id = event.target.id

		local sp ={
		    ActivityID = id
		}
		func.LoadScreen("ActivityDetail", "slideLeft",sp)

	end
	return true
end


function scene:enterScene(event)
	

	group:insert(func.StandardImage("SaturdayCoaching.png", 320,280,LoadDetail,1))
	group:insert(func.StandardImage("SaturdayRide.png", 320,600,LoadDetail,2))
	--group:insert(func.StandardImage("Rollers.png", 300,930,LoadDetail,3))
	_G.HaltNav = nil
end

function scene:createScene( event )
	
	group = self.view
	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )


	group:insert(func.CreateStandardHeader(nil, nil))
	--group:insert(func.SuperLabel({Caption="Select Activity:",Underline=0,FontSize=30,Bold=1,Left=20,Height=20,Top=100,Red=99/255,Green=37/255,Blue=35/255}))


	
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