--
-- Project: CareControlMobile2
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 . All Rights Reserved.
-- 
local func = require("functions")

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 0, 0, 0 )

_G.GUI = require("widget_candy")              -- LOAD WIDGET CANDY, USING A GLOBAL VAR, SO WE CAN ACCESS IT FROM ANY LOADED SAMPLE CODE, TOO
_G.GUI.LoadTheme("theme_1", "themes/theme_1/")-- LOAD THEME 1

local physicalW = math.round( (display.contentWidth  - display.screenOriginX*2) / display.contentScaleX)
local physicalH = math.round( (display.contentHeight - display.screenOriginY*2) / display.contentScaleY)
_G.isTablet     = false; if physicalW >= 1024 or physicalH >= 1024 then isTablet = true end
_G.GUIScale     = _G.isTablet == true and .5 or 1.0

_G.theme = "theme_1"


local storyboard = require "storyboard"
local func = require("functions")
local tmid

local ProblemOptions =
{
    effect = "slideLeft",
    time = 800, 
    params =""
}

local function myUnhandledErrorListener( event )
 
    local iHandledTheError = true
    if iHandledTheError then
        local params = {}
        params.eventError = event.errorMessage.. "###: " .. debug.traceback()
        params.httpWork = 0
        params.callType = ""
        params.screen = func.GetCurrentScreen()
        ProblemOptions.params = params
        storyboard.purgeAll()
        local LoadProblem = function() return storyboard.gotoScene( "problem", ProblemOptions, params ) end
        tmid = timer.performWithDelay( 300, LoadProblem, 1 )
           
    end
    
    return iHandledTheError
end
 
Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

local function onSystemEvent(event)
    if ((event.type == "applicationSuspend") and (_G.CameraLoaded == nil)) then
--        native.requestExit()
			--storyboard.gotoScene( "splash", "fade", 100 )
    end
    if ((event.type == "applicationResume") and (_G.CameraLoaded == nil)) then
    	--storyboard.gotoScene( "splash", "fade", 100 )
    end
end
Runtime:addEventListener("system", onSystemEvent)

local strict = require("strict")

-- local additionalData = {}
-- additionalData.message = 1221
-- Test("Jean Thomas has sent you a message!",additionalData)
storyboard.gotoScene( "Welcome", "fade", 1 )	
