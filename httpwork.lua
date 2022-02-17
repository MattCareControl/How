

local network = require("network")
local url = require("socket.url")
local storyboard = require( "storyboard" )
--local CCDB = require("Offline")

local resp = {}
local attempts
local _params = {}
local params = {}
local _command

local callType
local MakeGetCall, MakePostCall, ReportCall
local connectGroup

local ReportID,ReportFormat 


local OffGrp
--local waitText = display.newText( "Connecting to Care Control... Please wait...", 0, 0, "arial", 28 )
--waitText:setTextColor( 0 )
--waitText.x = 1024+ waitText.contentWidth * 0.5
--waitText.y = display.contentCenterY
--waitText.vis = 0



local problemsTable = {}

local ProblemOptions =
{
	effect = "slideLeft",
	time = 800,	
	params =""
}

local CloseWorkingOffline = function(event)
	
	if event.phase == "ended" then

		if OffGrp ~= nil then
			OffGrp:removeSelf()
			OffGrp = nil
		end	

	end
	return true

end

local DisplayWorkingOfflineMessage = function()
	
	if OffGrp ~= nil then
		OffGrp:removeSelf()
		OffGrp = nil
	end

	OffGrp = display.newGroup()
	local OfflineImg = display.newImage("Images/menuBackground.png")
	OfflineImg.x = display.contentWidth/2
	OfflineImg.y = display.contentHeight/2
	OffGrp:insert(OfflineImg)

	OfflineImg = display.newImage("Images/smallSadCloud.png")
	OfflineImg.x = display.contentWidth/2
	OfflineImg.y = display.contentHeight/2 - 230
	OffGrp:insert(OfflineImg)

    local lb1 = display.newText("There has been a problem connecting to Care Control.  This could be because you are out of WiFi signal.  You can continue to work Offline.  Remember to reconnect when you can to save any changes you may record.",0, 0, 400,0,native.systemFontBold,28 )
    lb1.x = 130 +  (lb1.contentWidth / 2)
    lb1.y = 550
	lb1:setFillColor(0,0,0)	
    OffGrp:insert(lb1)

    local lb2 = display.newText("Touch To Clear Message",0, 0, 430,0,native.systemFontBold,35 )
    lb2.x = 120 +  (lb2.contentWidth / 2)
    lb2.y = 800
	lb2:setFillColor(0,0,0)	
    OffGrp:insert(lb2)

    OffGrp:addEventListener("touch",CloseWorkingOffline)
end

local HideConnectingIcon = function()


	if connectGroup ~= nil then
		connectGroup:removeSelf()
		connectGroup = nil
	end

end

local MakeOfflineCall = function(callBack)

	local locParams = ""
	local event = {}
	event.isError = false
	_G.NetworkCallOn = false

	for i = 1,11 do
		if i > 1 and string.len(_params[i]) > 0 then
			locParams = locParams .. _params[i] .. ","
			--print(_params[i])
		end
	end
	if string.len(locParams) > 0 then
		locParams = string.sub(locParams,1,string.len(locParams)-1)
	end
	--print(_params[1] .. " - ")
	event.response = CCDB.GetDataSet(_params[1],locParams)
	if event.response == "*************NO FILE************" and _params[1] ~= "GetMonResidents2" then
   		local params = {}
   		params.eventError = "You are working offline.  The area you have tried to access is not currently available offline.  Try connecting to the internet and then this area again. Further details are: - " .. _params[1] .. " - " .. locParams
   		params.httpWork = 1
   		params.callType = callType
   		params.screen = "httpwork"
		HideConnectingIcon()
		ProblemOptions.params = params
		storyboard.gotoScene( "offlineProblem", ProblemOptions, params )	
	else
		if _G.WorkingOffline == 0 then
			CCDB.WriteOfflineFile()
			DisplayWorkingOfflineMessage()
			_G.WorkingOffline = 1
		end
		HideConnectingIcon()
		if _params[1] == "GetMonResidents2" and event.response == "*************NO FILE************" then
			event.response = ""
		end
		callBack(event)
	end

end

local OfflinePostCall = function(callBack)

	local event = {}
	event.isError = false

	local PostParams = params.body
    CCDB.StoreTranaction(_command,PostParams)
	if _G.WorkingOffline == 0 then
		DisplayWorkingOfflineMessage()
		_G.WorkingOffline = 1
	end
	event.response = "SUCCESS;COMPLETED;Completed"
	HideConnectingIcon()
	callBack(event)

