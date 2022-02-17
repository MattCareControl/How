	--
	-- Project: CareControlPortal
	-- Description: 
	--
	-- Version: 1.0
	-- Managed with http://CoronaProjectManager.com
	--
	-- Copyright 2014 . All Rights Reserved.
	-- 
	
	local widget = require( "widget" )
	local storyboard = require( "storyboard" )
	local http = require("httpwork")
	local date = require("date")
	local url = require("socket.url")
	local lfs = require("lfs")
	--local CCDB = require("Offline")
	local ReturnTable={}
	local OverlayShow
	local DrawLine
	local CreateListView
	local StandardTextBox
	local StandardImage
	local FadeScreen
	local SmallButton
	local PushBackEntry
	local GoBack
	local PopBackEntry
	local LoadScreen
	local WideButton2
	local _loading
	local _loadingStatus
	local fdScreen
	local AlertWindow
	local ShowSimpleAlert
	local OffGrp

system.activate( "multitouch" )

local isDevice = false -- (system.getInfo("model") == "iPhone")

function lengthOf( a, b )

    local width, height = b.x-a.x, b.y-a.y

    return (width*width + height*height)^0.5

end



-- returns the degrees between (0,0) and pt

-- note: 0 degrees is 'east'

function angleOfPoint( pt )

	local x, y = pt.x, pt.y

	local radian = math.atan2(y,x)

	local angle = radian*180/math.pi

	if angle < 0 then angle = 360 + angle end

	return angle

end



-- returns the degrees between two points

-- note: 0 degrees is 'east'

function angleBetweenPoints( a, b )

	local x, y = b.x - a.x, b.y - a.y

	return angleOfPoint( { x=x, y=y } )

end



-- returns the smallest angle between the two angles

-- ie: the difference between the two angles via the shortest distance

function smallestAngleDiff( target, source )

	local a = target - source

	

	if (a > 180) then

		a = a - 360

	elseif (a < -180) then

		a = a + 360

	end

	

	return a

end



-- rotates a point around the (0,0) point by degrees

-- returns new point object

function rotatePoint( point, degrees )

	local x, y = point.x, point.y

	

	local theta = math.rad( degrees )

	

	local pt = {

		x = x * math.cos(theta) - y * math.sin(theta),

		y = x * math.sin(theta) + y * math.cos(theta)

	}



	return pt

end



-- rotates point around the centre by degrees

-- rounds the returned coordinates using math.round() if round == true

-- returns new coordinates object

function rotateAboutPoint( point, centre, degrees, round )

	local pt = { x=point.x - centre.x, y=point.y - centre.y }

	pt = rotatePoint( pt, degrees )

	pt.x, pt.y = pt.x + centre.x, pt.y + centre.y

	if (round) then

		pt.x = math.round(pt.x)

		pt.y = math.round(pt.y)

	end

	return pt

end







-- calculates the average centre of a list of points