end


local ShowConnectingIcon = function()

	if connectGroup ~= nil then
		connectGroup:removeSelf()
		connectGroup = nil
	end
	connectGroup = display.newGroup()
	local paint = { nil, nil, nil,0 }
	local rect = display.newRect( display.contentWidth/2, 1136/2,display.contentWidth, 1136 )
	rect.strokeWidth = 1
	rect.fill = paint	
	rect:setStrokeColor( 166/255, 166/255, 166/255 )

	rect:addEventListener("touch", function() return true end)
	rect:addEventListener("tap", function() return true end)

	connectGroup:insert(rect)
	local ConnectIcon = display.newImage("Images/connecting.png")
	ConnectIcon.x = ConnectIcon.width/2
	ConnectIcon.y = ConnectIcon.height/2
	connectGroup:insert(ConnectIcon)
end





local function networkListener( event )
		
	local ev = event
	
	if not ev.isError and string.find(ev.response, "HTTP Error 404. The requested resource is not found.") == nil then
		_G.NetworkCallOn = false
		--HideConnectingIcon()
		--print(ev.response)
        resp.callback(event)
   else
   		local params = {}
   		params.eventError = "There error is " .. ev.response
   		params.httpWork = 1
   		params.callType = callType
   		params.screen = "httpwork"
   		--print("Attempt " .. attempts)
		if attempts == 5 then	
			_G.NetworkCallOn = false	
			HideConnectingIcon()
			ProblemOptions.params = params
			storyboard.gotoScene( "problem", ProblemOptions, params )	
		else
			network.cancel( _G.NetworkID )
			attempts = attempts + 1
			if callType == "Get" then
				timer.performWithDelay( 5000, MakeGetCall )
			elseif callType == "Post" and _command ~= nil then
				timer.performWithDelay( 5000, MakePostCall )
			else
				_G.NetworkCallOn = false	
				HideConnectingIcon()	
				ProblemOptions.params = params	
				storyboard.gotoScene( "problem", ProblemOptions, params )	
			end
		end
	end
				   
end

local function NilToString (val)
	
	local ret = ""
	if val == nil then
		return ret
	else
		return val
	end

end






ReportCall = function()
	
local paramString
local params = {}
params.timeout  = 10	

	paramString = "UCode=" .. _G.SiteCode .. "&DevCode=" .. url.escape(_G.TabletName) .. "&SysCode=" .. _G.SystemCode
	paramString = paramString .. "&VersionNum=" .. url.escape(_G.VersionNumber) .. "&TabletName=" .. url.escape(_G.TabletName) .. "&ReportID=" .. ReportID .. "&RepFormat=" .. ReportFormat .. "&Param1=" .. url.escape(NilToString(_params[1])) .. "&Param2=" .. url.escape(NilToString(_params[2])).."&Param3=" .. url.escape(NilToString(_params[3])) .."&Param4=" .. url.escape(NilToString(_params[4])) .."&Param5=" .. url.escape(NilToString(_params[5])) .."&Param6=" .. url.escape(NilToString(_params[6])) .."&Param7=" .. url.escape(NilToString(_params[7]))

	--print("http://" .. _G.IPAddress  ..  ":" .. _G.PortNumber .. "/CareControl/CCReports.aspx?".. paramString)
	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://" .. _G.IPAddress  ..  ":" .. _G.PortNumber .. "/CareControl/CCReports.aspx?".. paramString, "GET", networkListener,params )
	
	
end


local function MakeReportCall(reportid,reportformat,callback,... )
	
	_G.NetworkCallOn = true
	--transition.to( waitText, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )	
	--waitText.vis = 1	
	ShowConnectingIcon()
	attempts = 1
	ReportID = reportid
	ReportFormat = reportformat
	resp.callback = callback
	callType = "Get"
	
	for i = 1,7 do
	_params[i] = NilToString(select(i,...))
	end
	ReportCall()
end



MakeGetCall = function()
	
local paramString
local params = {}
params.timeout  = 10	

	paramString = "Command=" .. _params[1] .. "&Param1=" .. url.escape(NilToString(_params[2])) .. "&Param2=" .. url.escape(NilToString(_params[3])).."&Param3=" .. url.escape(NilToString(_params[4])) .."&Param4=" .. url.escape(NilToString(_params[5])) .."&Param5=" .. url.escape(NilToString(_params[6])) .."&Param6=" .. url.escape(NilToString(_params[7])) .."&Param7=" .. url.escape(NilToString(_params[8])).."&Param8=" .. url.escape(NilToString(_params[9])).."&Param9=" .. url.escape(NilToString(_params[10])).."&Param10=" .. url.escape(NilToString(_params[11]))
	print("http" .. _G.UseSSL .. "://" .. _G.IPAddress  ..  ":" .. _G.PortNumber .. "/How/HowResponse.aspx?".. paramString)
	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://" .. _G.IPAddress  ..  ":" .. _G.PortNumber .. "/How/HowResponse?".. paramString, "GET", networkListener,params )
	
	
end

MakePostCall = function()

	--print( "http" .. _G.UseSSL .. "://" .. _G.IPAddress  ..  ":" .. _G.PortNumber ..  "/CareControl/ccSave2.aspx?Command=" .. _command)
	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://" .. _G.IPAddress  ..  ":" .. _G.PortNumber ..  "/CareControl/ccSave2.aspx?Command=" .. _command , "POST", networkListener, params )
end

local function MakeNetworkCall(callback,... )
	
	_G.NetworkCallOn = true
	--ShowConnectingIcon()
	attempts = 1
	resp.callback = callback
	callType = "Get"
	

	for i = 1,11 do
		_params[i] = NilToString(select(i,...))
	end


	MakeGetCall()

end

local function PostNetworkData (callback, postdata, command,...)

	local localpostdata
	
	_G.NetworkCallOn = true
	attempts = 1
	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	params = {}
	params.headers = headers
	--All posts start with the following base date
	localpostdata = "SiteCode=" .. url.escape(_G.SiteCode) .. "&DeviceName=" .. url.escape(_G.TabletName) .. "&SystemCode=" .. _G.SystemCode
	if (postdata ~= nil) then
		if (string.len(postdata) > 0) then
			localpostdata = localpostdata .. "&" .. postdata
		end
	end

    params.body = localpostdata	
    params.timeout = 10
    _command = command
    callType = "Post"
    --print(localpostdata)
	ShowConnectingIcon()
	resp.callback = callback

	if _G.WorkingOffline == 1 then
		OfflinePostCall(callback)
	else
		MakePostCall()
	end

	
end

local function ReSyncPost (callback, postdata, command)

	local localpostdata
	
	_G.NetworkCallOn = true
	attempts = 1
	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	params = {}
	params.headers = headers
    params.body = postdata	
    params.timeout = 10
    _command = command
    callType = "Post"

	ShowConnectingIcon()
	resp.callback = callback
	MakePostCall()

	
end

local function PostNetworkImage (callback,ImageType, idValue, StaffIndex,  ImageFile, CompRate, progress)

	_G.NetworkCallOn = true
	local paramString
	local headers = {}
	headers["Content-Type"] = "image/jpeg"
    headers["X-Parse-Application-Id"] = APPID
    headers["X-Parse-REST-API-Key"] = RESTAPIKEY	
	--headers["Accept-Language"] = "en-US"
 	
 	local params = {}
    params.headers = headers
    params.bodyType = "binary"
    if progress ~= nil then
    	params.progress = true
    end

	callType = "Upload"
	attempts = 1
	--transition.to( waitText, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )		
	--waitText.vis = 1
	ShowConnectingIcon()
	resp.callback = callback

	paramString = "SysID=" .. _G.SiteCode .. "&DevCode=" .. url.escape(_G.TabletName) .. "&SysCode=" .. _G.SystemCode .. "&CompressionRate=" .. CompRate
	_G.NetworkID = network.upload("http" .. _G.UseSSL .. "://" .. _G.IPAddress   ..  ":" .. _G.PortNumber ..  "/CareControl/ccSaveImage.aspx?" .. paramString .. "&ImageType=" .. ImageType .. "&ImageID=" .. idValue .. "&StaffIndex=" .. StaffIndex , "POST",networkListener,params,ImageFile,system.TemporaryDirectory)

end