local function calcAvgCentre( points )

	local x, y = 0, 0

	

	for i=1, #points do

		local pt = points[i]

		x = x + pt.x

		y = y + pt.y

	end

	

	return { x = x / #points, y = y / #points }

end



-- calculate each tracking dot's distance and angle from the midpoint

local function updateTracking( centre, points )

	for i=1, #points do

		local point = points[i]

		

		point.prevAngle = point.angle

		point.prevDistance = point.distance

		

		point.angle = angleBetweenPoints( centre, point )

		point.distance = lengthOf( centre, point )

	end

end



-- calculates rotation amount based on the average change in tracking point rotation

local function calcAverageRotation( points )

	local total = 0

	

	for i=1, #points do

		local point = points[i]

		total = total + smallestAngleDiff( point.angle, point.prevAngle )

	end

	

	return total / #points

end



-- calculates scaling amount based on the average change in tracking point distances

local function calcAverageScaling( points )

	local total = 0

	

	for i=1, #points do

		local point = points[i]

		total = total + point.distance / point.prevDistance

	end

	

	return total / #points

end







-- creates an object to be moved

function newTrackDot(e)


	local circle = display.newCircle( e.x, e.y, 50 )
	circle.alpha = .5
	local rect = e.target

	

	-- standard multi-touch event listener

	function circle:touch(e)

		-- get the object which received the touch event

		local target = circle

		

		-- store the parent object in the event

		e.parent = rect

		

		-- handle each phase of the touch event life cycle...

		if (e.phase == "began") then

			-- tell corona that following touches come to this display object

			display.getCurrentStage():setFocus(target, e.id)

			-- remember that this object has the focus

			target.hasFocus = true

			-- indicate the event was handled

			return true

		elseif (target.hasFocus) then

			-- this object is handling touches

			if (e.phase == "moved") then

				-- move the display object with the touch (or whatever)

				target.x, target.y = e.x, e.y

			else -- "ended" and "cancelled" phases

				-- stop being responsible for touches

				display.getCurrentStage():setFocus(target, nil)

				-- remember this object no longer has the focus

				target.hasFocus = false

			end

			

			-- send the event parameter to the rect object

			rect:touch(e)

			

			-- indicate that we handled the touch and not to propagate it

			return true

		end

		

		-- if the target is not responsible for this touch event return false

		return false

	end

	

	-- listen for touches starting on the touch layer

	circle:addEventListener("touch")

	

	-- listen for a tap when running in the simulator

	function circle:tap(e)

		if (e.numTaps == 2) then

			-- set the parent

			e.parent = rect

			

			-- call touch to remove the tracking dot

			rect:touch(e)

		end

		return true

	end

	

	-- only attach tap listener in the simulator


	

	-- pass the began phase to the tracking dot

	circle:touch(e)

	

	-- return the object for use

	return circle

end






function touch(self, e)

	-- get the object which received the touch event

	local target = e.target

	

	-- get reference to self object

	local rect = self

	

	-- handle began phase of the touch event life cycle...

	if (e.phase == "began") then

		--print( e.phase, e.x, e.y )

		

		-- create a tracking dot

		local dot = newTrackDot(e)

		

		-- add the new dot to the list

		rect.dots[ #rect.dots+1 ] = dot

		

		-- pre-store the average centre position of all touch points

		rect.prevCentre = calcAvgCentre( rect.dots )

		

		-- pre-store the tracking dot scale and rotation values

		updateTracking( rect.prevCentre, rect.dots )

		

		-- we handled the began phase

		return true

	elseif (e.parent == rect) then

		if (e.phase == "moved") then

			--print( e.phase, e.x, e.y )

			

			-- declare working variables

			local centre, scale, rotate = {}, 1, 0

			

			-- calculate the average centre position of all touch points

			centre = calcAvgCentre( rect.dots )

			

			-- refresh tracking dot scale and rotation values

			updateTracking( rect.prevCentre, rect.dots )

			

			-- if there is more than one tracking dot, calculate the rotation and scaling

			if (#rect.dots > 1) then

				-- calculate the average rotation of the tracking dots

				rotate = calcAverageRotation( rect.dots )

				

				-- calculate the average scaling of the tracking dots

				scale = calcAverageScaling( rect.dots )

				

				-- apply rotation to rect

				--rect.rotation = rect.rotation + rotate

				

				-- apply scaling to rect

				rect.xScale, rect.yScale = rect.xScale * scale, rect.yScale * scale

			end

			

			-- declare working point for the rect location

			local pt = {}

			

			-- translation relative to centre point move

			pt.x = rect.x + (centre.x - rect.prevCentre.x)

			pt.y = rect.y + (centre.y - rect.prevCentre.y)

			

			-- scale around the average centre of the pinch

			-- (centre of the tracking dots, not the rect centre)

			pt.x = centre.x + ((pt.x - centre.x) * scale)

			pt.y = centre.y + ((pt.y - centre.y) * scale)

			

			-- rotate the rect centre around the pinch centre

			-- (same rotation as the rect is rotated!)

			--pt = rotateAboutPoint( pt, centre, rotate, false )

			

			-- apply pinch translation, scaling and rotation to the rect centre

			rect.x, rect.y = pt.x, pt.y

			

			-- store the centre of all touch points

			rect.prevCentre = centre

		else -- "ended" and "cancelled" phases

			--print( e.phase, e.x, e.y )

			

			-- remove the tracking dot from the list

			if (_G.PinchMode == "Yes" or e.numTaps == 2) then --isdevice

				-- get index of dot to be removed

				local index = table.indexOf( rect.dots, e.target )

				

				-- remove dot from list

				table.remove( rect.dots, index )

				

				-- remove tracking dot from the screen

				e.target:removeSelf()

				

				-- store the new centre of all touch points

				rect.prevCentre = calcAvgCentre( rect.dots )

				

				-- refresh tracking dot scale and rotation values

				updateTracking( rect.prevCentre, rect.dots )

			end

		end

		return true

	end

	return false

end
	
	local function split(pString, pPattern)
	   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	   local fpat = "(.-)" .. pPattern
	   local last_end = 1
	   local s, e, cap = pString:find(fpat, 1)

	   while s do
	     -- if s ~= 1 or cap ~= "" then

	         table.insert(Table,cap)
	     -- end
	      last_end = e+1
	      s, e, cap = pString:find(fpat, last_end)
	   end
	   if last_end <= #pString then
	      cap = pString:sub(last_end)

	      table.insert(Table, cap)
	  end
	 
	   return  Table
	end
	
	local function StandardNumericField(centrex, centrey,widthx, inputType)
	
		local isAndroid = "Android" == system.getInfo( "platformName" )
		local inputFontSize = 18
		local tHeight = 30
		
		if ( isAndroid ) then
		    inputFontSize = inputFontSize - 4
		    tHeight = tHeight + 10
		end
		
		local codeField = native.newTextField( centrex, centrey, widthx, tHeight )
		codeField.align = "right"
		codeField.inputType = inputType
	    codeField.hasBackground = true
	    codeField.font=native.newFont("arial", inputFontSize )
	    codeField:setTextColor(20/255, 20/255, 20/255)		
		
		return codeField
		
	end	
	
	local function StandardTextField(centrex, centrey,widthx,fontSize, tHeight)
	
		local isAndroid = "Android" == system.getInfo( "platformName" )
		local inputFontSize
		if fontSize ~= nil then
			inputFontSize = fontSize
		else
			inputFontSize = 17
		end
		
		if tHeight == nil then
			tHeight = inputFontSize + 13
		end

		if ( isAndroid ) then
		    inputFontSize = inputFontSize - 4
		    tHeight = tHeight + 15
		end
	
		local codeField = native.newTextField( centrex, centrey, widthx, tHeight )
	    codeField.hasBackground = true
	    codeField.font=native.newFont("arial", inputFontSize )
	    codeField:setTextColor(20/255, 20/255, 20/255)		
		
		return codeField
		
	end
	
		local function StandardTextBox2(centrex, centrey,widthx)
	
		local isAndroid = "Android" == system.getInfo( "platformName" )
		local inputFontSize = 17
		local tHeight = 30
	
		if ( isAndroid ) then
		    inputFontSize = inputFontSize - 4
		    tHeight = tHeight + 15
		end
	
		local codeField = native.newTextBox( centrex, centrey, widthx, tHeight )
	    codeField.hasBackground = true
	    codeField.font=native.newFont("arial", inputFontSize )
	    codeField:setTextColor(20/255, 20/255, 20/255)		
		
		return codeField
		
	end
	local function CreateBox(centrex, centrey,widthx, heightx, listener, id, stWidth)
		

		local fieldBox = display.newRect( centrex, centrey,widthx, heightx )
		if stWidth ~= nil then
			fieldBox.strokeWidth = stWidth + 1
		else
			fieldBox.strokeWidth = 2
		end
		
		fieldBox:setFillColor( 1 )
		
		if listener ~= nil then
			fieldBox:addEventListener("touch",listener)
		end	
		  if id ~= nil then
		    	fieldBox.id = id
		  end		
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		return fieldBox
		
	end		

	local function CreateBox2(centrex, centrey,widthx, heightx, red, green, blue,clear, swidth, sred, sgreen, sblue, alpha, listener, id)
	
		local paint = { red, green, blue}
		local paintTransparent = {red, green, blue, 0}
		local rect = display.newRect( centrex, centrey,widthx, heightx )
		rect.x = centrex + widthx/2
		if swidth == nil then
			swidth = 1
		end
		
		if clear == nil then
			rect.strokeWidth = swidth+1
			rect.fill = paint	
			if sred == nil then
				rect:setStrokeColor( 166/255, 166/255, 166/255 )
			else
				rect:setStrokeColor( sred, sgreen, sblue )
			end
		else
			rect.fill = paintTransparent
			rect.strokeWidth = swidth + 1
			rect:setStrokeColor( red, green, blue )
		end

		if id ~= nil  then
			rect.id = id
		end

		if listener ~= nil then
			rect:addEventListener("touch",listener)
		end	

		if alpha ~= nil then
			rect.alpha = alpha
		end
		
		return rect
		
	end		

	local function CreateRoundBox(centrex, centrey,widthx, heightx, red, green, blue,clear, swidth, corners, listener, id,fred,fgreen,fblue)
	
		local cn

		if corners == nil then
			cn = 6
		else
			cn = corners
		end

		local paint = { red, green, blue }
		local rect = display.newRoundedRect( centrex, centrey,widthx, heightx,cn )
		rect.x = centrex + widthx/2

		if clear == nil then
			rect.strokeWidth = swidth + 1
			rect.fill = paint	
			rect:setStrokeColor( 166/255, 166/255, 166/255 )
		else
			rect.strokeWidth = swidth + 1
			rect:setStrokeColor( red, green, blue )
		end
		if fred ~= nil then
			rect:setFillColor(fred,fgreen,fblue)
		end

		if id ~= nil then
			rect.id = id
		end
		if listener ~= nil then
			rect:addEventListener("touch",listener)
		end	
		
		return rect
		
	end		
	
	StandardTextBox = function (centrex, centrey,widthx, heightx, inputListener)
	
		local isAndroid = "Android" == system.getInfo( "platformName" )
		local inputFontSize = 27
		local tHeight = heightx
	
		if ( isAndroid ) then
		    inputFontSize = inputFontSize - 2
		    tHeight = tHeight + 10
		end
	
		
		local codeField = native.newTextBox( centrex, centrey, widthx, tHeight, inputListener )
	  --  codeField.hasBackground = true
	    codeField.isEditable = true
	  --  codeField:setReturnKey("done")
	    codeField.font=native.newFont("arial", inputFontSize )
	    codeField:setTextColor(20/255, 20/255, 20/255)		
		
		return codeField
		
	end	
	
	local function StandardLabel(LabelText, FontSize)

		    local lb7 = display.newText( LabelText,0, 0, "arial",FontSize )
			lb7:setFillColor( 120/255, 0/255, 4/255)	
		return lb7
	end
	

	local function StandardLabel2(LabelText, posX, posY, FontSize, red, green, blue, listener)
		
			if LabelText == nil then
				LabelText = ""
			end
		    local lb7 = display.newText( LabelText,0, 0, "arial",FontSize )
		    lb7.x = posX +  (lb7.contentWidth / 2)
		    lb7.y = posY

		    if red ~= nil then
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(135/255,122/255, 123/255)	
		    end
		    if listener ~= nil then
				lb7:addEventListener("touch",listener)
		    end		    
		    
		return lb7
	end	

	local function StandardLabel2w(LabelText, posX, posY, width, FontSize, red, green, blue, listener, id)
		
			if LabelText == nil then
				LabelText = ""
			end
		    local lb7 = display.newText( LabelText,0, 0,width,0, "arial",FontSize)
		    lb7.x = posX +  (lb7.contentWidth / 2)
		    lb7.y = posY --+  (lb7.contentHeight / 2) - 10

		    if red ~= nil then
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(135/255,122/255, 123/255)	
		    end
		    if listener ~= nil then
				lb7:addEventListener("touch",listener)
				if id ~= nil then
					lb7.id = id
				end
		    end		    
		    
		return lb7
	end
	local function 	StandardLabelBold(LabelText, posX, posY, FontSize, red, green, blue, listener, id, centreText)
		
		local isAndroid = "Android" == system.getInfo( "platformName" )
	--	if ( isAndroid ) then
	--	    FontSize = FontSize - 2
	--	end		

		    local lb7 = display.newText( LabelText,0, 0, native.systemFontBold,FontSize )
		    if posX < 0 then --  this means centre the text
		    	lb7.x = display.contentWidth/ 2
		    elseif centreText == nil then
		    	lb7.x = posX +  (lb7.contentWidth / 2)
		    else
		    	lb7.x = posX
		    end
		    lb7.y = posY
		  -- print("colour of red" .. red)
		    if red ~= nil then
		    	if red > 1.1 then
		    		red = red / 255
		    		green = green / 255
		    		blue = blue / 255
		    	end
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(1,1, 1)	
		    end
		    if listener ~= nil then
				lb7:addEventListener("touch",listener)
		    end		    
		    
		    if id ~= nil then
		    	lb7.id = id
		    end
		    
		return lb7
	end		



	local function StandardLabelBoldW(LabelText, posX, posY, width, FontSize, red, green, blue, listener, id,centre)
		
		    local lb7 = display.newText( LabelText,0, 0, width,0,native.systemFontBold,FontSize )
		    if centre ~= nil then
		    	lb7.x = posX --+  (lb7.contentWidth / 2)
		    else
		    	lb7.x = posX +  (lb7.contentWidth / 2)
		    end
		    lb7.y = posY

		    if red ~= nil then
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(1,1, 1)	
		    end
		    if listener ~= nil then
				lb7:addEventListener("touch",listener)
		    end		    
		    
		    if id ~= nil then
		    	lb7.id = id
		    end
		    
		return lb7
	end	

	local function StandardLabelBoldWNew(LabelText, posX, posY, width, FontSize,align, red, green, blue, listener, id)	

		local al

		if align == nil then
			al = "left"
		else
			al = align
		end

		local options = 
		{
		    text = LabelText,     
		    x = posX,
		    y = posY,
		    width = width,
		    font = native.systemFont,   
		    fontSize = FontSize,
		    align = al
		}
 
		local myText = display.newText( options )

	    if red ~= nil then
			myText:setFillColor(red,green, blue)	
		else
			myText:setFillColor(1,1, 1)	
	    end

	    if listener ~= nil then
			myText:addEventListener("touch",listener)
	    end		    
	    
	    if id ~= nil then
	    	myText.id = id
	    end

	   	return myText
	end

	local function MultilineLabel(LabelText, posX, posY, width, height, FontSize, red, green, blue, withScroll,listener, pid)
		

		local isAndroid = "Android" == system.getInfo( "platformName" )

		if ( isAndroid ) then
		    FontSize = FontSize - 1
		end			
			local lb7
			if withScroll ~= nil then
			    lb7 = display.newText( LabelText,0,0,width, 0, "arial",FontSize )
			 else
			 	lb7 = display.newText( LabelText,0,0,width, height, "arial",FontSize )
			end
		    lb7.x = posX +  (lb7.contentWidth / 2)
		    lb7.y = posY
		    if red ~= nil then
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(1,1, 1)	
		    end
		    if listener ~= nil then
				lb7:addEventListener("touch",listener)
				lb7.param = pid
		    end	
		    
			if withScroll ~= nil then
				
				local scrollView = widget.newScrollView
				{
					x =posX + (width / 2) ,
					y = posY,--row.contentHeight * 0.5,
					width = width ,
					height =height,
					scrollHeight =0,
					horizontalScrollDisabled = true,
					verticalScrollDisabled = false,
					hideScrollBar = false,
					hideBackground = true					
				}
				
				lb7.x = lb7.contentWidth / 2
				lb7.y = lb7.contentHeight / 2
				
				scrollView:insert( lb7 )	
				return scrollView
			else
			return lb7
			end			   	    
		    
		
	end		


	local _MultiLineEdits = {}
	local _EditGroup 

	local DestroyMultiLineEdits = function()

		for i = 1,#_MultiLineEdits do
			if _MultiLineEdits[i].Label ~= nil then
				_MultiLineEdits[i].Label:removeSelf()
				_MultiLineEdits[i].Label = nil
			end
			
		end

		for i = 1,#_MultiLineEdits do
			table.remove(_MultiLineEdits)
		end		


	end

	local DestroyAMultiLineEdits = function(n)

		local i
		if n == -1 then
			i = #_MultiLineEdits
		else
			i = n
		end

		if _MultiLineEdits[i].Label ~= nil then
			_MultiLineEdits[i].Label:removeSelf()
			_MultiLineEdits[i].Label = nil
		end

		table.remove(_MultiLineEdits, i)

	end	


	local function _CancelEditor(event)

		if event.phase == "ended" then


			for i=1,_EditGroup.numChildren do
			    local child = _EditGroup[1]
			    child:removeSelf()
			    child = nil
			end 
			if _EditGroup ~=nil then
				_EditGroup:removeSelf()
				_EditGroup = nil

			end
			native.setKeyboardFocus( nil )
		end
		return true
	end


	local _UpdateMultiEditor = function(event)


		local t = event.target
		if event.phase == "ended"  and _G.NetworkCallOn == false  then 

			if _MultiLineEdits[t.id].Label ~= nil then
				_MultiLineEdits[t.id].Label:removeSelf()
				_MultiLineEdits[t.id].Label = nil
			end

			--print(_MultiLineEdits[t.id].TextBox.text)

			local lb7
		    lb7 = display.newText( _MultiLineEdits[t.id].TextBox.text ,0,0,_MultiLineEdits[t.id].Width, 0,"arial" ,_MultiLineEdits[t.id].FontSize )

			lb7.x = lb7.contentWidth / 2 + 5
			lb7.y = lb7.contentHeight / 2 + 5
			lb7:setFillColor(0,0, 0)
			_MultiLineEdits[t.id].LabelText = _MultiLineEdits[t.id].TextBox.text 
			_MultiLineEdits[t.id].Group:insert(lb7)
			_MultiLineEdits[t.id].Label = lb7

			if _MultiLineEdits[t.id].SaveListener ~= nil then
				_MultiLineEdits[t.id].SaveListener(t.id, _MultiLineEdits[t.id].id)
			end
			if _MultiLineEdits[t.id].TextBox ~= nil then
				_MultiLineEdits[t.id].TextBox:removeSelf()
				_MultiLineEdits[t.id].TextBox = nil
			end
			_CancelEditor({phase="ended"})
		  end	
		  return true	
	end



 local _simpleEditChars = function ( event )

 	local finalString, char
 	local alc
 	local point
 	point = 0
 	alc = event.target.allowedChars
	if ( event.phase == "editing" ) then
		finalString = ""--string.sub(event.target.text,1,string.len(event.target.text)-1)
		for char in string.gfind(event.text, "([%z\1-\127\194-\244][\128-\191]*)") do
			if string.find(alc,char) ~= nil then
				if alc == "0123456789." then
					if char == "." then
						point = point + 1
					end
				end
				if char == "." and point < 2 then
					finalString = finalString .. char
				elseif char ~= "." then
					finalString = finalString .. char
				end
    		end
    	end
    	event.target.text = finalString
    end
end

local function ShowSimpleEdit(UpdateFunction,type,defValue)




	local NewEditGroup, alc
	NewEditGroup = display.newGroup( )

	NewEditGroup:insert(FadeScreen())
	NewEditGroup:insert(CreateBox2(display.contentWidth/2 - 500/2 - 5,80,500+10,45,0,0,0,1,2)	)	
	local txtBox = StandardTextField(display.contentWidth/2,80,500,14)
	if defValue ~= nil then
	--	print(defValue)
		txtBox.text = defValue
	end

	if type == nil then
		alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'.,!£%*@<>?/+="
	elseif type == "restrict" then
		alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 +"			
	elseif type == "number" then
		alc = "0123456789"
	elseif type == "IPnumber" then
		alc = "0123456789."			
	elseif type == "email" then
		alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-@._"	
	elseif type == "web" then
		alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:/."			
	elseif type == "decimal" then
		alc = "0123456789."		
	elseif type == "date" then
		alc = "0123456789/"		
	elseif type == "time" then
		alc = "0123456789:"										
	else
		alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'.,!£%*@<>?/"
	end

	txtBox.allowedChars = alc
	txtBox:addEventListener( "userInput", _simpleEditChars )
	native.setKeyboardFocus( txtBox )
	txtBox:setSelection( 9999, 9999 )
	NewEditGroup:insert(txtBox)
	NewEditGroup:insert(SmallButton("Cancel",UpdateFunction,1,670,160))
	NewEditGroup:insert(SmallButton("OK",UpdateFunction,2,780,160))
	return NewEditGroup

end

	local function _ShowMultiEditor(event)


local t = event.target
		if event.phase == "ended"  and _G.NetworkCallOn == false  then 

		if _EditGroup ~= nil then
			_EditGroup:removeSelf()
			_EditGroup = nil
		end


		_EditGroup = display.newGroup( )

		_EditGroup:insert(FadeScreen())
		_EditGroup:insert(CreateBox2(display.contentWidth/2 - 500/2 - 5,180,500+10,340+10,0,0,0,nil,2)	)	
		local txtBox = StandardTextBox(display.contentWidth/2,180,500,340)

		--print("Edit ID " .. t.id)
		--print(#_MultiLineEdits)
		txtBox.text  = _MultiLineEdits[t.id].LabelText
		native.setKeyboardFocus( txtBox )
		txtBox:setSelection( 9999, 9999 )
		_MultiLineEdits[t.id].TextBox = txtBox
		_EditGroup:insert(txtBox)
		_EditGroup:insert(WideButton2("Cancel",_CancelEditor,t.id,150,400))
		_EditGroup:insert(WideButton2("OK",_UpdateMultiEditor,t.id,500,400))

	end

	return true
end

local function GetMultiLineText(EditNumber)

	if EditNumber > #_MultiLineEdits then
		return ""
	else
		return _MultiLineEdits[EditNumber].LabelText
	end


end

local function SetMultiLineText(EditNumber,Text, Append)

	if Append == nil then
		Append = 0
	end

	if Append == 1 and string.len(_MultiLineEdits[EditNumber].LabelText) > 0 then
		Text = _MultiLineEdits[EditNumber].LabelText .. "\r\n" .. Text
	end
	if EditNumber <= #_MultiLineEdits then
		if _MultiLineEdits[EditNumber].Label ~= nil then
			_MultiLineEdits[EditNumber].Label:removeSelf()
			_MultiLineEdits[EditNumber].Label = nil
		end

		--print(_MultiLineEdits[t.id].TextBox.text)

		local lb7
	    lb7 = display.newText( Text ,0,0,_MultiLineEdits[EditNumber].Width, 0,"arial" ,_MultiLineEdits[EditNumber].FontSize )

		lb7.x = lb7.contentWidth / 2 + 5
		lb7.y = lb7.contentHeight / 2 + 5
		lb7:setFillColor(0,0, 0)
		_MultiLineEdits[EditNumber].LabelText = Text
		_MultiLineEdits[EditNumber].Group:insert(lb7)
		_MultiLineEdits[EditNumber].Label = lb7
	end


end

local function GetMultiLineMax()


	return #_MultiLineEdits

end

	local function MultilineLabelEdit(LabelText, posX, posY, width, height, FontSize, red, green, blue, SaveListener, id)
		

	local LabGroup = display.newGroup( )


			LabGroup:insert(CreateBox2(posX,posY,width+10,height+10,1,1,1,nil,1,0,0,0))


			local lb7
		    lb7 = display.newText( LabelText,0,0,width, 0, "arial",FontSize )

		    lb7.x = posX +  (lb7.contentWidth / 2)
		    lb7.y = posY
		    if red ~= nil then
				lb7:setFillColor(red,green, blue)	
			else
				lb7:setFillColor(0,0,0)	
		    end


			
			local scrollView = widget.newScrollView
			{
				x =posX + (width / 2) ,
				y = posY,--row.contentHeight * 0.5,
				width = width ,
				height =height,
				scrollHeight =0,
				horizontalScrollDisabled = true,
				verticalScrollDisabled = false,
				hideScrollBar = false,
				hideBackground = true					
			}
			
			lb7.x = lb7.contentWidth / 2 + 5
			lb7.y = lb7.contentHeight / 2 + 5
			
			scrollView:insert( lb7 )	
			LabGroup:insert(scrollView)

			_MultiLineEdits[#_MultiLineEdits+1] = {}
			_MultiLineEdits[#_MultiLineEdits].Label = lb7
			_MultiLineEdits[#_MultiLineEdits].LabelText = LabelText
			_MultiLineEdits[#_MultiLineEdits].Group = scrollView
			_MultiLineEdits[#_MultiLineEdits].Width = width
			_MultiLineEdits[#_MultiLineEdits].FontSize = FontSize
			_MultiLineEdits[#_MultiLineEdits].SaveListener = SaveListener
			_MultiLineEdits[#_MultiLineEdits].id = id

			LabGroup:insert(StandardImage("EditButton.png",posX + width - 26,posY - (height / 2) + 29,_ShowMultiEditor,#_MultiLineEdits,nil,1.1))
			
			return LabGroup
		   	    
		    
		
	end			

	local function SuperLabel(Props)
		
		local gr = display.newGroup()

		local MyLabel
		local ht
----print(Props.Caption)

		local isAndroid = "Android" == system.getInfo( "platformName" )

		local h = display.contentScaleY

	--	if h ~= 1 then
	 --   	Props.FontSize = Props.FontSize - 2
	--    end
		--    if Props.Height ~= nil then
		--    	Props.Height = Props.Height / factor
		--    end
		--end		
		--Props.Height = 0

			if Props.Scroll ~= nil then
				ht = Props.Height
				Props.Height = 0
			else
				Props.Height = 0
			end

			if Props.Width ~= nil then

				if Props.Bold == 1 then
			    	MyLabel = display.newText( Props.Caption,0, 0,Props.Width,Props.Height,native.systemFontBold,Props.FontSize )
			    else
					MyLabel = display.newText( Props.Caption,0, 0,Props.Width,Props.Height,native.systemFont,Props.FontSize )
				end				
			else
				Props.Height = 0
				if Props.Bold == 1 then
			    	MyLabel = display.newText( Props.Caption,0, 0, native.systemFontBold,Props.FontSize )
			    else
					MyLabel = display.newText( Props.Caption,0, 0, native.systemFont,Props.FontSize )
				end
			end	

		    if Props.Centre == 1 then 
		    	MyLabel.x = Props.Left
		    else
		    	MyLabel.x = Props.Left +  (MyLabel.contentWidth / 2)
		    end

		    MyLabel.y = Props.Top + (MyLabel.contentHeight  / 2)
		    if isAndroid then
		    	MyLabel.y = MyLabel.y - 5
		    end

		    if Props.Red ~= nil then
				MyLabel:setFillColor(Props.Red,Props.Green, Props.Blue)	
			else
				MyLabel:setFillColor(0,0, 0)	
		    end
		    
		    if Props.listener ~= nil then
				MyLabel:addEventListener("touch",Props.listener)
		    end		    
		    
		    if Props.id ~= nil then
		    	MyLabel.id = Props.id
		    end



			if Props.Scroll == 1 then

				local scroll = widget.newScrollView
				{
					x =Props.Left + (Props.Width / 2) ,
					y = Props.Top,--row.contentHeight * 0.5,
					width = Props.Width ,
					height =ht,
					scrollHeight =0,
					horizontalScrollDisabled = true,
					verticalScrollDisabled = false,
					hideScrollBar = false,
					hideBackground = true					
				}
				
				MyLabel.x = MyLabel.contentWidth / 2
				MyLabel.y = MyLabel.contentHeight / 2

			    if Props.Border == 1 then


					
					local fieldBox = display.newRect( Props.Left + (Props.Width / 2), Props.Top, Props.Width + 10, ht + 10 )
					fieldBox.strokeWidth = 2
					fieldBox:setFillColor( 1 )
					fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
					gr:insert(fieldBox)

				end		

				scroll:insert(MyLabel)	
				gr:insert(scroll)
			
		else

		    if Props.Border == 1 then


				
				local fieldBox = display.newRect( MyLabel.x, MyLabel.y, MyLabel.contentWidth + 10, MyLabel.contentHeight + 10 )
				fieldBox.strokeWidth = 2
				fieldBox:setFillColor( 1 )
				fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
				gr:insert(fieldBox)

			end


			
			gr:insert(MyLabel)

			if Props.Underline == 1 then
			    if Props.Red ~= nil then
			    	gr:insert(DrawLine(Props.Left,Props.Top+ (MyLabel.contentHeight),Props.Left + MyLabel.contentWidth, Props.Top+ (MyLabel.contentHeight),1,Props.Red,Props.Green,Props.Blue))
				else
			    	gr:insert(DrawLine(Props.Left,Props.Top+ (MyLabel.contentHeight),Props.Left + MyLabel.contentWidth, Props.Top+ (MyLabel.contentHeight),1,0,0,0))
			    end
				

			end	
					
		end



		return gr

	end		

	local function StandardDisplayBox(short,red, green, blue)
		
		local gr = display.newGroup()
		local box = CreateBox(display.contentWidth / 2, 105, display.contentWidth - 18, 62)

		if short ~= nil then
			box.width = box.width - 250
			box.x = box.x - 125
		end
		
		gr:insert(box)
		local fieldBox = display.newRect( display.contentWidth / 2, 105, display.contentWidth - 20, 60 )
		if short ~= nil then
			fieldBox.width = fieldBox.width - 250
			fieldBox.x = fieldBox.x - 125
		end
		fieldBox.strokeWidth = 2
		if red == nil then
			fieldBox:setFillColor(128/255, 100/255, 162/255)
		else
			fieldBox:setFillColor(red, green, blue)		
		end
		fieldBox:setStrokeColor( 1 )	    
		    
		gr:insert(fieldBox)
		    
		return gr
	end		

	local function NarrowDisplayBox(short,red, green, blue)
		
		local gr = display.newGroup()
		local box = CreateBox(1024/ 2, 100, 1024- 98, 42)

		gr:insert(box)
		local fieldBox = display.newRect( 1024/ 2, 100, 1024- 100, 40 )
		if short ~= nil then
			fieldBox.width = fieldBox.width - 250
			fieldBox.x = fieldBox.x - 125
		end
		fieldBox.strokeWidth = 2
		if red == nil then
			fieldBox:setFillColor(128/255, 100/255, 162/255)
		else
			fieldBox:setFillColor(red, green, blue)		
		end
		fieldBox:setStrokeColor( 1 )	    
		    
		gr:insert(fieldBox)
		    
		return gr
	end	

	local function StandardDisplayBox2(short,red, green, blue)
		
		local gr = display.newGroup()
		local box = CreateBox(1024/ 2, 120, 1024- 98, 82)

		gr:insert(box)
		local fieldBox = display.newRect( 1024/ 2, 120, 1024- 100, 80 )
		if short ~= nil then
			fieldBox.width = fieldBox.width - 250
			fieldBox.x = fieldBox.x - 125
		end
		fieldBox.strokeWidth = 2
		if red == nil then
			fieldBox:setFillColor(128/255, 100/255, 162/255)
		else
			fieldBox:setFillColor(red, green, blue)		
		end
		fieldBox:setStrokeColor( 1 )	    
		    
		gr:insert(fieldBox)
		    
		return gr
	end		

	
	local function LargeButton(ButtonText, onClickEvent,buttonID,fontSize, posX, posY)
		local fs

			if fontSize == nil then
				fs = 22
			else
				fs = fontSize
			end
				
				local hsButton = widget.newButton
			{
				id = buttonID,
				defaultFile = "Images/BigButtonOff.png",
				overFile = "Images/BigButtonOn.png",
				label = ButtonText,
				labelColor = 
				{ 
					default = { 255/255, 255/255, 255/255 },
				},
	
				font="arial",
				fontSize = fs,	
				emboss = true,
				onEvent = onClickEvent,
			
			}
			
	
				hsButton.width=250
				hsButton.height =55		

			if posX ~= nil then
				hsButton.x = posX
				hsButton.y = posY
			end

			return hsButton
	end
	
	
	local StandardButton = function(ButtonText, onClickEvent,buttonID, fontSize, posX, posY, extra)
		
			local fS = 0
			if fontSize == nil then
					fS = 15
			else
				fS = fontSize
			end
			
			
			
				local hsButton = widget.newButton
			{
				id = buttonID,
				defaultFile = "Images/btnDef.png",
				overFile = "Images/btnOver.png",
				label = ButtonText,
				labelColor = 
				{ 
					default = { 51/255, 51/255, 51/255 },
				},
	
				font="arial",
				fontSize =fS,	
				emboss = true,
				onEvent = onClickEvent,
			
			}
			
	
				hsButton.width=97
				hsButton.height =34		
		
		
			if posX ~= nil then
				hsButton.x = posX
				hsButton.y = posY
			end
			if extra ~= nil then
				hsButton.extra = extra
			end
			
			return hsButton
	end
	
		local function WideButton(ButtonText, onClickEvent,buttonID, posX, posY)
		
				local hsButton = widget.newButton
			{
				id = buttonID,
				defaultFile = "Images/widebtnDef.png",
				overFile = "Images/widebtnDefOver.png",
				label = ButtonText,
				labelColor = 
				{ 
					default = { 51/255, 51/255, 51/255 },
				},
	
				font="arial",
				fontSize =13,	
				emboss = true,
				onEvent = onClickEvent,
			
			}
			
	
				hsButton.width=120
				hsButton.height =35		
		
			if posX ~= nil then
				hsButton.x = posX
				hsButton.y = posY
			end
			return hsButton
	end	
	
	SmallButton = function(ButtonText, onClickEvent,buttonID, posX, posY)
		
				local hsButton = widget.newButton
			{
				id = buttonID,
				defaultFile = "Images/smallbtnDef.png",
				overFile = "Images/smallbtnDefOver.png",
				label = ButtonText,
				labelColor = 
				{ 
					default = { 51/255, 51/255, 51/255 },
				},
	
				font="arial",
				fontSize =13,	
				emboss = true,
				onEvent = onClickEvent,
			
			}
			
	
				hsButton.width=73
				hsButton.height =35		
			if posX ~= nil then
				hsButton.x = posX
				hsButton.y = posY
			end		
			return hsButton
	end	
	
	
	local function CreateSettingsFile(AutoSignIn)
		
		local sg
		if AutoSignIn == nil then
			sg = 0
		elseif tonumber(AutoSignIn) == 0 then
			sg = _G.StaffIndex
		else
			sg = 0
		end

		local rfilePath = system.pathForFile( "settings.txt", system.DocumentsDirectory )
		local file = io.open( rfilePath, "w" )	
		file:write("SiteCode:" .. _G.SiteCode .. ";DeviceName:" .. _G.TabletName .. ";LocalIPAddress:" .. _G.UserLocalIPAddress .. ";IPAddress:" .. _G.IPAddress .. ";PortNumber:" .. _G.PortNumber .. ";HomePage:" .. _G.HomePage .. ";PinchZoom:" .. _G.PinchMode .. ";AutoSignIn:" .. sg .. ";UseSSL:" .. _G.UseSSL)
		file:write("\n")
		io.close( file )
		file = nil	
		
		
	end

	local function CreateUserFile()
		

		local rfilePath = system.pathForFile( "user.txt", system.DocumentsDirectory )
		local file = io.open( rfilePath, "w" )	
		file:write("UserName:" .. _G.LoginName .. ";UserGuid:" .. _G.UserCode .. ";" )
		file:write("\n")
		io.close( file )
		file = nil	
		
	end
	local function CreateConfigFile(ZoomStatus)
		
		local sg
		if ZoomStatus == nil then
			sg = "letterbox"
		elseif tonumber(ZoomStatus) == 1 then
			sg = "letterbox"
		else
			sg = "zoomStretch"
		end

		local rfilePath = system.pathForFile( "config.txt", system.DocumentsDirectory )
		local file = io.open( rfilePath, "w" )	
		file:write("ZoomMode:" .. sg .. ";")
		file:write("\n")
		io.close( file )
		file = nil	
		
		
	end

	local function CheckCreateLogFile()

		local path = system.pathForFile( "cclog.txt", system.DocumentsDirectory )
		local file, errStr = io.open( path, "r" )
		if file then
			io.close( file )
		else
			local file, errStr = io.open( path, "w" )
			file:write("Log Started: " .. os.date("%d/%m/%Y %X"))
			file:write("\n")
			io.close( file )
			file = nil	
		end
		
	end

	local function LogSomething(PageName,ProcedureName,Message)

		local path = system.pathForFile( "cclog.txt", system.DocumentsDirectory )
		local file, errStr = io.open( path, "a+" )
		if file then
			file:write("Log Entry Start: " .. os.date("%d/%m/%Y %X"))
			file:write("\n")
			file:write("Page Name: " .. PageName)
			file:write("\n")
			file:write("Procedure Name: " .. ProcedureName)
			file:write("\n")
			file:write("Detail: " .. Message)
			file:write("\n")
			file:write("Log Entry End: ")
			file:write("\n")
			io.close( file )
			file = nil	
		end
		
	end

	local function GetLogDetail()

		local path = system.pathForFile( "cclog.txt", system.DocumentsDirectory )
		local file, errStr = io.open( path, "r" )
		local output = ""
		if file then

			for line in file:lines() do	
				
				output = output .. line
						 				
			end
			
			io.close( file )
			file = nil
		end

		
	end

		local function VerySmallButton(ButtonText, onClickEvent,buttonID)
		
				local hsButton = widget.newButton
			{
				id = buttonID,
				defaultFile = "Images/vsmallbtnDef.png",
				overFile = "Images/vsmallbtnDefOver.png",
				label = ButtonText,
				labelColor = 
				{ 
					default = { 51/255, 51/255, 51/255 },
				},
	
				font="arial",
				fontSize =12,	
				emboss = true,
				onEvent = onClickEvent,
			
			}
			
	
				hsButton.width=40
				hsButton.height =30		
		
			return hsButton
	end		
	
	local function LoadStaffSettingsFile()
	
		local settings
		local path = system.pathForFile( "staffSettings.txt", system.DocumentsDirectory )
	    local file = io.open( path, "r" )
		local s
		 
		for line in file:lines() do	
	
			settings = split(line,";")
			s = split(settings[1],":")
			_G.SiteCode =  s[2]
			_G.GUID = s[2]

			s = split(settings[2],":")
			_G.StaffIndex= s[2]

			s = split(settings[3],":")
			_G.TabletName = s[2]			 				
		end
		
		io.close( file )
		file = nil
	
	end

	local function LoadUserFile()
	
		local settings
		local path = system.pathForFile( "user.txt", system.DocumentsDirectory )
	    local file = io.open( path, "r" )
	    if file then
			local s
			 
			for line in file:lines() do	
		
				settings = split(line,";")
				s = split(settings[1],":")
				_G.LoginName =  s[2]
					 				
				s = split(settings[2],":")
				_G.UserCode = s[2]
			end
			
			io.close( file )
			file = nil
		end
	
	end

	local function LoadSettingsFile()
	
		local settings
		local path = system.pathForFile( "settings.txt", system.DocumentsDirectory )
	    local file = io.open( path, "r" )
		local s
		 
		for line in file:lines() do	
	
			settings = split(line,";")
			s = split(settings[1],":")
			_G.SiteCode =  s[2]
			_G.GUID = s[2]
			s = split(settings[2],":")
			_G.TabletName = s[2]
			s = split(settings[3],":")
			_G.UserLocalIPAddress = s[2]
			s = split(settings[4],":")
			_G.IPAddress = s[2]
			s = split(settings[5],":")
			_G.PortNumber = s[2]
			s = split(settings[6],":")
			_G.HomePage = s[2]

			_G.HomePage = "residentListImages"
			if #settings > 6 then
				s = split(settings[7],":")
				_G.PinchMode = s[2]	
			end	
			if #settings > 7 then
				s = split(settings[8],":")
				_G.AdminSignIn = s[2]	
			end
			if #settings > 8 then
				s = split(settings[9],":")
				if s[2] == nil then
					_G.UseSSL = ""
				else
					_G.UseSSL = "s"
				end
			end
					 				
		end
		
		io.close( file )
		file = nil
	
	end

		local function WriteStrapHeaderText(HeadingText)
	
		local gr = display.newGroup()

		local ComboLab = display.newText( gr, _G.CompanyName .. " - " .. HeadingText, 0, 0,"arial", 20)
		ComboLab.x =25 + (ComboLab.contentWidth / 2)
		ComboLab.y = 105
		ComboLab:setFillColor(1, 1, 1)		
		return gr
		
		
	end	
	
	local HeaderButtonClick = function(event)
		local t = event.target
	
			if event.phase == "ended"  and _G.NetworkCallOn == false and _G.OverlayShow == false then
			--print(t.id)
			--print(_G.HomePage)
			if t.id == "btnhelp" then
				local p = {}
				p.SearchText =t.extra 
				p.Autoplay = 0
				LoadScreen("help","slideLeft",p,800)
			end
			if t.id == "btn9" then	
				LoadScreen( _G.HomePage, "slideLeft", 800  )
			end			
			if t.id == "btn1" then	--homeScreen
				LoadScreen( _G.HomePage, "slideLeft", 800  )
			end
			if t.id == "btn99" then	--homeScreen
				LoadScreen( "adminMenu", "slideLeft", 800  )
			end		
			if t.id == "btn2" then	
				LoadScreen( "taskList", "slideLeft", 800  )
			end

			if t.id == "btn6" then	
				LoadScreen( "orders", "slideLeft", 800  )
			end

			if t.id == "btn8" then	
				LoadScreen( "manageMeals", "slideLeft", 800  )
			end

			if t.id == "btn7" then	
				LoadScreen( "menuView", "slideLeft", 800  )
			end									
			
			if t.id == "btn12" then	
				LoadScreen( "home2", "slideLeft", 800  )
			end	
			if t.id == "btn14" then	
				LoadScreen( "tabletSettings", "slideLeft", 800  )
			end	
			if t.id == "btn3" then	
				_G.StaffIndex = 0
				_G.StaffName =""
				_G.StaffStatus = 1				
				storyboard.gotoScene( "splash", "fade", 2500 )
			end

			if t.id == "btn4" then	
				local options =
					{
						effect = "slideLeft",
						time = 800,
						params ={
								         paramData1=0,
										 paramData2 = "None"
									}	
					}		
					storyboard.gotoScene( "login", options )							

			end			
			
		end

	end
	
	local LoadSetup = function(event)
		
		if event.phase == "ended" then
				storyboard.gotoScene( "configuration", "slideLeft", 800  )
		end
		
		
	end
	
	local function CreateComboBoxDropDown(ComboLabel, BoxWidth, BoxLeft, BoxY, PressOverlay, showLab)
		
		local gr = display.newGroup()
		
		if showLab == nil then
			showLab = 1
		end
		
		local BoxX = BoxWidth * 0.5 + BoxLeft
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, 22)
		fieldBox.strokeWidth = 2
		fieldBox:setFillColor( 1 )
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		fieldBox:addEventListener( "touch", PressOverlay )
		gr:insert(fieldBox)
		
		local dropDownIcon = display.newImage("Images/dropDownIcon2.png")
		dropDownIcon.y = BoxY
		dropDownIcon.x = fieldBox.contentWidth + BoxLeft - (dropDownIcon.contentWidth * 0.5) 
		
		gr:insert(dropDownIcon)
		
		if showLab == 1 then
		local ComboLab = display.newText( gr, ComboLabel, 0, 0,"arial", 20 )
		ComboLab.x = (BoxLeft - (ComboLab.contentWidth / 2) - 5)
		ComboLab.y = BoxY
		ComboLab:setFillColor(0, 0, 0)		
		end
		return gr
	end


local _DisplayList2
local _DisplayList2Box
local _listValues = {}


local _clearListLabel = function(name)


	for i = #_listValues, 1,-1 do
		if _listValues[i].name == name then
			if _listValues[i].lbValue ~= nil then
				_listValues[i].lbValue:removeSelf()
				_listValues[i].lbValue = nil
			end
		end
	end
end

local _setListValue = function (name,value,lb,lbText, rowID)

	for i = 1, #_listValues do

		if _listValues[i].name == name then
			_listValues[i].value = value
			_listValues[i].lbValue = lb
			_listValues[i].lbText = lbText
			_listValues[i].rowID = rowID
			break
		end

	end

end



local ClearListValue = function (name)


	for i = #_listValues, 1, -1 do

		if _listValues[i].name == name then

			if _listValues[i].lbValue ~= nil then
				_listValues[i].lbValue:removeSelf()
				_listValues[i].lbValue = nil
			end
			_listValues[i].value = nil
			_listValues[i].lbText = nil
			table.remove(_listValues,i)
		end
	end
end

local GetListText = function (name,def)

local v

	for i = 1, #_listValues do

		if _listValues[i].name == name then
			v = _listValues[i].lbText
			break
		end

	end
	if v == nil then
		v = def
	end
	return v

end

local GetListValue = function (name,def)

local v

	for i = 1, #_listValues do

		if _listValues[i].name == name then
			v = _listValues[i].value
			break
		end

	end

	if v == nil then
		v = def
	end
	if string.len(v) < 1 then
		v = def
	end
	return v

end

local GetListIndex = function (name,def)

local v

	for i = 1, #_listValues do

		if _listValues[i].name == name then
			v = _listValues[i].rowID
			break
		end

	end

	if v == nil then
		v = def
	end
	if string.len(v) < 1 then
		v = def
	end
	return v

end

local InitBackTable = function()

	for i = 1,#_G.BackStructure do
		table.remove(_G.BackStructure)
	end

end

local ListGR

local _RemoveListBox = function()
	
	
	if _DisplayList2 ~= nil then
		if _DisplayList2Box ~= nil then
			_DisplayList2Box:removeSelf()
		end
		_DisplayList2:deleteAllRows()
		_DisplayList2:removeSelf()
		_DisplayList2 = nil	
	end	
	
	if ListGR ~= nil then
		ListGR:removeSelf()	
		ListGR = nil
	end
end


local _RemoveListBoxNew = function(event)

	if event.phase == "ended" then

		_RemoveListBox()

	end
	return true

end

local SuperDDRemoveListBox = function()

	_RemoveListBox()
end


local _SetCommentValue = function(val, xPos, yPos, fontSize)
		

	local _CommentLabel

		if _CommentLabel ~= nil then
				_CommentLabel:removeSelf()
				_CommentLabel = nil
		end
		
		if fontSize == nil then
			fontSize = 20
		end

		_CommentLabel = StandardLabel( val,fontSize )
		_CommentLabel.x =xPos + 10 + _CommentLabel.contentWidth * 0.5
		_CommentLabel.y = yPos

		return _CommentLabel
		

end

local _listViewRowClick3 = function(event)


	if event.phase == "release" then--or event.phase == "tap" then
		local row = event.row
		local id = row.index
		local params = event.row.params


		_clearListLabel(params.name)
		local lb =_SetCommentValue(params.text,params.xPos,params.yPos, params.fontSize)

		_setListValue(params.name,params.value,lb,params.text, id)
		params.pGroup:insert(lb)
		--print("row clicked")
		if params.selectFunc ~= nil then
			params.selectFunc(params.name,params.xPos,params.yPos )
		end
		_RemoveListBox()

	end
	return true

end


local SetListValue = function(listName, value,text, xPos, yPos, fontSize)


		_clearListLabel(listName)
		local lb =_SetCommentValue(text,xPos,yPos, fontSize)

		_setListValue(listName,value,lb,text)


		_RemoveListBox()

		return lb

end


local  _listViewRowRender3 = function( event )
		
		   local row = event.row
		   local id = row.index
			local params = event.row.params
		local taskDetail2


			taskDetail2 = display.newText( row, params.text, 0, 0,570,0, "arial", 38 )
			taskDetail2.x = (taskDetail2.contentWidth / 2) +10
			taskDetail2.y = 40
			taskDetail2:setFillColor(0/255, 0/255,0/255)
	
		
			return true
end



local _SDD_SelectList = function(event)

	local tg = event.target

	if event.phase == "ended" then
	
		ListGR = display.newGroup()
		ListGR:insert(FadeScreen())
		ListGR:insert(StandardImage("listBackground.png",320,820))
		_DisplayList2 = CreateListView(30, 620, 580, 430,_listViewRowRender3, _listViewRowClick3 , true)
		ListGR:insert(_DisplayList2)	
		ListGR:insert(StandardImage("closeWindow.png",570,600,_RemoveListBoxNew,nil,nil,1.2))
		for i = 1, #tg.List do
			_DisplayList2:insertRow
			{
		
				rowHeight  =100,
				lineColor={212/255,212/255, 212/255},
				rowColor = 
				{ 
					default = { 242/255,242/255, 242/255 },
				},
				params = {
			         value=tg.List[i][1],
			         text=tg.List[i][2],
			         xPos = tg.x - tg.width *0.5,
			         yPos = tg.y,
			         pGroup = tg.parent,
			         name = tg.name,
			         selectFunc = tg.selectFunction,
			         fontSize = tg.fontSize
				}							
			}
		end	

	end
	return true

end



local _CommList = {}

local  _CommentSelectList = function(event)
	
	local tg = event.target
	if event.phase == "began" then
		
		local gr = tg.group
		if _DisplayList2 == nil  then

			if tg.direction == "down" then
	 			_DisplayList2Box = display.newRect( tg.x+5,300/2 + tg.y + 35, tg.width+5, 305 )
	 		else
	 			_DisplayList2Box = display.newRect( tg.x+5,tg.y - 300/2 - 35, tg.width+5, 305 )
	 		end

			_DisplayList2Box.strokeWidth = 2
			_DisplayList2Box:setFillColor( 1 )
			_DisplayList2Box:setStrokeColor( 166/255, 166/255, 166/255)
			gr:insert(_DisplayList2Box)
			
			if tg.direction == "down" then
				_DisplayList2 = CreateListView(5+tg.x - tg.width *0.5, tg.y + 35, tg.width, 300,_listViewRowRender3, _listViewRowClick3 , false)
			else
				_DisplayList2 = CreateListView(5+tg.x - tg.width *0.5, tg.y - 300 - 35, tg.width, 300,_listViewRowRender3, _listViewRowClick3 , false)
			end

			gr:insert(_DisplayList2)	

			
			for i = 1, #tg.List do
					_DisplayList2:insertRow
					{
				
						rowHeight  =90,
						lineColor={212/255,212/255, 212/255},
						rowColor = 
						{ 
							default = { 255/255,255/255, 255/255 },
						},
				params = {
			         value=tg.List[i][1],
			         text=tg.List[i][2],
			         xPos = tg.x - tg.width *0.5,
			         yPos = tg.y,
			         pGroup = tg.parent,
			         name = tg.name,
			         selectFunc = tg.selectFunction,
			         fontSize = tg.fontSize
				}							
					}
			end	
	else
		_RemoveListBox()			
			end

	end
	
end

		local function SuperDropDown(ParentGroup,BoxWidth, BoxLeft, BoxY,  List, name,direction,selectFunction, fontSize, boxHeight, CustomSelect)
		
		local gr = display.newGroup()
		
		
		if boxHeight == nil then
			boxHeight = 40
		end
		if fontSize == nil then
			fontSize = 30
		end

		local BoxX = BoxWidth * 0.5 + BoxLeft
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, boxHeight)
		fieldBox.strokeWidth = 2
		fieldBox:setFillColor( 1 )
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		if CustomSelect ~= nil then
			fieldBox:addEventListener( "touch", CustomSelect )
		else
			fieldBox:addEventListener( "touch", _SDD_SelectList) --_CommentSelectList )
		end
		fieldBox.List = List
		fieldBox.group = ParentGroup
		fieldBox.name = name
		fieldBox.fontSize = fontSize
		if direction ~= nil then
			fieldBox.direction = direction
		else
			fieldBox.direction = "down"
		end

		if selectFunction ~= nil then
			fieldBox.selectFunction = selectFunction
		end

		gr:insert(fieldBox)
		
		local dropDownIcon = display.newImage("Images/dropDownIcon2.png")
		dropDownIcon.y = BoxY
		dropDownIcon.x = fieldBox.contentWidth + BoxLeft - (dropDownIcon.contentWidth * 0.5)  + 4
		
		gr:insert(dropDownIcon)

		_listValues[#_listValues+1] = {}
		_listValues[#_listValues].name = name

		return gr
	end	

	local function CreateComboBoxDropDownLarge(BoxWidth, BoxLeft, BoxY, PressOverlay,ComboLabel,Bold)
		
		local gr = display.newGroup()
		
		
		local BoxX = BoxWidth * 0.5 + BoxLeft
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, 26)
		fieldBox.strokeWidth = 2
		fieldBox:setFillColor( 1 )
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		fieldBox:addEventListener( "touch", PressOverlay )
		gr:insert(fieldBox)
		
		local dropDownIcon = display.newImage("Images/dropDownIcon2.png")
		dropDownIcon.y = BoxY
		dropDownIcon.x = fieldBox.contentWidth + BoxLeft - (dropDownIcon.contentWidth * 0.5)  + 4
		
		gr:insert(dropDownIcon)
		
		local ComboLab
		if ComboLabel ~= nil  then
			if Bold ~= nil then
				ComboLab = display.newText( gr, ComboLabel, 0, 0,native.systemFontBold, 16)
			else
				ComboLab = display.newText( gr, ComboLabel, 0, 0,"arial", 16)
			end
			ComboLab.x = (BoxLeft - (ComboLab.contentWidth / 2) - 5)
			ComboLab.y = BoxY
			ComboLab:setFillColor(61/255, 61/255, 61/255)		
		end
		return gr
	end	
	

	local function CreateBoxedLabel(LabelText, BoxWidth, BoxLeft, BoxY,alignment)
		
		local gr = display.newGroup()
	
		local BoxX = BoxWidth * 0.5 + BoxLeft
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, 50 )
		fieldBox.strokeWidth = 2
		fieldBox:setFillColor( 1 )
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		gr:insert(fieldBox)

		
		local ComboLab = display.newText( gr, LabelText, 0, 0,"arial", 25 )
		if alignment == 2 then
			ComboLab.x = (BoxX + (ComboLab.contentWidth / 2 ))
		else
			ComboLab.x = (BoxLeft + (ComboLab.contentWidth / 2) + 5)
		end
		ComboLab.y = BoxY
		ComboLab:setFillColor( 120/255, 0/255, 4/255)		
		gr:insert(ComboLab)
		return gr
	end


	local function CoolEdit(StartText, xPos, yPos,width,fontSize,  id,groupName, type, quitCaption, thName, onchange,listener)

		local alc, qc, fs
		if quitCaption ~= nil then
			qc = quitCaption
		else
			qc = "Tap screen to finish text input."
		end

		if fontSize == nil then
			fs = 14
		else
			fs = fontSize
		end

		if type == nil then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'.,!£%*@<>?/+=()"
		elseif type == "restrict" then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "	
		elseif type == "restrictPrompt" then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789: "	
		elseif type == "password" then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 *!£$%^()"			
		elseif type == "number" then
			alc = "0123456789"			
		elseif type == "IPnumber" then
			alc = "0123456789."			
		elseif type == "email" then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-@._"	
		elseif type == "web" then
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:/."			
		elseif type == "decimal" then
			alc = "0123456789."		
		elseif type == "date" then
			alc = "0123456789/"		
		elseif type == "datetime" then
			alc = "0123456789/:- "	
		elseif type == "time" then
			alc = "0123456789:"										
		else
			alc = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'.,!£%*@<>?/"
		end


		if thName == nil then
			thName = "theme_1"
		end

	_G.GUI.NewInput({

		caption=StartText,
		parentGroup=groupName,
		scale=1.5,
		theme=thName,
		inputType = "default",
		allowedChars=alc,
		quitCaption=qc,
		fontSize=fs,
		x=xPos - 5,
		y=yPos - 20,
		width=width,
		height=50,
		name=id,
		onChange = listener,
		onBlur = onchange}
		)
	
	end

	local function CreateBoxedLabelNew(LabelText, BoxX, BoxY,BoxWidth,fontSize,bold,listener, id, ColourMode,height,RedBox, centre)
		
		local gr = display.newGroup()
		local ComboLab

		local isAndroid = "Android" == system.getInfo( "platformName" )
		if ( isAndroid ) then
		    fontSize = fontSize - 2
		end		
		
		if bold ~= nil then
			ComboLab = display.newText( gr, LabelText, 0, 0,native.systemFontBold,fontSize )
		else
			ComboLab = display.newText( gr, LabelText, 0, 0,"arial",fontSize )
		end
		
		local BoxHeight
		if height == nil then
			BoxHeight = ComboLab.contentHeight + 8
		else
			BoxHeight = height
		end


		
		local fieldBox = display.newRect( 0, 0, BoxWidth, BoxHeight )

		if centre == nil then
			fieldBox.x = BoxX +  (BoxWidth / 2)
		else
			fieldBox.x = BoxX
		end

		fieldBox.y = BoxY
		fieldBox.strokeWidth = 2
		if RedBox == nil then
			fieldBox:setFillColor( 242/255,242/255,242/255 )
		elseif RedBox == 1 then
			fieldBox:setFillColor( 255/255,0/255,0/255 )
		elseif RedBox == 2 then
			fieldBox:setFillColor( 255/255,255/255,255/255 )
		end

		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )

		gr:insert(fieldBox)

		if centre == nil then
			ComboLab.x = BoxX  + (ComboLab.contentWidth / 2) + 3
		else
			ComboLab.x = BoxX
		end

		ComboLab.y = BoxY
		if ColourMode == 1 then
			ComboLab:setFillColor( 0, 0, 0)
		elseif ColourMode == 2 then
			ComboLab:setFillColor( 149/255, 55/255, 73/255)
		elseif ColourMode == 3 then
			ComboLab:setFillColor( 255/255, 255/255, 255/255)
		else
			ComboLab:setFillColor( 74/255, 69/255, 42/255)		
		end
		
		if listener ~= nil then
			fieldBox:addEventListener("touch",listener)
			fieldBox.id = id
			--ComboLab:addEventListener("touch",listener)
			--ComboLab.id = id
		end

		gr:insert(ComboLab)
		return gr
	end	

	local function CreateBoxedLabelBold(LabelText, BoxX, BoxY,fontSize)
		
		local gr = display.newGroup()
	
		
		local ComboLab = display.newText( gr, LabelText, 0, 0,native.systemFontBold,fontSize )
	
		local BoxWidth = ComboLab.contentWidth + 10
		local BoxHeight = ComboLab.contentHeight + 10
		
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, BoxHeight )
		fieldBox.strokeWidth = 2
		fieldBox:setFillColor( 1 )
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		gr:insert(fieldBox)

		ComboLab.x = BoxX
		ComboLab.y = BoxY
		ComboLab:setFillColor( 120/255, 0/255, 4/255)		
		
		gr:insert(ComboLab)
		return gr
	end	
	

	
	local function LoadMenu(event)
		
		local pTable = {}
		local t = event.target

		if (event.phase == "ended" or event.phase == "tap")  and _G.NetworkCallOn == false and _G.OverlayShow == false  then
			
			pTable.contextMenu = t.contextScreen

			OverlayShow("menu","fromRight",pTable)

		end
	end
	
	local function CreateMenuHeader (contextScreen)
		
		local gr = display.newGroup()

		local menuIcon = display.newImage("Images/menuIcon.png")
	    menuIcon:addEventListener( "touch", LoadMenu )
		menuIcon.x =  970
		menuIcon.y =30
		menuIcon.contextScreen = contextScreen
		gr:insert(menuIcon)	
		
		return gr
	end
	
	local _HeaderTimeID, _headingTimeGroup


	local _RefreshHeadingTime = function()

		local newTimeValue
		if _headingTimeGroup ~= nil then
			_headingTimeGroup:removeSelf()
			_headingTimeGroup = nil
		end

		newTimeValue = "Current Time: " .. os.date("%H:%M:%S",os.time())

		_headingTimeGroup = display.newGroup()
		_headingTimeGroup:insert(StandardLabelBold(newTimeValue,(1024/2),32,28,3/255,101/255,162/255,nil,nil,1))

	end

	local _StartHeadingTime = function()

		_HeaderTimeID = timer.performWithDelay( 1000, _RefreshHeadingTime , 0 )


	end

	local function ClearHeaderTime()

		if _HeaderTimeID ~= nil then
			timer.cancel( _HeaderTimeID )
			_HeaderTimeID = nil
		end
		if _headingTimeGroup ~= nil then
			_headingTimeGroup:removeSelf()
			_headingTimeGroup = nil
		end
	end


	local function PocketMenu(event)

		_G.MenuID = 0
		if _G.HaltNav == nil then
			OverlayShow("pocketMenu","slideDown")
		end
	end

	local function PocketMenuStaff(event)

		_G.MenuID = 0
		if _G.HaltNav == nil then
			OverlayShow("pocketMenuStaff","slideDown")
		end
	end

local function LoadPocketMenu()

	if _G.HaltNav == nil then
		if tonumber(_G.MenuID) == 2 then
			_G.MenuID = 0
			local p = {}
			p.LoadScreen = "residentListImages"
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 1 then
			_G.MenuID = 0
			local p = {}
			p.LoadScreen = "taskList"
			p.ActionType = 2

			if _G.WorkingOffline == 1 then
			p.ActionType = 0
			p.LoadType = 2
			ShowSimpleAlert("Resync before signing out!","Please resync before signing out!")
			p.LoadScreen = "Sync"
			end

			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 3 then
			_G.MenuID = 0
			local p = {}
			p.LoadScreen = "taskList"
			p.ActionType = 3
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 5 then
			_G.MenuID = 0

			if _G.WorkingOffline == 1 then
				ShowSimpleAlert("Not Supported","We do not support Handover Notes for offline mode yet!")
				return
			end

			local p = {}
			p.LoadScreen = "handover"
			p.ActionType = 0
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 6 then
			_G.MenuID = 0

			if _G.WorkingOffline == 1 then
				ShowSimpleAlert("Not Supported","We do not support the Staff Area for offline mode!")
				return
			end

			local p = {}
			p.LoadScreen = "staffHome"
			p.ActionType = 2
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 4 then
			_G.MenuID = 0

			if _G.WorkingOffline == 1 then
				ShowSimpleAlert("Not Supported","We do not support the home screen for offline mode yet!")
				return
			end

			local p = {}
			p.LoadScreen = "homeStatus"
			p.ActionType = 0
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
		if tonumber(_G.MenuID) == 99 then
			_G.MenuID = 0
			local p = {}
			p.LoadType = 2
			LoadScreen("Sync", "slideLeft",p,0,1)
		end

		if tonumber(_G.MenuID) == 7 then
			_G.MenuID = 0
			if _G.FullVersion == 1 then
				local p = {}
				p.LoadScreen = "residentListImages"
				LoadScreen("menuMove", "slideLeft",p,0,1)
			else 
				ShowSimpleAlert("Access Denied","You cannot access the Care Menu on a staff device!")
			end
		end	
		if tonumber(_G.MenuID) == 10 then
			_G.MenuID = 0

			if _G.WorkingOffline == 1 then
				ShowSimpleAlert("Not Supported","We do not support the Staff Area for offline mode!")
				return
			end

			local p = {}
			p.LoadScreen = "staffHome"
			p.ActionType = 2
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end	

		if tonumber(_G.MenuID) == 16 then
			_G.MenuID = 0
			local p = {}
			p.LoadScreen = "staffMsgCentre"
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end	
		if tonumber(_G.MenuID) == 8 then
			_G.MenuID = 0
			local p = {}
			if _G.HomePage == "staffRotaNew" then
				p.entryDate = ""
				p.viewMode = 1
				p.fromTask = 1
				p.LoadScreen = "staffRotaNew"
			else
				p.LoadScreen = "staffRota"
			end

			LoadScreen("menuMove", "slideLeft",p,0,1)
		end	
		if tonumber(_G.MenuID) == 9 then
			_G.MenuID = 0
			local p = {}
			p.LoadScreen = "staffTimesheet"
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end	
		if tonumber(_G.MenuID) == 11 then
			_G.MenuID = 0
			_G.StaffIndex = 0
			local p = {}
			p.LoadScreen = "splash"
			LoadScreen("menuMove", "slideLeft",p,0,1)
		end
	end
end

	local OfflineScreen = function(event)

		if event.phase == "ended" or event.phase == "tap" then

			local p = {}
			p.LoadType = 2
			LoadScreen("Sync", "slideLeft",p,0,1)


		end
		return true
	end
	
	local function CreateStandardHeader(showButtons, StaffName, Heading, hideBack, HelpContext, ShowTime, SaveButton, SaveListener)
		
		local gr = display.newGroup()
		local DataEntryHeader

		local isAndroid = "Android" == system.getInfo( "platformName" )
		local inputFontSize = 35
		if ( isAndroid ) then
		    inputFontSize = inputFontSize - 4
		end

		local hsButton, abButton, msButton, clButton, rsButton, coButton
		local banner
		if StaffName == nil and Heading == nil then
			banner = display.newImage("Images/banner2full.png")
		else
			banner = display.newImage("Images/banner2full.png")
		end
		banner.x = banner.width/2
		banner.y=banner.height/2
		gr:insert(banner)
		

		if ShowTime ~= nil then
			_StartHeadingTime()
		end

		if StaffName ~= nil then
			gr:insert(StandardLabel2("User: " .. StaffName,60,35,inputFontSize,136/255,0/255,21/255))	
		end

		if Heading ~= nil then	
			gr:insert(StandardLabel2(Heading,60,30,inputFontSize,136/255,0/255,21/255))	
		end	

		if showButtons == nil then
			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,940,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
		end

		if showButtons == 3 then
			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,940,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end

	
		end

		if showButtons == 1 then
			if _G.WorkingOffline == 1 then
				gr:insert(StandardImage("OfflineIcon.png",535,30,OfflineScreen))
			end
			gr:insert(StandardImage("menu.png",600,30,PocketMenu))
		end

		if showButtons == 2 then
			gr:insert(StandardImage("menu.png",600,30,PocketMenuStaff))
		end


		if showButtons == 6 then
			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,700,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
			hsButton = StandardButton("Home",HeaderButtonClick,"btn1",13)
			hsButton.x =  820
			hsButton.y =30
			gr:insert(hsButton)	
		
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end	

		if showButtons == 7 then
			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,700,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
			hsButton = StandardButton("Home",HeaderButtonClick,"btn1",13)
			hsButton.x =  820
			hsButton.y =30
			gr:insert(hsButton)	
		
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end			

		if showButtons == 9 then
			hsButton = StandardButton("Home",HeaderButtonClick,"btn9",13)
			hsButton.x =  700
			hsButton.y =30
			gr:insert(hsButton)	
		
			abButton = StandardButton("Tasks",HeaderButtonClick,"btn2",13)
			abButton.x =  820
			abButton.y =30
			gr:insert(abButton)	
	
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end	

		if showButtons == 8 then

			hsButton = StandardButton("Orders",HeaderButtonClick,"btn6",13)
			hsButton.x =  580
			hsButton.y =30
			gr:insert(hsButton)

			hsButton = StandardButton("Menus",HeaderButtonClick,"btn7",13)
			hsButton.x =  700
			hsButton.y =30
			gr:insert(hsButton)	
		
			abButton = StandardButton("Meals",HeaderButtonClick,"btn8",13)
			abButton.x =  820
			abButton.y =30
			gr:insert(abButton)	
	
			 msButton = StandardButton("Home",HeaderButtonClick,"btn12",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end				

		if showButtons ==2 then
			 msButton = WideButton("Login",HeaderButtonClick,"btn4",16)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end		

		if showButtons ==10 then
			 msButton = StandardButton("End Tutorial",HeaderButtonClick,"btn4",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		
	
		end	


		if showButtons ==11 then
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		

			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,700,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
			hsButton = StandardButton("Admin Home",HeaderButtonClick,"btn99",13)
			hsButton.x =  820
			hsButton.y =30
			gr:insert(hsButton)	
		end	

		if showButtons ==13 then
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		

			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,700,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
			hsButton = StandardButton("Setup",HeaderButtonClick,"btn14",13)
			hsButton.x =  820
			hsButton.y =30
			gr:insert(hsButton)	
		end	

		if showButtons ==12 then
			 msButton = StandardButton("Finish",HeaderButtonClick,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)		

			if HelpContext ~= nil then
				msButton = StandardButton("Get Help",HeaderButtonClick,"btnhelp",13,700,30,HelpContext)
			--	msButton.x = 820
			--	msButton.y =30
			--	msButton.Help = HelpContext
				gr:insert(msButton)				
			end
			hsButton = StandardButton("User Home",HeaderButtonClick,"btn12",13)
			hsButton.x =  820
			hsButton.y =30
			gr:insert(hsButton)	
		end	

		if (StaffName ~= nil or Heading ~= nil) and hideBack == nil then
			local backIcon = display.newImage("Images/backIcon.png")
			backIcon.x = backIcon.width/2
			backIcon.y = backIcon.height/2
			backIcon:addEventListener( "touch", GoBack )
			backIcon:addEventListener( "tap", GoBack )

			gr:insert(backIcon)
		end


		if SaveButton ~= nil then
			msButton = StandardButton("Save Changes",SaveListener,"btn3",13)
			msButton.x = 940
			msButton.y =30
			gr:insert(msButton)	
		end		
	
	return gr
	end
	
	
	
	 CreateListView = function(lLeft,lTop,lWidth, lHeight, onRenderFunction, onRowFunction,noLines,withListener, hideBack)
	
	local hb
	if hideBack == nil then
		hb = false
	else
		hb = true
	end

	local list
	if withListener == nil then
		 list = widget.newTableView
		{
			left = lLeft,
			top = lTop,
			width =lWidth, 
			height = lHeight,
			noLines = noLines,
			isBounceEnabled = false,
			rowTouchDelay = 0,
			onRowRender = onRenderFunction,
			onRowTouch = onRowFunction,
			hideBackground = hb
		}
		
	else
			 list = widget.newTableView
		{
			left = lLeft,
			top = lTop,
			width =lWidth, 
			height = lHeight,
			noLines = noLines,
			isBounceEnabled = false,
			onRowRender = onRenderFunction,
			onRowTouch = onRowFunction,
			listener = withListener,
			hideBackground = hb,
		}
	end
		
		return list
		
	end
	
	FadeScreen = function(OptionalComment, customTouch)
		
		local disp = display.newGroup()
		local paint = { nil, nil, nil,0.7 }
		local rect = display.newRect( display.contentWidth/2, 1136/2,display.contentWidth, 1136 )
		rect.strokeWidth = 1
		rect.fill = paint	
		rect:setStrokeColor( 166/255, 166/255, 166/255 )

		if customTouch == nil then
			rect:addEventListener("touch", function() return true end)
		else
			rect:addEventListener("touch", customTouch)
		end
		rect:addEventListener("tap", function() return true end)

		disp:insert(rect)
		if OptionalComment ~= nil then
			disp:insert(SuperLabel({Caption=OptionalComment,Left=(640/ 2) - 100,Top=290,FontSize=20, Bold=1, Red=255/255, Green=255/255, Blue=255/255, Underline=0 }))
		end

		return disp
		
		
	end


	
	OverlayShow  = function(OverlayName, effect, pTable )
		
		local options =
		{
			isModal = true,
			effect = effect,
			time = 300,
			params =pTable,
		}		
		_G.OverlayShow = true	

		
		storyboard.showOverlay( OverlayName, options )	
		
		
	end


local CloseWorkingOffline = function(event)
	
	if event.phase == "ended" then

		if OffGrp ~= nil then
			OffGrp:removeSelf()
			OffGrp = nil
		end	

	end
	return true

end

local TrySyncNow = function(event)

	if event.phase == "ended" then

			if OffGrp ~= nil then
				OffGrp:removeSelf()
				OffGrp = nil
			end	

			local p = {}
			p.LoadType = 2
			p.startSync = "1"
			LoadScreen("Sync", "slideLeft",p,0,1)
	end
	return true
end

	LoadScreen =  function  (ScreenName, effect, pTable, timeAmount, skipPush)
		

		if _G.HaltNav ~= nil then
			return 
		end

		_G.HaltNav = 1

		if timeAmount == nil then
			timeAmount = 200
		end
		
		local options =
		{
			effect = effect,
			time = timeAmount,	
			params =pTable
		}		

		storyboard.gotoScene( ScreenName, options )	
	end

local GetPreviousScreen = function()

	local ScreenName
	local id
	
	ScreenName = ""
	id = #_G.BackStructure-1
	if (#_G.BackStructure > 1) then
		ScreenName = _G.BackStructure[id].ScreenName
	end
	return ScreenName
end


local GetCurrentScreen = function()

	local ScreenName
	local id
	
	ScreenName = ""
	id = #_G.BackStructure
	if (id > 1) then
		ScreenName = _G.BackStructure[id].ScreenName
	end
	return ScreenName
end

GoBack = function(event,NoPop)
--	print("here")
	if event == nil then
		event = {}
		event.phase = "ended"
	end
	if _G.HaltNav ~= nil then
			return 
	end
	--print(#_G.BackStructure)
	if (event.phase == "ended" or event.phase == "tap") and _G.LoadStarting == 0 then
		local ScreenName
		local Params
		local ID
	
		if NoPop == nil then
			ID = #_G.BackStructure-1
		else
			ID = #_G.BackStructure
		end

	--	print(#_G.BackStructure)
		if (#_G.BackStructure > 1) then

			ScreenName = _G.BackStructure[ID].ScreenName
					--	print("screenname:" ..ScreenName)
			Params = _G.BackStructure[ID].Params
			--_G.ClientID = _G.BackStructure[#_G.BackStructure-1].ClientID

			if NoPop == nil then
				PopBackEntry()
			end
			--print(ScreenName)
			LoadScreen(ScreenName,"slideRight",Params,nil,1)
			return 1
		else
			return 0
		end
		
	end
	return true

end

	local function LoadCarePlanScreenFF(index)

		 if index == 2 then
			LoadScreen("carePlan_LifeHistoryFF","slideLeft")
		end

		 if index == 3 then
			LoadScreen("carePlan_KeyContactsFF","slideLeft")
		end		

		 if index == 4 then
			LoadScreen("carePlan_loadCareReviewFF","slideLeft")
		end	


		 if index == 5 then
			LoadScreen("carePlan_riskAssessmentsFF","slideLeft")
		end			

		 if index == 1 then
			LoadScreen("carePlan_personalDetailsFF","slideLeft")
		end		
		
		if index == 6 then
			LoadScreen("carePlan_MedicalVisitsFF","slideLeft")
		end				

		 if index == 8 then
			LoadScreen("carePlan_NotesFF","slideLeft")
		end		

		 if index == 7 then
			LoadScreen("carePlan_MedicationProfileFF","slideLeft")
		end		


	end

local function LoadAdminScreen(index)

	if index == 1 then
		LoadScreen("adminMenu","slideLeft")
	elseif index == 2 then
		LoadScreen("adminBasic","slideLeft")
	elseif index == 3 then
		LoadScreen("adminStaff","slideLeft")	
	elseif index == 4 then
		LoadScreen("adminResidents","slideLeft")
	elseif index == 5 then
		LoadScreen("corrections","slideLeft",nil,100,1)
	elseif index == 6 then
		LoadScreen("adminDevice","slideLeft")
	elseif index == 7 then
		LoadScreen("corrections","slideLeft")
	elseif index == 8 then
		LoadScreen("adminAdvanced","slideLeft")	
	elseif index == 9 then
		LoadScreen("adminMedicine","slideLeft")
	elseif index == 10 then
		LoadScreen("reports","slideLeft")
	elseif index == 13 then
		LoadScreen("carePlan_Monitoring","slideLeft")
	end	


end 
	 
local function LoadCarePlanScreen(index)
	

	local p = {}


	if index == 1 then
		LoadScreen("carePlan_personalDetails","slideLeft")
	elseif index == 2 then
		LoadScreen("carePlan_LifeHistory","slideLeft")
	elseif index == 3 then
		LoadScreen("carePlan_KeyContacts","slideLeft")	
	elseif index == 4 then
		LoadScreen("carePlan_documentLibrary","slideLeft")
	elseif index == 5 then
		LoadScreen("carePlan_loadCareReview","slideLeft",nil,100,1)
	elseif index == 6 then
		LoadScreen("carePlan_riskAssessments","slideLeft")
	elseif index == 7 then
		LoadScreen("carePlan_MedicationProfileNew","slideLeft")
	elseif index == 8 then
		LoadScreen("carePlan_MedicalVisits","slideLeft")	
	elseif index == 9 then
		LoadScreen("carePlan_Notes","slideLeft")
	elseif index == 10 then
		LoadScreen("carePlan_Summary","slideLeft")
	elseif index == 13 then
		LoadScreen("carePlan_Monitoring","slideLeft")
	elseif index == 20 then
		LoadScreen("carePlan_MedicationProfileMeds","slideLeft")
	elseif index == 21 then
		LoadScreen("carePlan_Emar","slideLeft")
	elseif index == 14 then
		p.Origin = 2
		p.ResidentID = _G.ClientID
		LoadScreen("IncidentAnalysis","slideLeft",p)
	end		

	
end

local _CloseOverlay = function(event)
	--print(_G.NetworkCallOn)

	if event.phase == "ended"  and _G.NetworkCallOn == false then
	
		storyboard.hideOverlay( "fade", 400 )
		_G.OverlayShow = false
	end
	return true
end


local StandardOverlay = function(ScreenTitle, CloseOverlayOverride, HideClose)

	_G.NetworkCallOn =false
	local gp = display.newGroup()
	gp:insert(StandardImage("screenOverlay.png",640/ 2,1136 / 2))
	
	gp:insert(StandardLabelBold(ScreenTitle,35,105,26,0,0,0))
	if HideClose == nil then
		if CloseOverlayOverride == nil then
			gp:insert(StandardImage("closeWindow.png",560,100,_CloseOverlay,nil,nil,1.5))	
		else		
			gp:insert(StandardImage("closeWindow.png",560,100,CloseOverlayOverride,nil,nil,1.5))	
		end
	end
	return gp
end

local function fitImage( displayObject, fitWidth, fitHeight )
	--
	-- first determine which edge is out of bounds
	--
	local scaleFactor = fitHeight / displayObject.height 
	local newWidth = displayObject.width * scaleFactor
	if newWidth > fitWidth then
		scaleFactor = fitWidth / displayObject.width 
	end
	displayObject:scale( scaleFactor, scaleFactor )
	return displayObject
end
			
  StandardImage = function(imageName, posX, posY, listener, id,withFrame, scale, width,height,maintainAspect, Orientation, Location, TargetWidth, TargetHeight )
	
	
		local gr = display.newGroup()
		local newImg 
			if Location == nil then
				newImg = display.newImage("Images/" .. imageName)
			elseif Location == "Resource" then
				newImg = display.newImage("Images/" .. imageName)
			elseif Location == "Documents" then
				newImg = display.newImage(imageName,system.DocumentsDirectory)
			elseif Location == "Temporary" then
				newImg = display.newImage(imageName,system.TemporaryDirectory)			
			end
			newImg.x =posX
			newImg.y =posY
			if width == nil then
				width = newImg.width
			end
			if height == nil then
				height = newImg.height
			end
			if maintainAspect ~= nil then
				newImg = fitImage(newImg,TargetWidth,TargetHeight )
				--[[
				if Orientation == "Portrait" then
					local  s = width/newImg.width
					newImg:scale(s, s)
				else
					local  s = height/newImg.height
					newImg:scale(s, s)					
				end]]
			else
				if width ~= nil then
					newImg.width = width
					if TargetWidth ~= nil then
						--if newImg.width > TargetWidth then
							newImg.width = TargetWidth
						--end
					end
				end
				if height ~= nil then
					newImg.height = height
					if TargetHeight ~= nil then
						--if newImg.height > TargetHeight then
							newImg.height = TargetHeight
					--	end
					end
				end
			end			



			if listener ~= nil then
				newImg:addEventListener("touch",listener)
			end
			if id ~= nil then
				newImg.id = id
			end
			if scale ~= nil then
				newImg.xScale = scale
				newImg.yScale = scale
			end

		if withFrame ~= nil then
			gr:insert( CreateBox(posX,posY,newImg.contentWidth,newImg.contentHeight))
		end
		gr:insert(newImg)
		return gr
		
	end
	
	DrawLine = function(leftx,lefty,rightx,righty,swidth,rcol,gcol,bcol)
		
		local ln = display.newLine( leftx,lefty, rightx, righty )
		ln:setStrokeColor( rcol, gcol, bcol)
		ln.strokeWidth = swidth
		
		return ln
		
	end
	local function CreateRadioButton(leftx, topy, idVal, initState, onSwitch)
		

		local state
	--	print(initState)
		if initState == nil then
			state = false
		elseif tonumber(initState) == 1 then
			state = true
		elseif tonumber(initState) == 0 then
			state = false
		else
			state = initState
		end

		local radioButton1 = widget.newSwitch
	{
	    left = leftx,
	    top = topy,
	    style = "radio",
	    id = idVal,
	    initialSwitchState = state,
	    onPress = onSwitch
	}
	return radioButton1
	
	end



	local function NiltoZero(obj)

		local retVal

		if obj == nil then
			retVal = 0
		elseif tonumber(obj) == nil then
			retVal = 0
		else
			retVal = tonumber(obj)
		end

		return retVal
	end

	local function NiltoString(obj)

		local retVal

		if obj == nil then
			retVal = ""
		else
			retVal = obj
		end

		return retVal
	end


	local function 	CreateYesNoButton(leftx, topy, idVal, initState, onSwitch)
		
		local state
		local ng = display.newGroup()

		if initState == nil then
			state = false
		elseif tonumber(initState) == 1 then
			state = true
		elseif tonumber(initState) == 0 then
			state = false
		else
			state = initState
		end

		if state then
			ng:insert(StandardImage("YesButtonOn.png",leftx + 15,topy + 15,onSwitch,idVal))
		else
			ng:insert(StandardImage("YesButtonOff.png",leftx + 15,topy + 15,onSwitch,idVal))
		end

--[[
		local radioButton1 = widget.newSwitch
	{
	    left = leftx,
	    top = topy,
	    style = "checkbox",
	    id = idVal,
	    initialSwitchState = state,
	    onPress = onSwitch
	}
	]]

	return ng
	
	end	

	local function CreateOnOffButton(leftx, topy, idVal, initState, onSwitch)

		local state

		if initState == nil then
			state = false
		elseif tonumber(initState) == 1 then
			state = true
		elseif tonumber(initState) == 0 then
			state = false
		else
			state = initState
		end

		
		local radioButton1 = widget.newSwitch
	{
	    left = leftx,
	    top = topy,
	    style = "onOff",
	    id = idVal,
	    initialSwitchState = state,
	    onPress = onSwitch
	}
	return radioButton1
	
	end		

	
	
	
	local function fileExists (fileName, base)
  assert(fileName, "fileName is missing")

  local base = base or system.ResourceDirectory
  local filePath = system.pathForFile( fileName, base )
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end

local function NumberPicker(posX, posY, NumberList,stIndex, listener,ref)

local RetGrp = display.newGroup()



-- Configure the picker wheel columns
local columnData = 
{
	
	    -- Numbers
    {
        align = "center",
        width = 60,
        startIndex = stIndex,
        labels = NumberList
    }

}

			PickerBlock = display.newRect(posX,posY+25, 360, 280 )
			PickerBlock.strokeWidth = 1
			PickerBlock:setFillColor( 1 )
			PickerBlock:setStrokeColor( 255/255, 0/255, 0/255)
	
			RetGrp:insert(PickerBlock)   	
	
     		smBut = SmallButton("OK",listener,"OK" .. ref)
		    smBut.x = posX - 60
		    smBut.y = posY + 135
			RetGrp:insert(smBut)	

     		smBut2 = SmallButton("Cancel",listener,"Cancel" .. ref)
		    smBut2.x = posX + 60
		    smBut2.y = posY + 135
			RetGrp:insert(smBut2)


-- Create the widget
local pickerWheel = widget.newPickerWheel
{
    top = 768 - 222,
    columns = columnData
}

	pickerWheel.x = posX
	pickerWheel.y = posY
	RetGrp:insert(pickerWheel)
	return(RetGrp)

end

function round(n)

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

end

local function TimePicker(posX, posY, listener,ref,dtValue)

local PickerBlock, smBut2, smBut
if dtValue == nil then
	
	dtValue = os.date( "%H:%M",os.time())
end
--print(dtValue)
--print("here1")
--print(tonumber(tonumber(string.sub(dtValue,4,5)) / 5))
local RetGrp = display.newGroup()

if ref == nil then
		ref = ""
end

local hours={}
local mins={}

		for h = 1, 24 do
		    hours[h] = string.rep("0",2-string.len(h-1)) .. h - 1
		end
		
		-- Populate the "mins" table
		for m = 1, 12 do
		    mins[m] = string.rep("0",2-string.len((m-1) * 5)) .. (m-1) * 5
		end
-- Configure the picker wheel columns
local timeData = 
		{
		
		    -- hours
		    {
		        align = "center",
		      --  width = 125,
		        startIndex = tonumber(string.sub(dtValue,1,2)) + 1,
		        labels = hours
		    },
    -- sep
		    { 
		        align = "center",
		        width = 50,
		        startIndex = 1,
		        labels = {":"}
		    },        
    -- mins
		    { 
		        align = "center",
		       -- width = 125,
		        startIndex = tonumber(round(tonumber(string.sub(dtValue,4,5)) / 5)),
		        labels = mins
		    },    
		}


	local PickerBlock = display.newRect(posX,posY+125, 600, 480 )
	PickerBlock.strokeWidth = 1
	PickerBlock:setFillColor( 1 )
	PickerBlock:setStrokeColor( 255/255, 0/255, 0/255)

	RetGrp:insert(PickerBlock)   	

	local smBut = WideButton2("OK",listener,"DPOK" .. ref)
    smBut.x = posX - 100
    smBut.y = posY + 330
	RetGrp:insert(smBut)	

	local smBut2 = WideButton2("Cancel",listener,"DPCancel" .. ref)
    smBut2.x = posX + 100
    smBut2.y = posY + 330
	RetGrp:insert(smBut2)

	--[[
			PickerBlock = display.newRect(posX,posY+25, 360, 350 )
			PickerBlock.strokeWidth = 1
			PickerBlock:setFillColor( 1 )
			PickerBlock:setStrokeColor( 255/255, 0/255, 0/255)
			PickerBlock:addEventListener("touch", function() return true end)
			PickerBlock:addEventListener("tap", function() return true end)

			RetGrp:insert(PickerBlock)   	
     		smBut = WideButton2("OK",listener,"DPOK" .. ref)
		    smBut.x = posX - 80
		    smBut.y = posY + 150
			RetGrp:insert(smBut)	

     		smBut2 =WideButton2("Cancel",listener,"DPCancel" .. ref)
		    smBut2.x = posX + 80
		    smBut2.y = posY + 150
			RetGrp:insert(smBut2)
]]

-- Create the widget
local pickerWheel = widget.newPickerWheel
{

	top = 900,
	columns = timeData,
    style = "resizable",
    width = 600,
    rowHeight = 70,
    fontSize = 35
}

	pickerWheel.x = posX
	pickerWheel.y = posY + 100

	RetGrp:insert(pickerWheel)
	return(RetGrp)

end

local function DatePicker(posX, posY, listener,ref,dtValue)
local days = {}
local months = {}
local years = {}
--print(dtValue)
if dtValue == nil then
	
	dtValue = os.date( "%d/%m/%Y",os.time())
end
--print(dtValue)
local RetGrp = display.newGroup()

if ref == nil then
		ref = ""
end

-- Populate the "days" table
for d = 1, 31 do
	if d < 10 then
		days[d] = "0" .. d
	else
	    days[d] = d
	end
end

-- Populate the "months" table
for y = 1, 12 do
	if y < 10 then
	    months[y] =  "0" .. y
	 else
	    months[y] =  y
	end	   
end

-- Populate the "years" table
for y = 1, 48 do
    years[y] = 2013 + y
end

-- Configure the picker wheel columns
local columnData = 
{
	
	    -- Days
    {
        align = "center",
        width = 60,
        startIndex = tonumber(string.sub(dtValue,1,2)),--tonumber(os.date( "%d",os.time())),
        labels = days
    },
    -- Months
    { 
        align = "center",
        width = 140,
        startIndex = tonumber(string.sub(dtValue,4,5)), -- tonumber(os.date( "%m",os.time())),
        labels =months
    },

    -- Years
    {
        align = "center",
        width = 80,
        startIndex = tonumber(string.sub(dtValue,7,10)) - 2013, -- tonumber(os.date( "%Y",os.time())) - 2013,
        labels = years
    }
}

			PickerBlock = display.newRect(posX,posY+25, 360, 280 )
			PickerBlock.strokeWidth = 1
			PickerBlock:setFillColor( 1 )
			PickerBlock:setStrokeColor( 255/255, 0/255, 0/255)
	
			RetGrp:insert(PickerBlock)   	
	
     		smBut = SmallButton("OK",listener,"DPOK" .. ref)
		    smBut.x = posX - 60
		    smBut.y = posY + 135
			RetGrp:insert(smBut)	

     		smBut2 = SmallButton("Cancel",listener,"DPCancel" .. ref)
		    smBut2.x = posX + 60
		    smBut2.y = posY + 135
			RetGrp:insert(smBut2)


-- Create the widget
local pickerWheel = widget.newPickerWheel
{
    top = 768 - 222,
    columns = columnData
}

	pickerWheel.x = posX
	pickerWheel.y = posY
	RetGrp:insert(pickerWheel)
	return(RetGrp)

end

local function cUSDate(UKDate)
	
	local retVal = ""
	if UKDate ~= nil then
	if string.len(UKDate) == 10 then
		retVal = string.sub(UKDate,4,5) .. "/" .. string.sub(UKDate,1,2).. "/" ..string.sub(UKDate,7,10)
	end
	end
	return retVal	
end


local DateDiffDays = function(Date1, Date2)

local d = 0
	if tostring(Date1) ~= "-1" and tostring(Date2) ~= "-1" then
		--print(cUSDate(Date2))
		--print(cUSDate(Date1))
		days = date.diff(cUSDate(Date2),cUSDate(Date1))
		d = days:spandays()
	end

	return d

end

local function CreateScrollArea(CentreXOffSet, CentreYOffSet, WidthOffSet, HeighOffset, HorizontalScroll, VerticalScroll, ScrollListener, Red, Green, Blue)

	local r, g, b

	if Red == nil then
		r = 1
		g = 1
		b = 1
	else
		r = Red
		g = Green
		b = Blue 	
	end

	local scView

	 scView = widget.newScrollView
	{
		x = display.contentWidth/2 + CentreXOffSet,
		y = 768/2 + CentreYOffSet,
		width = 1024- WidthOffSet,
		height = 768 - HeighOffset,
		bottomPadding = 90,
		topPadding = 20,
		id = "onBottom",
		horizontalScrollDisabled = HorizontalScroll,
		verticalScrollDisabled = VerticalScroll,
		listener = ScrollListener,
		backgroundColor = { r, g, b },
		hideScrollBar =false
	}

	return scView

end


ShowSimpleAlert = function(Title, Caption,Buttons, listener)



	
	if AlertWindow ~= nil then
		if AlertWindow.x ~= nil then
			AlertWindow:destroy()
		end
		AlertWindow = nil
	end

	AlertWindow =_G.GUI.Confirm(
		{
		name    = "WIN_ALERT2",
		modal   = true,
		theme   = _G.theme, 
		width   = "85%",
		scale   = 1.7,
		icon    = 14,
		title   = Title,
		caption = Caption, 
		onPress    = listener,
		buttons = { { icon = 15, caption = "Okay", }, },
		} )
end






local ShowSimpleQuestion = function(Title,Caption,Listener,Options)


	local Opts
	if Options == nil then
		Opts = {
				{icon = 15, caption = "Yes",},
				{icon = 16, caption = "No" ,},
			}
	else
		Opts = Options
	end

	_G.GUI.Confirm(
		{
		name       = "WIN_ALERT1",
		modal      = true,
		theme      = _G.theme, 
		width      = "85%",
		height     = "auto",
		scale      = 1.7,
		icon       = 14,
		fadeInTime = 500,
		title      = Title,
		caption    = Caption, 
		onPress    = function(EventData)  end,
		onRelease  = Listener,
		buttons    = Opts,
		} )
end


local NativeReplaceQuestion = function(Title,Caption,Array,CallBack)

	local QuestionCall = function(event)
				local i = event.button
				local event = {}
				event.action = "clicked"
				event.index = i
				CallBack(event)
			end

	ShowSimpleQuestion(Title,Caption,QuestionCall)
end

	local function CreateBoxedLabelExtra(LabelText, BoxWidth, BoxLeft, BoxY, FontSize, Alignment, Listener, RowID, ColID, BoxHeight, Bold)
		
		local gr = display.newGroup()
	
		local BoxX = BoxWidth * 0.5 + BoxLeft
		local bh
		if BoxHeight == nil then
			bh = 20
		else
			bh = BoxHeight
		end
		local fieldBox = display.newRect( BoxX, BoxY, BoxWidth, bh )
		fieldBox.strokeWidth = 2
		fieldBox.alpha = 0.5
		--fieldBox:setFillColor( 1 )
		if Listener ~= nil then
			fieldBox:addEventListener( "touch", Listener )
			fieldBox.rowID = RowID
			fieldBox.colID = ColID		
		end
		fieldBox:setStrokeColor( 166/255, 166/255, 166/255 )
		gr:insert(fieldBox)

		
		local ComboLab
		if Bold == nil then
			ComboLab = display.newText( gr, LabelText, 0, 0,"arial", FontSize )
		else
			ComboLab = display.newText( gr, LabelText, 0, 0,native.systemFontBold, FontSize )
		end
		if Alignment == "L" then
			ComboLab.x = (BoxLeft + (ComboLab.contentWidth / 2) + 5)
		end
		
		if Alignment == "C" then
			ComboLab.x = BoxLeft +  (BoxWidth / 2)
		end

		if Alignment == "R" then
			ComboLab.x =  (BoxLeft + BoxWidth) - (ComboLab.contentWidth / 2)
		end		
			
		ComboLab.y = BoxY

		--ComboLab:addEventListener( "touch", Listener )
		ComboLab:setFillColor(61/255, 61/255, 61/255)		
		return gr
	end

	


function is_valid_date(str)

  -- perhaps some sanity checks to see if `str` really is a date

  if str == nil then
  	return false
  end

  if string.len(str) ~= 10 then
  	return false
  end

  local d, m, y = str:match("(%d+)/(%d+)/(%d+)")

  m, d, y = tonumber(m), tonumber(d), tonumber(y)

  if d < 0 or d > 31 or m < 0 or m > 12 or y < 0 then
    -- Cases that don't make sense
    return false
  elseif m == 4 or m == 6 or m == 9 or m == 11 then 
    -- Apr, Jun, Sep, Nov can have at most 30 days
    return d <= 30
  elseif m == 2 then
    -- Feb
    if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
      -- if leap year, days can be at most 29
      return d <= 29
    else
      -- else 28 days is the max
      return d <= 28
    end
  else 
    -- all other months can have at most 31 days
    return d <= 31
  end

end

local LoadScreenPassword = function(screenName, effect, params, time)

	
	
		if time == nil then
			time = 800
		end

		local p = {}
		p.Location = screenName
		p.params = params
		p.effect = effect
		p.timeAmount = time
		LoadScreen("passwordCheck","slideLeft",p, 300,1)

end

function comma_value(amount)
  local formatted = amount
  local k
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

local  format_num = function(amount, decimal, prefix, neg_prefix)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end

        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 

        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end

local IsTime = function(TimeValue)

	-- I expect my time values to always be 5 charanters long
	local retVal = true

	if string.len(TimeValue) ~= 5 then
		retVal = false
	end

	if retVal then
		if tonumber(string.sub(TimeValue,1,2)) == nil then
			retVal = false
		end
	end

	if retVal then
		if tonumber(string.sub(TimeValue,1,2)) > 23 then
			retVal = false
		end
	end	

	if retVal then
		if tonumber(string.sub(TimeValue,4,5)) == nil then
			retVal = false
		end
	end		

	if retVal then
		if tonumber(string.sub(TimeValue,4,5)) > 59 then
			retVal = false
		end
	end		

	if retVal then
		if string.sub(TimeValue,3,3) ~= ":" then
			retVal = false
		end
	end		

	return retVal

end

 PushBackEntry = function(ScreenName,Params)

	local BackStruct = {}

	BackStruct.ScreenName = ScreenName
	BackStruct.Params = Params
	BackStruct.ClientID = _G.ClientID
	--print(ScreenName)
	table.insert(_G.BackStructure,BackStruct)

end

PopBackEntry = function()
	--print("pop called")
	table.remove(_G.BackStructure)

end


local GetTrueFalse = function(value)

	if tonumber(value) == 1 then
		return true
	else
		return false
	end

end

local GetOneZero = function(value)

	if value == true then
		return 1
	else
		return 0
	end

end

local LoadDataSet = function(ReturnedDataSet, DataSet, RowSplit, ColSplit, KeepData)

	--print(ReturnedDataSet.response)
	if RowSplit == nil then
		RowSplit = "Æ"
	end
	if ColSplit == nil then
		ColSplit = "ç"
	end

	local mainList, sublist, j, i, n
	local retVal = 0
	if (ReturnedDataSet.isError) then
		ShowSimpleAlert("Network Connection Error","There seems to be a problem connecting to Care Control.  Please try again.",{"OK"})
	else	
		if string.find(ReturnedDataSet.response, "User Not Active") ~= nil then
			ShowSimpleAlert("Account Not Active","Your account is not active.  Please check with your administrator with regards access through the Care Control Portal.",{"OK"})
		else
			if DataSet ~= nil and KeepData == nil then
				for i = 1,#DataSet do
					table.remove(DataSet)
				end
			end
			
			mainList = split(url.unescape(string.gsub(string.gsub(string.gsub(string.gsub(ReturnedDataSet.response,"&#x0D;", ""),"&amp;", "&"),"amp;",""), "&gt;", ">")),RowSplit)
			n = #DataSet + 1
			for i = 1,#mainList do
				DataSet[n] = {}
				sublist = split(mainList[i],ColSplit)
				for j = 1,#sublist do
					DataSet[n][j] =  sublist[j]
				end
				n = n + 1
			end
			retVal = 1
		end
	end

	return retVal
end

local ClearGroup = function(GroupDetails)


	if GroupDetails ~= nil then
		GroupDetails:removeSelf()
		GroupDetails = nil
	end
end

local ClearTextField = function(TextFieldName)

	if _G.GUI.GetHandle(TextFieldName) ~= nil then
	 	_G.GUI.GetHandle(TextFieldName):destroy()
	 end

end

local RefreshGroup = function(GroupDetails)


	if GroupDetails ~= nil then
		GroupDetails:removeSelf()
		GroupDetails = nil
	end

	GroupDetails = display.newGroup()

	return GroupDetails
end

local TransferList = function(Structure, Listname, Source, SeedList)


	for i = 1,#Listname do
		table.remove(Listname)
	end

	if SeedList ~= nil then
		for i = 1, #SeedList do
			Listname[#Listname + 1] = {}
			Listname[#Listname][1] = SeedList[i][1]
			Listname[#Listname][2] = SeedList[i][2]	
		end
	end

	for i = 1, #Source do

		if Source[i][1] == Structure then
			Listname[#Listname + 1] = {}
			Listname[#Listname][1] = Source[i][2]
			Listname[#Listname][2] = Source[i][3]
		end
	end


end


local GetListItem = function(ListName, Index, ValText)

	local RetVal = ""

	for i = 1,#ListName do
		if tostring(ListName[i][1]) == tostring(Index) then
			if ValText == "V" then
				RetVal = ListName[i][1]
			else
				RetVal = ListName[i][2]
			end
		end
	end
	return RetVal

end

local ClearLoadingStatus = function()

ClearGroup(_loadingStatus)

end

local ClearLoading = function()

ClearGroup(_loadingStatus)
ClearGroup(_loading)

end


local DisplayLoadingStatus = function(Loadstatus)

	ClearGroup(_loadingStatus)
	_loadingStatus = display.newGroup()
	_loadingStatus:insert(StandardLabelBold(Loadstatus,1024/ 2-70, 768/2 + 100,14,170/255,170/255,170/255))
	_loading:insert(_loadingStatus)

end

local DisplayLoading = function()

	
	_loading = RefreshGroup(_loading)
	_loading:insert(StandardImage("loading.jpg",1024/ 2, 768/2))
	return _loading

end


local PCall = function(CallText, delVal)

	local del

	if delVal == nil then
		del = 10
	else
		del = delVal
	end

	timer.performWithDelay(del,CallText)


end


local LoadHandoverScreen = function(ScreenID)

	if ScreenID == 1 then
		LoadScreen( "handover", "slideLeft", 800  )
	elseif ScreenID == 2 then
		LoadScreen( "handoverPhotoWall", "slideLeft", 800  )
	elseif ScreenID == 3 then
		LoadScreen( "handoverFluid", "slideLeft", 800  )
	elseif ScreenID == 5 then
		LoadScreen( "handoverMovement", "slideLeft", 800  )
	end


end


local LoadStandardListView = function (DataSet, TableList, HasCategory, CatRowHeight, RowHeight) 


		local crh, rh
		TableList:deleteAllRows()

		if CatRowHeight == nil then
			crh = 45
		else
			crh = CatRowHeight
		end

		if RowHeight == nil then
			rh = 35
		else
			rh = RowHeight
		end

		if HasCategory ~= nil then
			TableList:insertRow
			{
				isCategory=true,
				rowHeight  =crh,
				lineColor={212/255,212/255, 212/255},
				rowColor = 
				{ 
					default = { 57/255,100/255,152/255 },
				}, 
				params = 
				{
					Cat = 0
				}

			}			
		end


		for i = 1, #DataSet do
			TableList:insertRow
			{
				isCategory=false,
				rowHeight  =rh,
				lineColor={212/255,212/255, 212/255},
				rowColor = 
				{ 
					default = {  255/255,255/255, 255/255 },
				}, 
				params = 
					{
						rowid = i
				},

			}
			
		end
			
	return true
end

function WideButton2(ButtonText, onClickEvent,buttonID, posX, posY, fontSize)

		if fontSize == nil then
			fontSize = 22
		end

		local hsButton = widget.newButton
	{
		id = buttonID,
		defaultFile = "Images/widebtnDef.png",
		overFile = "Images/widebtnDefOver.png",
		label = ButtonText,
		labelColor = 
		{ 
			default = { 51/255, 51/255, 51/255 },
		},

		font="arial",
		fontSize =fontSize,	
		emboss = true,
		onEvent = onClickEvent,
	
	}
	

		hsButton.width=140
		hsButton.height =60		

	if posX ~= nil then
		hsButton.x = posX
		hsButton.y = posY
	end
	return hsButton
end	

local function PerceivedBrightness(c)
	local r = c[1] *255
	local g = c[2]*255
	local b = c[3]*255
    return math.sqrt(
    r * r * .241 +
    g* g * .691 +
    b * b* .068)
end

local function HourDiff(StartDate, EndDate)

	local dd1,mm1,yy1,hh1,nn1
	local dd2,mm2,yy2,hh2,nn2
	
	dd1 = string.sub(StartDate,1,2)
	mm1 = string.sub(StartDate,4,5)
	yy1 = string.sub(StartDate,7,10)

	hh1 = string.sub(StartDate,12,13)
	nn1 = string.sub(StartDate,15,16)

	dd2 = string.sub(EndDate,1,2)
	mm2 = string.sub(EndDate,4,5)
	yy2 = string.sub(EndDate,7,10)

	hh2 = string.sub(StartDate,12,13)
	nn2 = string.sub(StartDate,15,16)
	return ((os.time{year=yy2, month=mm2, day=dd2, hour=hh2, min=nn2} - os.time{year=yy1, month=mm1, day=dd1, hour=hh1, min=nn1})/60/60)

end

local function printTable( t )
 
    local printTable_cache = {}
 	local text = ""
    local function sub_printTable( t, indent )
 
        if ( printTable_cache[tostring(t)] ) then
            text  = text.. indent .. "*" .. tostring(t)
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                       text = text .. indent .. "[" .. pos .. "]->" .. tostring( t ).. " {" 
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        text = text .. indent .. string.rep( " ", string.len(pos)+6 ) .. "}" 
                    elseif ( type(val) == "string" ) then
                      text = text ..  indent .. "[" .. pos .. ']->'.. val 
                    else
                       text = text .. indent .. "[" .. pos .. "]->" .. tostring(val) 
                    end
                end
            else
                text = text .. indent..tostring(t) 
            end
        end
    end
 
    if ( type(t) == "table" ) then
        --print( tostring(t) .. " {" )
        sub_printTable( t, " " )
        --print( "}" )
    else
        sub_printTable( t, " " )
    end
    --print("FULL TEXT = " .. text)
    return text
end


local StandardPickerWheel = function(posX, posY,ref,listener,colData1,colData2,colData3,colStart1, colStart2, colStart3)
	
	if colData1 == nil then
		colData1 = {""}
	end
	if colData2 == nil then
		colData2 = {""}
	end
	if colData3 == nil then
		colData3 = {""}
	end

	if colStart1 == nil then
		colStart1 = 1
	end

	if colStart2 == nil then
		colStart2 = 1
	end

	if colStart3 == nil then
		colStart3 = 1
	end

	local RetGrp = display.newGroup()
	local PickerBlock = display.newRect(posX,posY+125, 600, 480 )
	PickerBlock.strokeWidth = 1
	PickerBlock:setFillColor( 1 )
	PickerBlock:setStrokeColor( 255/255, 0/255, 0/255)

	RetGrp:insert(PickerBlock)   	

	local smBut = WideButton2("OK",listener,"DPOK" .. ref)
    smBut.x = posX - 100
    smBut.y = posY + 330
	RetGrp:insert(smBut)	

	local smBut2 = WideButton2("Cancel",listener,"DPCancel" .. ref)
    smBut2.x = posX + 100
    smBut2.y = posY + 330
	RetGrp:insert(smBut2)

	local columnDatas = 
	{
		
		    -- Numbers
	    {
	        align = "center",
	       --width = 60,
	        startIndex = colStart1,
	        labels = colData1
	    },

	    {
	        align = "center",
	        --width = 60,
	        startIndex = colStart2,
	        labels = colData2
	    },

	   	{
	        align = "center",
	        --width = 60,
	        startIndex = colStart3,
	        labels = colData3
	    }
	}
	-- Create the widget
	local pickerWheel = widget.newPickerWheel
	{
    	top = 900,
    	columns = columnDatas,
	    style = "resizable",
	    width = 600,
	    rowHeight = 70,
	    fontSize = 35
	}

	pickerWheel.x = posX
	pickerWheel.y = posY + 100
	RetGrp:insert(pickerWheel)
	return(RetGrp)

end

local GamefadeScreen

local GamefadeScreen
local ImgDownload

local function LoadGameData(GameData)

	local gh
	local questions
	local qData
	GamefadeScreen = FadeScreen("Loading Game Data...")

	ImgDownload = 0

	local doc_path = system.pathForFile( "", system.TemporaryDirectory )
	for file in lfs.dir(doc_path) do
	    os.remove(system.pathForFile( file, system.TemporaryDirectory  ))
	end

	gh = split(url.unescape(string.gsub(string.gsub(string.gsub(string.gsub(GameData,"&#x0D;", ""),"&amp;", "&"),"amp;",""), "&gt;", ">")),"ç")
	_G.GameStructure = nil
	_G.GameStructure = {}
	_G.GameStructure[1] = {}
	_G.GameStructure[1].HostName = gh[1]
	_G.GameStructure[1].Category = gh[2]
	_G.GameStructure[1].AdultGame = gh[3]
	_G.GameStructure[1].GameType = gh[4]
	_G.GameStructure[1].TimeLimit = gh[5]
	_G.GameStructure[1].NoQuestions = gh[6]
	_G.GameStructure[1].WinnerGets = gh[7]
	_G.GameStructure[1].Forfiet = gh[8]
	_G.GameStructure[1].Stake = gh[9]
	_G.GameStructure[1].Questions = {}

	local function updateProgress( event )
		if ( event.phase == "ended" ) then
			ImgDownload = ImgDownload + 1
			if ImgDownload == #questions then
				if GamefadeScreen ~= nil then
					GamefadeScreen:removeSelf()
					GamefadeScreen = nil
				end
			end
       end
	end	

	questions = split(gh[10],"|")
	for i = 1,#questions do
		qData = split(questions[i],"~")
		_G.GameStructure[1].Questions[i] = {}
		_G.GameStructure[1].Questions[i].QuestionNum = qData[1]
		_G.GameStructure[1].Questions[i].QuestionID = qData[2]
		_G.GameStructure[1].Questions[i].QuestionText = qData[3]
		_G.GameStructure[1].Questions[i].ActualAnswer = qData[4]
		_G.GameStructure[1].Questions[i].MinRange = qData[5]
		_G.GameStructure[1].Questions[i].MaxRange = qData[6]
		_G.GameStructure[1].Questions[i].QUnit = qData[7]
		_G.GameStructure[1].Questions[i].Prefix = qData[8]
		_G.GameStructure[1].Questions[i].Suffix = qData[9]
		_G.GameStructure[1].Questions[i].HasImage = qData[10]
		_G.GameStructure[1].Questions[i].UseCommas = qData[11]
		_G.GameStructure[1].Questions[i].UserAnswer = ""
		_G.GameStructure[1].Questions[i].AnswerTime = ""

		print("http" .. _G.UseSSL .. "://".. _G.IPAddress  .. ":" .. _G.PortNumber .. 
			"/How/GetImage.ashx?QuestionID=" .. _G.GameStructure[1].Questions[i].QuestionID)
		network.download( "http" .. _G.UseSSL .. "://".. _G.IPAddress  .. ":" .. _G.PortNumber .. 
			"/How/GetImage.ashx?QuestionID=" .. _G.GameStructure[1].Questions[i].QuestionID, "GET", updateProgress, "img" .. 
			_G.GameStructure[1].Questions[i].QuestionID.. ".jpg", system.TemporaryDirectory)
	end

end


	ReturnTable.StandardPickerWheel = StandardPickerWheel
	ReturnTable.printTable = printTable
	ReturnTable.InitBackTable = InitBackTable
	ReturnTable.GoBack = GoBack
	ReturnTable.PushBackEntry = PushBackEntry
	ReturnTable.PopBackEntry = PopBackEntry
	ReturnTable.StandardTextField = StandardTextField
	ReturnTable.split = split
	ReturnTable.StandardLabel = StandardLabel
	ReturnTable.StandardButton = StandardButton
	ReturnTable.CreateSettingsFile = CreateSettingsFile
	ReturnTable.LoadSettingsFile =LoadSettingsFile
	ReturnTable.CreateStandardHeader =CreateStandardHeader
	ReturnTable.LargeButton = LargeButton
	ReturnTable.CreateListView = CreateListView
	ReturnTable.CreateComboBoxDropDown = CreateComboBoxDropDown
	ReturnTable.CreateBoxedLabel = CreateBoxedLabel
	ReturnTable.SmallButton = SmallButton
	ReturnTable.StandardTextBox2 = StandardTextBox2
	ReturnTable.WideButton = WideButton	
	ReturnTable.touch = touch
	ReturnTable.StandardNumericField = StandardNumericField
	ReturnTable.CreateBox = CreateBox	
	ReturnTable.StandardImage = StandardImage	
	ReturnTable.StandardLabel2 = StandardLabel2
	ReturnTable.StandardDisplayBox = StandardDisplayBox
	ReturnTable.MultilineLabel = MultilineLabel	
	ReturnTable.CreateBox2 = CreateBox2		
	ReturnTable.CreateRadioButton = CreateRadioButton
	ReturnTable.StandardTextBox= StandardTextBox	
	ReturnTable.OverlayShow = OverlayShow
	ReturnTable.FadeScreen = FadeScreen	
	ReturnTable.LoadScreen = LoadScreen
	ReturnTable.StandardLabelBold = StandardLabelBold	
	ReturnTable.DrawLine = DrawLine
	ReturnTable.CreateYesNoButton = CreateYesNoButton
	ReturnTable.CreateComboBoxDropDownLarge = CreateComboBoxDropDownLarge
	ReturnTable.fileExists = fileExists
	ReturnTable.CreateMenuHeader = CreateMenuHeader
	ReturnTable.DatePicker = DatePicker
	ReturnTable.NumberPicker = NumberPicker	
	ReturnTable.cUSDate = cUSDate
	ReturnTable.CreateBoxedLabelBold = CreateBoxedLabelBold
	ReturnTable.CreateBoxedLabelNew = CreateBoxedLabelNew
	ReturnTable.LoadCarePlanScreen = LoadCarePlanScreen
	ReturnTable.StandardLabelBoldW = StandardLabelBoldW
	ReturnTable.CreateOnOffButton = CreateOnOffButton
	ReturnTable.CreateScrollArea = CreateScrollArea
	ReturnTable.SuperLabel = SuperLabel
	ReturnTable.ShowSimpleAlert = ShowSimpleAlert
	ReturnTable.SuperDropDown = SuperDropDown
	ReturnTable.GetListValue = GetListValue
	ReturnTable.ClearListValue = ClearListValue
	ReturnTable.SetListValue = SetListValue
	ReturnTable.TimePicker = TimePicker
	ReturnTable.MultilineLabelEdit = MultilineLabelEdit
	ReturnTable.DestroyMultiLineEdits = DestroyMultiLineEdits
	ReturnTable.DestroyAMultiLineEdits = DestroyAMultiLineEdits
	ReturnTable.GetMultiLineText = GetMultiLineText
	ReturnTable.WriteStrapHeaderText = WriteStrapHeaderText
	ReturnTable.VerySmallButton = VerySmallButton
	ReturnTable.CreateBoxedLabelExtra = CreateBoxedLabelExtra
	ReturnTable.GetListText = GetListText
	ReturnTable.ShowSimpleEdit = ShowSimpleEdit
	ReturnTable.is_valid_date = is_valid_date
	ReturnTable.CoolEdit = CoolEdit
	ReturnTable.LoadScreenPassword = LoadScreenPassword
	ReturnTable.LoadCarePlanScreenFF = LoadCarePlanScreenFF
	ReturnTable.SuperDDRemoveListBox = SuperDDRemoveListBox
	ReturnTable.StandardDisplayBox2 = StandardDisplayBox2
	ReturnTable.format_num = format_num
	ReturnTable.SetMultiLineText = SetMultiLineText
	ReturnTable.NiltoZero = NiltoZero
	ReturnTable.NiltoString = NiltoString
	ReturnTable.IsTime = IsTime
	ReturnTable.DateDiffDays = DateDiffDays
	ReturnTable.ShowSimpleQuestion = ShowSimpleQuestion
	ReturnTable.CheckCreateLogFile = CheckCreateLogFile
	ReturnTable.LogSomething = LogSomething
	ReturnTable.CreateRoundBox = CreateRoundBox
	ReturnTable.StandardOverlay = StandardOverlay
	ReturnTable.StandardLabel2w = StandardLabel2w
	ReturnTable.NativeReplaceQuestion = NativeReplaceQuestion
	ReturnTable.GetTrueFalse = GetTrueFalse
	ReturnTable.GetOneZero = GetOneZero
	ReturnTable.LoadAdminScreen = LoadAdminScreen
	ReturnTable.NarrowDisplayBox = NarrowDisplayBox
	ReturnTable.GetPreviousScreen = GetPreviousScreen
	ReturnTable.LoadDataSet = LoadDataSet
	ReturnTable.StandardLabelBoldWNew = StandardLabelBoldWNew
	ReturnTable._CloseOverlay = _CloseOverlay
	ReturnTable.ClearGroup = ClearGroup
	ReturnTable.RefreshGroup = RefreshGroup
	ReturnTable.TransferList = TransferList
	ReturnTable.GetListItem = GetListItem
	ReturnTable.DisplayLoading = DisplayLoading
	ReturnTable.DisplayLoadingStatus = DisplayLoadingStatus
	ReturnTable.ClearLoading = ClearLoading
	ReturnTable.ClearLoadingStatus = ClearLoadingStatus
	ReturnTable.PCall = PCall
	ReturnTable.GetMultiLineMax = GetMultiLineMax
	ReturnTable.GetListIndex = GetListIndex
	ReturnTable.ClearHeaderTime = ClearHeaderTime
	ReturnTable.LoadHandoverScreen = LoadHandoverScreen
	ReturnTable.LoadStandardListView = LoadStandardListView
	ReturnTable.ClearTextField = ClearTextField
	ReturnTable.CreateConfigFile = CreateConfigFile
	ReturnTable.WideButton2 = WideButton2
	ReturnTable.LoadPocketMenu = LoadPocketMenu
	ReturnTable.GetCurrentScreen = GetCurrentScreen
	ReturnTable.clipTextByWidth = clipTextByWidth
	ReturnTable.LoadStaffSettingsFile = LoadStaffSettingsFile
	ReturnTable.PerceivedBrightness = PerceivedBrightness
	ReturnTable.HourDiff = HourDiff
	ReturnTable.CreateUserFile = CreateUserFile
	ReturnTable.LoadUserFile = LoadUserFile
	ReturnTable.LoadGameData = LoadGameData
	return ReturnTable