local function PostNetworkImage2 (callback,ImageType, idValue, StaffIndex,  ImageFile, CompRate, progress)

	_G.NetworkCallOn = true
	local paramString
	local headers = {}
	headers["Content-Type"] = "image/jpeg"
    headers["X-Parse-Application-Id"] = APPID
    headers["X-Parse-REST-API-Key"] = RESTAPIKEY	
	--headers["Accept-Language"] = "en-US"
 	
 	local params = {}
    params.headers = headers
    params.bodyType = "binary"
    params.timeout = 300
    if progress ~= nil then
    	params.progress = true
    end
    
	--callType = "Upload"
	--attempts = 1
	--transition.to( waitText, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )		
	--waitText.vis = 1
	--resp.callback = callback

	paramString = "SysID=" .. _G.SiteCode .. "&DevCode=" .. url.escape(_G.TabletName) .. "&SysCode=" .. _G.SystemCode .. "&CompressionRate=" .. CompRate
	local issue = "http" .. _G.UseSSL .. "://" .. _G.IPAddress   ..  ":" .. _G.PortNumber ..  "/CareControl/ccSaveImage.aspx?" .. paramString .. "&ImageType=" .. ImageType .. "&ImageID=" .. idValue .. "&StaffIndex=" .. StaffIndex

	local rfilePath = system.pathForFile( "help.txt", system.DocumentsDirectory )
	local file = io.open( rfilePath, "w" )	
	file:write(issue)
	file:write("\n")
	io.close( file )
	file = nil

	network.upload("http" .. _G.UseSSL .. "://" .. _G.IPAddress   ..  ":" .. _G.PortNumber ..  "/CareControl/ccSaveImage.aspx?" .. paramString .. "&ImageType=" .. ImageType .. "&ImageID=" .. idValue .. "&StaffIndex=" .. StaffIndex , "POST",callback,params,ImageFile,system.TemporaryDirectory)

end

local function CheckInternetConnection(callback)


	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	params = {}
	params.headers = headers
	params.body = ''
    params.timeout = 10
    callType = "Post"
    --print("called")
	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://robust.carecontrolsystems.co.uk/Director/directme.aspx", "POST", callback, params )

end

local function ConfigIPAddress(callback, OverrideCode)
	
	--[[.NetworkCallOn = true
	resp.callback = callback

	network.request( "http" .. _G.UseSSL .. "://portal.carecontrolbusiness.co.uk/hgsy235kjls876.php", "GET", networkListener )
	]]
	local localpostdata
	
	_G.NetworkCallOn = true
	attempts = 1
	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	params = {}
	params.headers = headers
	--All posts start with the following base date
	if OverrideCode == nil then
		localpostdata = "UserCode=" .. url.escape(_G.SiteCode) 
		--print(localpostdata)
	else
		localpostdata = "UserCode=" .. url.escape(OverrideCode) 
	end
    params.body = localpostdata	
    params.timeout = 10
  --  _command = command
    callType = "Post"
    ShowConnectingIcon()
	resp.callback = callback

	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://robust.carecontrolsystems.co.uk/Director/directme.aspx", "POST", networkListener, params )
			


end

local function GetCode(callback, Type, ParentCode, Description)

	local localpostdata
	
	_G.NetworkCallOn = true
	attempts = 1
	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	params = {}
	params.headers = headers
	--All posts start with the following base date
	localpostdata = "CodeType=" .. url.escape(Type) .. "&ParentCode=" .. url.escape(ParentCode)   .. "&Description=" .. url.escape(Description)
    params.body = localpostdata	
    params.timeout = 20
    _command = command
    callType = "Post"
    ShowConnectingIcon()
	resp.callback = callback

	_G.NetworkID = network.request( "http" .. _G.UseSSL .. "://safe.carecontrolsystems.co.uk/Director/fixmeup.aspx", "POST", networkListener, params )
			

end

local function DownloadImage(ImageType,ImageID, ImagePrefix, SaveDirectory,callBack)


	local pString
	pString = "UCode=" .. _G.SiteCode .. "&DevCode=" .. url.escape(_G.TabletName) .. "&SysCode=" .. _G.SystemCode
	
	network.download( "http" .. _G.UseSSL .. "://".. _G.IPAddress  .. ":" .. _G.PortNumber .. "/CareControl/ShowImage.ashx?" .. pString .. "&ImageType=" .. ImageType .. "&ImageID=" .. ImageID .. "&StaffID=1", "GET", callBack, ImagePrefix .. ImageID .. ".jpg", SaveDirectory)


end

resp.MakeNetworkCall = MakeNetworkCall
resp.PostNetworkData = PostNetworkData
resp.ConfigIPAddress = ConfigIPAddress
resp.PostNetworkImage = PostNetworkImage
resp.PostNetworkImage2 = PostNetworkImage2
resp.MakeReportCall = MakeReportCall
resp.GetCode = GetCode
resp.DownloadImage = DownloadImage
resp.ReSyncPost = ReSyncPost
resp.CheckInternetConnection = CheckInternetConnection

return resp

