--require("string")
--require("sprite")

--[[
----------------------------------------------------------------
WIDGET CANDY FOR CORONA SDK
----------------------------------------------------------------
PRODUCT  :		WIDGET CANDY GUI LIBRARY
VERSION  :		1.1.75
AUTHOR   :		MIKE DOGAN / X-PRESSIVE.COM
WEB SITE :		http:www.x-pressive.com
SUPPORT  :		info@x-pressive.com
PUBLISHER:		X-PRESSIVE.COM
COPYRIGHT:		(C)2012,2013 MIKE DOGAN GAMES & ENTERTAINMENT

----------------------------------------------------------------

PLEASE NOTE:
A LOT OF HARD AND HONEST WORK HAS BEEN SPENT
INTO THIS PROJECT AND WE'RE STILL WORKING HARD
TO IMPROVE IT FURTHER.
IF YOU DID NOT PURCHASE THIS SOURCE LEGALLY,
PLEASE ASK YOURSELF IF YOU DID THE RIGHT AND
GET A LEGAL COPY (YOU'LL BE ABLE TO RECEIVE
ALL FUTURE UPDATES FOR FREE THEN) TO HELP
US CONTINUING OUR WORK. THE PRICE IS REALLY
FAIR. THANKS FOR YOUR SUPPORT AND APPRECIATION.

FOR FEEDBACK & SUPPORT, PLEASE CONTACT:
INFO@X-PRESSIVE.COM

]]--


-- TO HOLD VARIABLES AND FUNCTIONS
local V = {}

-- A WIDGET'S DEFAULT SETTINGS (IF NOT SPECIFIED)
V.Defaults =
	{
	alpha                   = 1.0,
	visible                 = true,
	x                       = "auto",
	y                       = "auto",
	width                   = "auto",
	height                  = "auto",
	scale                   = 1.0,
	zindex                  = 0,
	icon                    = 0,
	toggleButton            = false,
	toggleState             = false,
	group                   = "",
	enabled                 = true,
	textAlign               = "left",
	lineSpacing             = 0, -- TEXT
	border                  = {},
	value                   = 0,
	-- PROGBAR, SLIDER
	percent                 = 0, -- READONLY
	minValue                = 0,
	maxValue                = 1,
	-- FOR PARENT LAYOUT:
	includeInLayout         = true,
	newLayoutLine           = false,
	rightMargin             = 0,
	bottomMargin            = 0,
	leftMargin              = 0,
	topMargin               = 0,
	caption                 = "",
	-- FOR WINDOW
	slideOut                = .92,
	-- FOR LISTS
	scrollbarColor          = {1,1,1,1},
	scrollbarBGColor        = {0,0,0,.5},
	-- FOR CONTAINER WIDGETS:
	gradientDirection       = "left",
	shadow                  = false,
	dragX                   = false,
	dragY                   = false,
	stayOnTop               = false,
	closeButton             = false,
	resizable               = false,
	margin                  = 0,
	tapToFront              = true,
	}


-- UTF8 HELPER FUNCTIONS
V.utf8sub   = function (s, i, j)
	i = string.find(s, i, 1, true)
	if not i then return '' end 
	if j then local tmp = string.find(s, j, 1, true) if not tmp then return '' end j = (tmp - 1) + #j end
	return string.sub(s, i, j)
end
V.utf8len   = function (s) if s == nil then return 0 else return select(2, string.gsub(s, '[^\128-\193]', '')) end end
V.utf8char  = '[%z\1-\127\194-\244][\128-\191]*'
V.utf8map   = function (s, f) local i = 0; for b, c in string.gmatch(s, '()(' .. V.utf8char .. ')') do i = i + 1 f(i, c, b) end end
V.utf8iter  = function (s) return coroutine.wrap(function () return V.utf8map(s, coroutine.yield) end) end
V.utf8at    = function (s, x) for i, c, b in V.utf8iter(s) do if i == x then return c, b end end end
V.utf8lower = function (char) if string.lower(char) == char and V.KEYBOARD_CHARS_LOWER[char] ~= nil then return V.KEYBOARD_CHARS_LOWER[char] else return string.lower(char) end end

-- LIST OF (UTF8) CHARS NOT SUPPORTED BY string.lower / string.upper
V.KEYBOARD_CHARS_LOWER = 
	{
	["À"] = "à",["È"] = "è",["Ð"] = "ð",["Ø"] = "ø",
	["Á"] = "á",["É"] = "é",["Ñ"] = "ñ",["Ù"] = "ù",
	["Â"] = "â",["Ê"] = "ê",["Ò"] = "ò",["Ú"] = "ú",
	["Ã"] = "ã",["Ë"] = "ë",["Ó"] = "ó",["Û"] = "û",
	["Ä"] = "ä",["Ì"] = "ì",["Ô"] = "ô",["Ü"] = "ü",
	["Å"] = "å",["Í"] = "í",["Õ"] = "õ",["Ý"] = "ý",
	["Æ"] = "æ",["Î"] = "î",["Ö"] = "ö",["Þ"] = "þ",
	["Ç"] = "ç",["Ï"] = "ï",["×"] = "÷",["Ÿ"] = "ÿ",
	--["Š"] = "š",
	--["Ž"] = "ž",
	}


-- DEFAULT KEYBOARD SETTINGS (IF NOT SPECIFIED)
V.KeyboardDefaults =
	{
	height        = "50%",
	align         = "bottom",         -- "top" | "bottom"
	cursor        = "|",              -- CURSOR TO USE WHEN target IS SPECIFIED
	target        = nil,              -- INPUT TEXT WIDGET (WILL BE FILLED IN, IF SPECIFIED)
	case          = 0,                -- 0 = LOWER CASE, 1 = ONE LETTER UPPERCASE, 2 = SHIFT LOCK
	fontSize      = 22,               -- FONT SIZE (DEFAULT = THEME'S FONT SIZE)
	glossy        = true,             -- GLOSSY KEYS EFFECT
	margin        = 4,                -- KEY SPACING
	subTextDelay  = 350,              -- DELAY UNTIL SUBTEXT MENU IS SHOWN
	subTextSize   = 45,               -- SIZE OF SUBTEXT MENU
	corners       = 2,                -- KEY ROUNDED CORNER RADIUS
	bgColor       = {.1,.1,.15, .85}, -- KEYBOARD BG COLOR
	charColor1    = {1,1,1, 1},       -- KEY TEXT COLOR
	charColor2    = {1,.8,.5, .8},    -- KEY SUB-TEXT COLOR 
	keyColor1     = {.4,.4,.45, .75}, -- NORMAL KEYS COLOR
	keyColor2     = {.2,.2,.25, .75}, -- SPECIAL KEYS COLOR
	keyStroke     = {2, 1,1,1, .2},   -- KEY OUTLINE (BORDER) COLOR
	pressColor    = {1,1,1, .5},      -- KEY PRESS COLOR
	tapSound      = 4, 					
	subTextSound  = 2,					
	releaseSound  = 0,
	-- KEYBOARD LAYOUT, DEFINE UP TO 3 PAGES HERE:
	layout =
		{
		-- DEFINES THE GENERAL KEY PAGE
		page1 =
			{
			allowCase = true,
			{ {"Q","1"}, {"W","2"}, {"E","È","É","3","Ê","Ë"}, {"R","4"}, {"T","5"}, {"Y","Ÿ","6","Ý"}, {"U","Ù","Ú","7","Û","Ü"}, {"I","Ì","8","Î","Ï"}, {"O","Ø","Ò","Ó","9","Ô","Õ","Ö"}, {"P","0"} },
			{ {"A","À","Á","Â","@","Ã","Ä","Å","Æ"}, {"S","#","ß"}, {"D","§","&","Ð"}, {"F","*"}, {"G","-"}, {"H","+"}, {"J","="}, {"K","<","(","["}, {"L",">",")","]"} },
			{ {"SHIFT"}, {"Z","_"}, {"X","$","€"}, {"C","Ç"}, {"V","'"}, {"B",":"}, {"N",";","Ñ"}, {"M","/"}, {"DEL"} },
			{ {"PAGE2"}, {"PAGE3"},{","} , {"SPACE"}, {".",",","!","?"}, {"OK"}, {"CLEAR"} },
			},
		-- DEFINES THE NUMBERS KEY PAGE
		page2 =
			{
			allowCase = false,
			{ {"1"}  , {"2"}  , {"3"}, {"+"}, {"-"}    , {"@","%"}, {"#"}    , {"(","<"}, {")",">"} },
			{ {"4"}  , {"5"}  , {"6"}, {"*"}, {"/"}    , {"%","$","€"}, {"?"}    , {"!"}    , {"'"} },
			{ {"7"}  , {"8"}  , {"9"}, {","}, {"="}    , {"_","-"}, {":",";"}, {"DEL"} },
			{ {"PAGE1"}, {"PAGE3"}, {"0"}, {"."}, {"SPACE"}, {"OK"}   , {"CLEAR"} },
			},
		-- PAGE WITH SPECIAL CHARS (SMILEYS ETC.)
		page3 =
			{
			allowCase = false,
			{ {":-)"}  , {";-)"}  , {":-p"}, {":-/"}, {":-("}, {":-x"}, {":-*"} },
			{ {"8-)"}  , {"B-)"}  , {":-o"}, {":-D"}, {":-["}, {"<3"}, {"DEL"} },
			{ {"PAGE1"}, {"PAGE2"}, {"SPACE"}, {"OK"}   , {"CLEAR"} },
			},		
		},

	-- ICONS TO USE WITH THE FUNCTION KEYS (SHIFT KEY, SPACE KEY ETC.)
	icons =
		{
		SHIFT = 64,
		OK    = 63,
		DEL   = 62,
		SPACE = 61,
		CLEAR = 59,
		PAGE1 = 57,
		PAGE2 = 60,
		PAGE3 = 58,
		},
	}

V.Abs         = math.abs
V.Rnd         = math.random
V.Ceil        = math.ceil
V.Round       = math.round
V.Floor       = math.floor
V.Sin         = math.sin
V.Cos         = math.cos
V.Time        = system.getTimer
V.Stage       = display.getCurrentStage()
V.widgetCount = 0

-- WIDGET IDs
V.TYPE_WINDOW       = 1
V.TYPE_BORDER       = 2
V.TYPE_BUTTON       = 3
V.TYPE_SQUAREBUTTON = 4
V.TYPE_CHECKBOX     = 5
V.TYPE_RADIO        = 6
V.TYPE_TEXT         = 7
V.TYPE_PROGBAR      = 8
V.TYPE_SWITCH       = 9
V.TYPE_SLIDER       = 10
V.TYPE_LIST         = 11
V.TYPE_LABEL        = 12
V.TYPE_INPUT        = 13
V.TYPE_DRAGBUTTON   = 14
V.TYPE_IMAGE        = 15
V.TYPE_ICONBAR      = 16
V.TYPE_SHAPEBUTTON  = 17
V.TYPE_TEXT_SIMPLE  = 18
V.TYPE_CUSTOMLIST   = 19
V.TYPE_CALENDAR     = 20
V.TYPE_SCROLLVIEW   = 21
V.TYPE_CONTAINER    = 22


-- TO STORE LOADED THEMES
V.Themes       = {}
V.defaultTheme = ""

-- TO STORE EXISTING WIDGETS
V.Widgets      = {}

-- TOP-SCREEN INPUT FIELD
V.Input        = nil

-- MODAL DIALOG SCREEN FADE
V.ModalGrp     = nil
V.Fader        = nil
V.numModals    = 0

----------------------------------------------------------------
-- GLOBALLY ENABLE / DISABLE TAP / RELEASE SOUNDS
----------------------------------------------------------------
V.SetSounds = function(tapSound, releaseSound, changeSound, selectSound)
	V.Defaults.tapSound     = tapSound
	V.Defaults.releaseSound = releaseSound
	V.Defaults.changeSound  = changeSound
	V.Defaults.selectSound  = selectSound

	local name, Widget
	for name,Widget in pairs(V.Widgets) do 
		if Widget.Props then
			Widget.Props.tapSound     = tapSound 
			Widget.Props.releaseSound = releaseSound 
			Widget.Props.changeSound  = changeSound 
			Widget.Props.selectSound  = selectSound 
		end
	end
end

----------------------------------------------------------------
-- SET AUDIO CHANNEL FOR WIDGET SOUND PLAYBACK
----------------------------------------------------------------
V.muted           = false
V.channel         = 1
V.SetAudioChannel = function(channel) V.channel = channel end
V.Mute            = function(state  ) V.muted   = state   end

----------------------------------------------------------------
-- PUBLIC: ENABLE / DISABLE PRESS HIGHLIGHT EFFECT
----------------------------------------------------------------
V.Highlight    = nil

V.ShowTouches = function(state, size, color, theme)
	local Theme
	-- DISABLE?
	if state == false and V.Highlight ~= nil then V.Highlight:removeSelf(); V.Highlight = nil ; return end

	-- ENABLE?
	size  = (size  == nil and 128 or size)
	color = (color == nil and {1,1,1} or color)
	-- LOAD IMAGE
	if V.Highlight == nil then
		Theme = (theme == nil and V.Themes[next(V.Themes)] or V.Themes[theme])
		if Theme == nil then V.error("!!! WIDGET ERROR: EnableHighlight(): No theme loaded or specified theme does not exist!"); return end
		V.Highlight = V.newSprite(Theme.Set, Theme.Frame_PressHighlight)
		V.Highlight.anchorX   = .5
		V.Highlight.anchorY   = .5
		V.Highlight.blendMode = "add"
		V.Highlight.isVisible = false
	end
	-- CONFIGURE
	V.Highlight.xScale    = size / V.Highlight.width
	V.Highlight.yScale    = size / V.Highlight.height
	V.Highlight.sx        = V.Highlight.xScale
	V.Highlight.sy        = V.Highlight.yScale
	V.Highlight:setFillColor(color[1],color[2],color[3],1)
end
-- PRIVATE
V._ShowTouch = function(x,y)
	V.Stage:insert(V.Highlight)
	V.Highlight.isVisible = true
	V.Highlight.x = x
	V.Highlight.y = y
	V.Highlight.xScale = V.Highlight.sx
	V.Highlight.yScale = V.Highlight.sy
	V.Highlight.alpha  = 1
	transition.to(V.Highlight, {time = 250, alpha = 0, xScale = .1, yScale = .1, onComplete = function() V.Highlight.isVisible = false  end })
end

----------------------------------------------------------------
-- PRIVATE: GET SCREEN SIZE / DISPLAY HAS BEEN ROTATED
----------------------------------------------------------------
V.screenW                = display.viewableContentWidth
V.screenH                = display.viewableContentHeight ; if (system.getInfo("model") == "Kindle Fire") then V.screenH = display.contentHeight - 20 end
V.physicalW              = math.round( (V.screenW - display.screenOriginX*2) )
V.physicalH              = math.round( (V.screenH - display.screenOriginY*2) )
V.top                    = display.screenOriginY
V.bottom                 = display.screenOriginY + V.physicalH
V.left                   = display.screenOriginX
V.right                  = display.screenOriginX + V.physicalW
V.allowedOrientations    = {"landscapeRight","landscapeLeft","portrait","portraitUpsideDown"}
V.SetAllowedOrientations = function(list) V.allowedOrientations = list end

V._onRotate = function(event)
	local allowed = false
	for i = 1, #V.allowedOrientations do
		if event.type == V.allowedOrientations[i] then allowed = true end
	end
	if allowed == false then return end
	
	V.screenW   = display.viewableContentWidth
	V.screenH   = display.viewableContentHeight ; if (system.getInfo("model") == "Kindle Fire") then V.screenH = display.contentHeight - 20 end
	V.physicalW = math.round( (V.screenW - display.screenOriginX*2) )
	V.physicalH = math.round( (V.screenH - display.screenOriginY*2) )
	V.top       = display.screenOriginY
	V.bottom    = display.screenOriginY + V.physicalH
	V.left      = display.screenOriginX
	V.right     = display.screenOriginX + V.physicalW

	local name, Widget
	-- UPDATE WINDOWS
	for name,Widget in pairs(V.Widgets) do 
		if Widget.typ == V.TYPE_WINDOW then
			V._CheckProps(Widget); Widget:_update(); Widget:layout(true) 
		end
	end
	-- UPDATE WIDGETS
	for name,Widget in pairs(V.Widgets) do 
		if Widget.typ ~= V.TYPE_WINDOW then
			V._CheckProps(Widget); Widget:_update() 
		end
	end
	
	-- RE-ADJUST MODAL FADER?
	if V.Fader ~= nil then
		V.Fader.x     = display.screenOriginX
		V.Fader.y     = display.screenOriginY
		if V.Fader[1] ~= nil then V.Fader[1]:removeSelf() end
		Tmp         = display.newRect(V.Fader,0,0,V.physicalW,V.physicalH)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp:setFillColor (0,0,0,.5)
		Tmp.strokeWidth = 0
	end
end
Runtime:addEventListener( "orientation"	, V._onRotate )


----------------------------------------------------------------
-- PUBLIC: SET LOG LEVEL
----------------------------------------------------------------
V.SetLogLevel = function(level)
	-- ON DEVICE, SHOW ERRORS ONLY 
	if system.getInfo("environment") ~= "simulator" then level = 1 end
	-- NO MESSAGES
	    if level == 0 then V.print = function() end; V.error = function() end
	-- ERROR MESSAGES ONLY
	elseif level == 1 then V.print = function() end; V.error = print
	-- EVERYTHING
	else V.print = print; V.error = print end
	
	print()
	print("*** WIDGET CANDY INITIALIZED ***")
	print("USE SetLoglevel(1) TO SHOW WIDGET CANDY ERRORS ONLY (DEFAULT).")
	print("USE SetLoglevel(2) TO SHOW ALL WIDGET CANDY MESSAGES.")
	print()
end
V.SetLogLevel(1)

----------------------------------------------------------------
-- PRIVATE: VERIFY A WIDGET'S EXISTING PROPERTY COLLECTION
----------------------------------------------------------------
V._CheckProps = function ( Widget)
	local Props = Widget.Props
	local Theme = V.Themes[Props.theme]
	if Theme == nil then V.error("!!! WIDGET ERROR: _CheckProps(): Unknown theme '"..Props.theme.."' for widget '"..Props.name.."'."); return end
	V.Defaults.name      = "Widget"..V.widgetCount
	--V.Defaults.fontSize  = Theme.WidgetFontSize
	V.Defaults.minWidth  = Props.minW
	V.Defaults.maxWidth  = Props.maxW
	V.Defaults.minHeight = Props.minH
	V.Defaults.maxHeight = Props.maxH
	
	-- APPLY THEME COLOR?
	if Props.color == nil then Props.color = Theme.color end
	
	local k,v; for k,v in pairs(V.Defaults) do 
		if Props[k] == nil then Props[k] = V.Defaults[k] elseif Props[k] == "" then Props[k] = V.Defaults[k] end 
		if Props.fontSize     == nil then Props.fontSize = Theme.WidgetFontSize end
		if Props.iconSize     == nil then 
			    if Widget.typ == V.TYPE_LIST or Widget.typ == TYPE_CUSTOMLIST then Props.iconSize = Theme.ListIconSize 
			elseif Widget.typ == V.TYPE_WINDOW then Props.iconSize = Theme.WindowIconSize
			  else Props.iconSize = Theme.ButtonIconSize end
		end
	end
	
	-- SET PARENT
	Props.parentGroup = V._SetWidgetParent(Widget, Props.parentGroup)

	-- CAPTION: REMOVE NEW LINES / CONVERT BOOLEAN TO STRING
	if type(Props.caption) == "boolean" then       
		Props.caption = Props.caption == true and "true" or "false" 
	end 
	Props.caption = tostring(Props.caption):gsub("\n", "|") 
	
	if Props.minWidth      < V.Defaults.minWidth  * Props.scale then Props.minWidth  = V.Defaults.minWidth  * Props.scale end
	if Props.minHeight     < V.Defaults.minHeight * Props.scale then Props.minHeight = V.Defaults.minHeight * Props.scale end
	    if Props.maxWidth  < Props.minWidth       * Props.scale then Props.maxWidth  = Props.minWidth       * Props.scale 
	elseif Props.maxWidth  > Props.maxW           * Props.scale then Props.maxWidth  = Props.maxW           * Props.scale end
	    if Props.maxHeight < Props.minHeight      * Props.scale then Props.maxHeight = Props.minHeight      * Props.scale 
	elseif Props.maxHeight > Props.maxH           * Props.scale then Props.maxHeight = Props.maxH           * Props.scale end

	--if Props.minWidth      < V.Defaults.minWidth  then Props.minWidth  = V.Defaults.minWidth end
	--if Props.minHeight     < V.Defaults.minHeight then Props.minHeight = V.Defaults.minHeight end
	--    if Props.maxWidth  < Props.minWidth       then Props.maxWidth  = Props.minWidth 
	--elseif Props.maxWidth  > Props.maxW           then Props.maxWidth  = Props.maxW end
	--    if Props.maxHeight < Props.minHeight      then Props.maxHeight = Props.minHeight 
	--elseif Props.maxHeight > Props.maxH           then Props.maxHeight = Props.maxH end

	if Props.Shape == nil then Props.Shape = {} end
	V._SetSize      (Widget)
	V._SetPos       (Widget)
end


----------------------------------------------------------------
-- PRIVATE: GET MINX,MAXX,MINY,MAXY,WIDTH,HEIGHT OF A WIDGETS PARENT
----------------------------------------------------------------
V._GetParentShape = function ( Widget )
	local P         = {}
	P.insideWidget  = Widget.parent.isContainer
	P.insideGroup   =(P.insideWidget ~= true and Widget.parent ~= V.Stage) and true or false

	-- INSIDE A WIDGET? (GETS LOCAL COORDINATES)
	if P.insideWidget == true then
		local ParentProps = Widget.parent.parent.Props
		P.minX  = ParentProps.margin
		P.maxX  = ParentProps.Shape.w - ParentProps.margin
		P.minY  = ParentProps.margin
		P.maxY  = ParentProps.Shape.h - ParentProps.margin - V.Themes[ParentProps.theme].widgetFrameSize
		P.w     = P.maxX - P.minX
		P.h     = P.maxY - P.minY
	-- INSIDE A GROUP? (GETS SCREEN COORDINATES)
	elseif P.insideGroup == true then
		local Group = Widget.parent
		if Group.bounds == nil then Group.bounds = {0,0,V.screenW,V.screenH} end -- TOP,LEFT,WIDTH,HEIGHT
		P.minX   = Group.bounds[1]
		P.maxX   = Group.bounds[1] + Group.bounds[3]
		P.minY   = Group.bounds[2]
		P.maxY   = Group.bounds[2] + Group.bounds[4]
		P.w      = Group.bounds[3]
		P.h      = Group.bounds[4]
	-- NO PARENT? (GETS SCREEN COORDINATES)
	else
		P.minX   = 0
		P.maxX   = V.screenW
		P.minY   = 0
		P.maxY   = V.screenH
		P.w      = V.screenW
		P.h      = V.screenH
	end

	return P
end

----------------------------------------------------------------
-- PRIVATE: SET A WIDGET'S SIZE, CALCULATE STRING TO VALUE
----------------------------------------------------------------
V._SetSize = function (Widget)
	local Props  = Widget.Props
	local Shape  = Widget.Props.Shape
	local PShape = V._GetParentShape(Widget)

	-- WIDTH
	if Props.width == "auto" then 
		if Shape.w == nil then Shape.w = Props.minWidth end
	else 
		Shape.w = type(Props.width ) == "string" and (PShape.w/100) *  (Props.width:sub(1,Props.width:len()-1)) or Props.width 
	end

	       Shape.w = Shape.w * (1/Props.scale)
		if Shape.w < Props.minWidth * (1/Props.scale) then Shape.w = Props.minWidth* (1/Props.scale) 
	elseif Shape.w > Props.maxWidth * (1/Props.scale) then Shape.w = Props.maxWidth* (1/Props.scale) end

	-- HEIGHT
	if Props.height == "auto" then 
		if Shape.h == nil then Shape.h = Props.minHeight * (1/Props.scale) end
	else 
		Shape.h = type(Props.height) == "string" and (PShape.h/100) *  (Props.height:sub(1,Props.height:len()-1)) or Props.height 
	end

	       Shape.h = Shape.h * (1/Props.scale)
	    if Shape.h < Props.minHeight * (1/Props.scale) then Shape.h = Props.minHeight* (1/Props.scale) 
	elseif Shape.h > Props.maxHeight * (1/Props.scale) then Shape.h = Props.maxHeight* (1/Props.scale) end

	Shape.w = V.Floor(Shape.w)
	Shape.h = V.Floor(Shape.h)
	
end

----------------------------------------------------------------
-- PRIVATE: SET A WIDGET'S POS, CALCULATE STRING TO VALUE
----------------------------------------------------------------
V._SetPos = function (Widget)
	local tmp
	local Props  = Widget.Props
	local Shape  = Widget.Props.Shape
	local PShape = V._GetParentShape(Widget)

	-- XPOS
	if Props.x == "auto" then
		if Shape.x == nil then Shape.x = 0 end
	else
		Shape.x = Props.x
		if type(Props.x) == "string"   then
				if Props.x == "left"   then Shape.x = PShape.minX
			elseif Props.x == "center" then Shape.x = PShape.minX + PShape.w*.5 - (Shape.w * Props.scale)*.5
			elseif Props.x == "right"  then Shape.x = PShape.maxX - (Shape.w * Props.scale)
			elseif string.find(Props.x,"%",1,true) then Shape.x = PShape.minX + (PShape.w/100) *  tonumber(Props.x:sub(1,Props.x:len()-1))
			else   Props.x = 0; V.error("!!! WIDGET ERROR: INVALID X-POS SPECIFIED FOR WIDGET '"..Props.name.."'") end
			-- REFERS TO SCREEN COORDS?
			--if PShape.insideGroup then Shape.x, tmp = Widget.parent:contentToLocal(Shape.x, 0) end
		end
	end

	-- YPOS
	if Props.y == "auto" then
		if Shape.y == nil then Shape.y = 0 end
	else
		Shape.y = Props.y
		if type(Props.y) == "string"   then
				if Props.y == "top"    then Shape.y = PShape.minY
			elseif Props.y == "center" then Shape.y = PShape.minY + PShape.h*.5 - (Shape.h * Props.scale)*.5
			elseif Props.y == "bottom" then Shape.y = PShape.maxY - (Shape.h * Props.scale)
			elseif string.find(Props.y,"%",1,true) then Shape.y = PShape.minY + (PShape.h/100) *  tonumber(Props.y:sub(1,Props.y:len()-1)) 
			else   Props.y = 0; V.error("!!! WIDGET ERROR: INVALID Y-POS SPECIFIED FOR WIDGET '"..Props.name.."'") end
			-- REFERS TO SCREEN COORDS?
			--if PShape.insideGroup then tmp, Shape.y = Widget.parent:contentToLocal(0, Shape.y) end
		end
	end

	Shape.x  = V.Floor(Shape.x)
	Shape.y  = V.Floor(Shape.y)
	Widget.x = Shape.x
	Widget.y = Shape.y
end

----------------------------------------------------------------
-- PRIVATE: SET A WIDGET'S PARENT (WINDOW, GROUP OR STAGE)
----------------------------------------------------------------
V._SetWidgetParent = function (Widget, newParent)

	local Props = Widget.Props
	local name  = ""; if Props ~= nil and Props.name ~= nil then name = Props.name end

	-- SAME PARENT AS BEFORE?
	if Widget.parent == newParent or (Widget.parent.parent ~= nil and Widget.parent.parent.Props ~= nil and Widget.parent.parent == newParent) then 
		if Props.zindex > 0 then Widget.parent:insert(Props.zindex,Widget) end
		return newParent 
	end

	Props.myWindow = ""

	-- NO PARENT SPECIFIED? SET TO STAGE!
	if newParent == nil then newParent = V.Stage end

	-- PARENT IS ANOTHER WIDGET?
	if newParent~= nil and type(newParent) == "string" then
		local P = V.Widgets[newParent]
	
		-- PARENT WIDGET DOES NOT EXIST?
		if P == nil or (P ~= nil and P.Widgets == nil) or Widget.typ == V.TYPE_WINDOW then
			print("!!! WIDGET ERROR: Can't insert widget "..name.." into specified parent." ) 
			return nil
		-- OK
		else
			Props.myWindow = P.Props.name
			if Props.zindex > 0 then 
				P.Widgets:insert(Props.zindex,Widget) 
			else 
				P.Widgets:insert(Widget)
			end
			V.print("--> Widgets: Inserted widget "..name.." to parent '"..P.Props.name.."'.")
			return P
		end
	end

	-- INSERT TO A GROUP OR STAGE?	
	if newParent ~= nil then
		if Props.zindex > 0 then 
			newParent:insert(Props.zindex,Widget) 
		else 
			newParent:insert(Widget) 
		end
		V.print("--> Widgets: Inserted widget "..name.." into display group or stage.")
		return newParent
	end

end


----------------------------------------------------------------
-- PRIVATE: AUTOMATICALLY ARRANGE ALL WIDGETS INSIDE A WINDOW OR FRAME
----------------------------------------------------------------
V._ArrangeWidgets = function (Win, doScreenAlign)
	if Win.Widgets == nil then V._ArrangeWidget(Win); return end

	V.print("--> Widgets: Calculating layout for window "..Win.Props.name)
	
	--Win.maxY = Win.Props.minHeight

	local i

	-- LOOP THROUGH WINDOW'S WIDGETS, ARRANGE
	for i = 1, Win.Widgets.numChildren do
		--if Win.Widgets[i].Props.x == "auto" or Win.Widgets[i].Props.y == "auto" then 
		if Win.Widgets[i].Props.includeInLayout == true then 
			V._ArrangeWidget(Win.Widgets[i]) 
			-- WINDOW AUTO HEIGHT
			if Win.Props.height  == "auto" then  
				h =  Win.Widgets.y + Win.Widgets[i].Props.Shape.y + Win.Widgets[i].Props.Shape.h
			end
		end
	end

	-- NEW WINDOW AUTO HEIGHT?
	if Win.Props.height  == "auto" then 
		if Win.Props.minHeight and h < Win.Props.minHeight * (1/Win.Props.scale) then h = Win.Props.minHeight * (1/Win.Props.scale) end
		Win.Props.Shape.h = h + Win.Props.margin
		if doScreenAlign == true then V._SetPos(Win) end -- SCREEN ALIGN
		Win:_update( )
	end

	-- NOW RE-ADJUST ANY AUTO-SIZE BORDER WIDGETS
	for i = 1, Win.Widgets.numChildren do
		if Win.Widgets[i].typ == V.TYPE_BORDER and Win.Widgets[i].Props.group ~= "" then 
			Win.Widgets[i]:_update() 
		end
	end
end

----------------------------------------------------------------
-- PRIVATE: AUTOMATICALLY ARRANGE A WIDGET INSIDE A WINDOW OR FRAME
----------------------------------------------------------------
V._ArrangeWidget = function (Widget)
	if Widget.Props == nil then V.error("!!! WIDGET ERROR: ArrangeWidgets(): Invalid widget handle."); return end

	local i, depth, W, WShape, set
	local Widgets = Widget.parent
	local Props   = Widget.Props
	local Win     = Widgets.parent
	local Shape   = Widget.Props.Shape
	local minX    = Win.Props.margin
	local maxX    = Win.Props.Shape.w - Win.Props.margin
	local x       = minX + Props.leftMargin
	local y       = Props.topMargin

	-- FIND THIS WIDGET'S DEPTH
	for i = 1,Widgets.numChildren do if Widgets[i] == Widget then depth = i; break end end

	-- LOOP WIDGETS BACKWARDS
	for i = depth-1,1,-1 do
		W      = Widgets[i]
		WShape = W.Props.Shape
		if W.Props.includeInLayout == true then
			-- ALIGN TO FIRST AUTOINCLUDE ANCESTOR FOUND
			if set ~= true then
				set = true
				x   = WShape.x + WShape.w + W.Props.rightMargin + Props.leftMargin
				y   = WShape.y + Props.topMargin
				-- NEW LINE OR EXCEED WINDOW WIDTH? NEXT LINE!
				if Props.newLayoutLine or (Win.Props.width ~= "auto" and x + Shape.w > maxX) then 
					x = minX + Props.leftMargin
					y = WShape.y + WShape.h + W.Props.bottomMargin + Props.topMargin
				end
			-- OVERLAPPING ANY EARLIER ANCESTOR? 
			elseif y < WShape.y + WShape.h and x < WShape.x + WShape.w then 
				x = WShape.x + WShape.w + W.Props.rightMargin
				if Win.Props.width ~= "auto" and x + Shape.w > maxX then
					x = minX + Props.leftMargin
					y = WShape.y + WShape.h + W.Props.bottomMargin + Props.topMargin
				end
			end
		end
	end
	if Props.x == "auto" then Shape.x = V.Floor(x); Widget.x = Shape.x end
	if Props.y == "auto" then Shape.y = V.Floor(y); Widget.y = Shape.y end

end


----------------------------------------------------------------
-- PRIVATE: SHORTEN A GADGET TEXT TO STAY WITHIN A GIVEN WIDTH
----------------------------------------------------------------
V._WrapGadgetText = function (Obj, maxw, font, size)
	maxw = maxw * 2
	if Obj.width <= maxw or Obj.text == "" then return end
	local txt = Obj.text
	local len = txt:len()
	local cnt = 1
	Obj.text  = ""

	while cnt <= len do 
		Obj.text = txt:sub(1,cnt)
		if Obj.width > maxw + 4 then
			cnt = cnt - 3; if cnt < 1 then cnt = 1 end
			Obj.text = txt:sub(1,cnt).."..."
			break
		end
		cnt = cnt + 1
	end
end


----------------------------------------------------------------
-- PRIVATE: ADD A BORDER TO A WIDGET {"type", [cornerRadius], [strokeWidth], [R],[G],[B],[A], [R],[G],[B],[A]}
----------------------------------------------------------------
V._AddBorder = function (Widget)
	while Widget[1].numChildren > 0 do Widget[1][1]:removeSelf() end

	local Tmp1, Tmp2
	local Props  = Widget.Props
	local w      = Props.Shape.w
	local h      = Props.Shape.h
	local Theme  = V.Themes [Props.theme]
	
	-- ADD SHAPE BORDER?
	if Props.border[1] ~= nil then
		local corner = Props.border[2] == nil and 2   or Props.border[2]
		local stroke = Props.border[3] == nil and 1   or Props.border[3]
		local R      = Props.border[4] == nil and 0   or Props.border[4]
		local G      = Props.border[5] == nil and 0   or Props.border[5]
		local B      = Props.border[6] == nil and 0   or Props.border[6]
		local A      = Props.border[7] == nil and 1   or Props.border[7]

		if Props.border[1] == "normal" then
			Tmp1              = display.newRoundedRect(Widget[1],stroke,stroke,w-stroke*2,h-stroke*2,corner)
			Tmp1.anchorX      = 0
			Tmp1.anchorY      = 0
			Tmp1.strokeWidth  = stroke
			Tmp1:setFillColor  (Props.border[4],Props.border[5],Props.border[6],Props.border[7])
			Tmp1:setStrokeColor(Props.border[8],Props.border[9],Props.border[10],Props.border[11])
		elseif Props.border[1] == "shadow" then
			Tmp1              = display.newRoundedRect(Widget[1],Props.border[3],Props.border[3],w,h,corner)
			Tmp1.anchorX      = 0
			Tmp1.anchorY      = 0
			Tmp1.strokeWidth  = 0
			Tmp1:setFillColor  (0,0,0,Props.border[4])
			Tmp1:setStrokeColor(0,0,0,0)
		else
			Tmp1             = display.newRoundedRect(Widget[1],stroke*2,stroke*2,w-stroke*3,h-stroke*3,corner)
			Tmp1.anchorX     = 0
			Tmp1.anchorY     = 0
			Tmp1.strokeWidth = stroke
			Tmp1:setFillColor (Props.border[4],Props.border[5],Props.border[6],Props.border[7])

			Tmp2             = display.newRoundedRect(Widget[1],stroke,stroke,w-stroke*3,h-stroke*3,corner)
			Tmp2.anchorX     = 0
			Tmp2.anchorY     = 0
			Tmp2.strokeWidth = stroke
			Tmp2:setFillColor (0,0,0,0)

			    if Props.border[1] == "inset"  then Tmp1:setStrokeColor(Theme.EmbossColorHigh[1],Theme.EmbossColorHigh[2],Theme.EmbossColorHigh[3],1); Tmp2:setStrokeColor(Theme.EmbossColorLow[1],Theme.EmbossColorLow[2],Theme.EmbossColorLow[3],1)
			elseif Props.border[1] == "outset" then Tmp1:setStrokeColor(Theme.EmbossColorLow[1],Theme.EmbossColorLow[2],Theme.EmbossColorLow[3],1); Tmp2:setStrokeColor(Theme.EmbossColorHigh[1],Theme.EmbossColorHigh[2],Theme.EmbossColorHigh[3],1) end
		end


	end
	
	-- ADD BACKGROUND IMAGE?
	if Props.bgImage ~= nil then
		if Props.bgImage[1] ~= nil then Tmp1 = display.newImage(Props.bgImage[1]) end
		if Tmp1 ~= nil then
			Tmp1.anchorX   = 0
			Tmp1.anchorY   = 0
			Tmp1.x         = 2
			Tmp1.y         = 2
			Tmp1.xScale    = (w-4) / Tmp1.width
			Tmp1.yScale    = (h-4) / Tmp1.height
			Tmp1.alpha     = Props.bgImage[2] or 1
			Tmp1.blendMode = Props.bgImage[3] or "normal"
			Widget[1]:insert(Tmp1)
		end
	end
end


----------------------------------------------------------------
-- PRIVATE: APPLY STANDARD WIDGET METHODS
----------------------------------------------------------------
V._ApplyWidgetMethods = function (Widget)
	function Widget:show     (state,anim) V.Show(self.Props.name, state, anim) end
	function Widget:enable   (state) V.Enable(self.Props.name, state) end
	function Widget:set      (A, B, C) V.Set(self.Props.name, A, B, C) end
	function Widget:get      (name) return V.Get(self.Props.name, name) end
	function Widget:layout   (doScreenAlign) V._ArrangeWidgets(self, doScreenAlign) end
	function Widget:setPos   (x,y) self.Props.x = x; self.Props.y = y; V._SetPos(self); if self.Props.myWindow ~= "" then V._ArrangeWidgets(V.Widgets[self.Props.myWindow]) end end
	function Widget:getShape () return V.GetShape(self.Props.name) end
	function Widget:getHandle() return V.GetHandle(self.Props.name) end
	function Widget:destroy  () V._RemoveWidget(self.Props.name) end
	function Widget:update   () self:_update() end
	function Widget:getDepth () return V.GetDepth(self.Props.name) end
	function Widget:toFront  () self.parent:insert(self); self.Props.zindex = V.GetDepth(self.Props.name); return self.Props.zindex end
	--function Widget:animate  (typ, Props) V.Animate(self.Props.name, typ, Props) end
	--function Widget:animStop () V.AnimStop(self.Props.name) end

	if Widget.typ ~= V.TYPE_WINDOW then
		function Widget:makeDraggable(minX,minY,maxX,maxY)
			-- DISABLE DRAG?
			if self.dragEnabled ~= nil and (minX == nil or minX == false) then
				self.dragEnabled = nil
				self:removeEventListener("touch", self)
				return
			end
			-- ENABLE DRAG?
			self.dragMinX    = minX
			self.dragMinY    = minY
			self.dragMaxX    = maxX
			self.dragMaxY    = maxY
			self.dragEnabled = true
			function self:touch (event)
				local p     = event.phase
				local T     = event.target
				if T.Props == nil then return false end
				local w     = T.Props.Shape.w
				local h     = T.Props.Shape.h
				if p == "began" then 
					T.ox = T.x - event.x
					T.oy = T.y - event.y
					self.isFocus  = true; display.getCurrentStage():setFocus( event.target ) 
				end
				if self.isFocus == true then
					if p == "ended" or p == "cancelled" then
						self.isFocus = false; display.getCurrentStage():setFocus( nil )
					else
						local x = event.x + T.ox
						local y = event.y + T.oy
						if x < T.dragMinX then x = T.dragMinX elseif x+w > T.dragMaxX then x = T.dragMaxX-w end
						if y < T.dragMinY then y = T.dragMinY elseif y+h > T.dragMaxY then y = T.dragMaxY-h end
						T:setPos(x, y)
					end
				end
				return true
			end
			self:addEventListener("touch", self)
		end
	end

	if Widget.typ == V.TYPE_WINDOW then
		function Widget:close() 
			if self.Props.onClose ~= nil then self.Props.onClose(		
			{ 
			Widget = self,
			Props  = self.Props,
			name   = self.Props.name,
			}) 
			end 
		end
	end
	
end


----------------------------------------------------------------
-- PRIVATE: WIDGET LISTENERS
----------------------------------------------------------------
V._OnWidgetTouch = function (event)

	if _G.NoEditShow == true then return end
	local i,v
	local Obj   = event.target
	local Props = Obj.Props
	local Theme = V.Themes [Props.theme]
	local name  = Props.name
	local ex,ey = Obj:contentToLocal(event.x, event.y)
	local EventData = 
		{ 
		Widget      = Obj,
		Props       = Props,
		name        = name,
		x           = event.x,
		y           = event.y,
		lx          = ex,
		ly          = ey,
		inside      = true,
		}

	-- INPUT TEXT OKAY BUTTON CLICKED?
	if V.Input ~= nil then 
		if event.phase == "began" then V._RemoveInput() end 
		return true 
	end

	-- WIDGET OR WINDOW DISABLED?
	if Props.enabled == false or (Props.myWindow ~= "" and V.Widgets[Props.myWindow].Props.enabled == false) then
		Obj.isFocus = false; V.Stage:setFocus( nil )
		return true
	end

	-- PRESS
	if event.phase == "began" then

		-- WIDGET PLACED WITHIN WINDOW?
		if Props.myWindow ~= "" then

			if V.Widgets[Props.myWindow].Props.tapToFront == true then V.Widgets[Props.myWindow]:toFront() end
			if V.Widgets[Props.myWindow].Props.onWidgetPress ~= nil then V.Widgets[Props.myWindow].Props.onWidgetPress(EventData) end
		end
		Obj.inside  = true
		Obj.isFocus = true; V.Stage:setFocus( Obj )
		Obj:_drawPressed( EventData )
		EventData.value       = Props.value
		EventData.toggleState = Props.toggleState
		if Props.onPress ~= nil then Props.onPress( EventData ) end 
		if Props.tapSound~= nil and Props.tapSound > 0 and V.muted ~= true then audio.play(Theme.Sounds[Props.tapSound], {channel = V.channel}) end

		-- WIDGET HAS NOT BEEN REMOVED IN .onRelease() BUT WAS DISABLED THERE?
		if V.Widgets[name] == nil or (V.Widgets[name] and (Props.enabled == false or (Props.myWindow ~= "" and V.Widgets[Props.myWindow] and V.Widgets[Props.myWindow].Props.enabled == false))) then Obj.isFocus = false; V.Stage:setFocus( nil ); return true end

		-- REMOVE INPUT TEXT?
		V._RemoveInput() 
		
		-- HIGHLIGHT EFFECT?
		if V.Highlight then V._ShowTouch(event.x, event.y) end

	elseif Obj.isFocus then

		-- INSIDE WIDGET?
		if ex > 0 and ex < Props.Shape.w and ey > 0 and ey < Props.Shape.h then EventData.inside = true else EventData.inside = false end

		-- DRAG
		if event.phase == "moved" then
			Obj.inside            = EventData.inside
			if Obj._drawDragged  then Obj:_drawDragged( EventData ) end
			EventData.value       = Props.value
			EventData.toggleState = Props.toggleState
			if Props.onDrag      then Props.onDrag    ( EventData ) end 

		-- RELEASE
		elseif event.phase == "ended" or event.phase == "cancelled" then
			-- SHOW INPUT TEXT?
			if EventData.inside and Obj.typ == V.TYPE_INPUT then
				if Props.disableInput ~= true then
					if V.Input == nil then V._CreateInput(Obj) end
						native.setKeyboardFocus(V.Input.Txt)
				end
			end

			Obj.inside            = EventData.inside
			Obj.isFocus           = false; V.Stage:setFocus( nil )
			Obj:_drawReleased( EventData )
			EventData.value       = Props.value
			EventData.toggleState = Props.toggleState
			if Props.onRelease   ~= nil then Props.onRelease( EventData ) end
			if Props.releaseSound~= nil and V.muted ~= true then audio.play(Theme.Sounds[Props.releaseSound], {channel = V.channel}) end
			-- WIDGET HAS NOT BEEN REMOVED IN .onRelease() BUT WAS DISABLED THERE?
			if V.Widgets[name] == nil or (V.Widgets[name] and (Props.enabled == false or (Props.myWindow ~= "" and V.Widgets[Props.myWindow] and V.Widgets[Props.myWindow].Props.enabled == false))) then Obj.isFocus = false; V.Stage:setFocus( nil ); return true end
		end
	end
	
	return true
end


----------------------------------------------------------------
-- PRIVATE: WINDOW TOUCH
----------------------------------------------------------------
V._OnWindowTouch = function (event)
	local Win   = event.target.parent
	local Props = Win.Props
	local p     = event.phase
	local ex,ey = Win.parent:contentToLocal(event.x, event.y)

	if p == "began" and Props.enabled == true then
		if Props.tapToFront == true then Win:toFront() end
		V._RemoveInput() 
		Win.isFocus  = true; display.getCurrentStage():setFocus( event.target )
		Win.sx, Win.sy = 0,0
		Win.lx, Win.ly = Win.x, Win.y
		Win.ox, Win.oy = Win.x - ex, Win.y - ey
		if Props.onPress then Props.onPress(Win, Props) end
		if Win.DragTimer ~= nil then timer.cancel(Win.DragTimer); Win.DragTimer.Win = nil; Win.DragTimer = nil end
		if Props.slideOut then
			Win.DragTimer = timer.performWithDelay(1, 
				function (event)
					local Win   = event.source.Win
					local Props = Win.Props
					-- GET VELOCITY
					if Win.isFocus then
						Win.sx, Win.sy = Win.x - Win.lx, Win.y - Win.ly
						Win.lx, Win.ly = Win.x, Win.y
						Win.fx, Win.fy = Win.x, Win.y
					-- SLIDE OUT
					else
						if Props.dragX then Win.fx = Win.fx + Win.sx; Win.x = V.Ceil(Win.fx) end
						if Props.dragY then Win.fy = Win.fy + Win.sy; Win.y = V.Ceil(Win.fy) end

						Win.sx = Win.sx * (Props.slideOut or .95)
						Win.sy = Win.sy * (Props.slideOut or .95)
						if Props.dragArea ~= nil then Win:_keepInsideArea() end

						if V.Abs(Win.sx) < 0.1 and V.Abs(Win.sy) < 0.1 then
							timer.cancel(Win.DragTimer)
							Win.x             = V.Ceil(Win.x)
							Win.y             = V.Ceil(Win.y)
							Props.Shape.x = Win.x
							Props.Shape.y = Win.y
							Win.DragTimer.Win = nil
							Win.DragTimer     = nil
						end
					end
				end, 0)
			Win.DragTimer.Win = Win
		end

	elseif Win.isFocus == true then
		if p == "moved" then
			if Props.dragX then Win.x = V.Ceil(ex + Win.ox) end
			if Props.dragY then Win.y = V.Ceil(ey + Win.oy) end
			if Props.dragArea ~= nil then Win:_keepInsideArea() end
			if Props.onDrag   ~= nil then Props.onDrag(Win, Props) end

		elseif p == "ended" or p == "cancelled" then
			Win.isFocus = false; display.getCurrentStage():setFocus( nil )
			if Props.onRelease ~= nil then Props.onRelease(Win, Props) end
		end
	end
	
	Props.Shape.x = Win.x
	Props.Shape.y = Win.y
	
	return true
end


----------------------------------------------------------------
-- PRIVATE: WINDOW CLOSE
----------------------------------------------------------------
V._OnWindowClose = function (event)
	local But   = event.target
	local Win   = But.parent.parent
	local Props = Win.Props
	local Theme = V.Themes [Props.theme]

	V._RemoveInput() 
	
	if event.phase == "began" and Props.enabled == true then
		if Props.tapSound~= nil and Props.tapSound > 0 and V.muted ~= true then audio.play(Theme.Sounds[Props.tapSound], {channel = V.channel}) end
		if Props.tapToFront == true then Win:toFront() end
		But.isFocus = true; display.getCurrentStage():setFocus( But )
		But:setFrame(Theme.Frame_Win_CloseButtonDown)

		-- HIGHLIGHT EFFECT?
		if V.Highlight then V._ShowTouch(event.x, event.y) end
	
	elseif But.isFocus then
		-- OVER / OUTSIDE BUTTON?
		local size = Theme.widgetFrameSize
		local x,y  = But:contentToLocal(event.x, event.y)
		x = x + size*.5
		y = y + size*.5
		But:setFrame( (x > 0 and x < size and y > 0 and y < size) and Theme.Frame_Win_CloseButtonDown or Theme.Frame_Win_CloseButton )

		if event.phase == "ended" or event.phase == "cancelled" then
			But.isFocus = false; display.getCurrentStage():setFocus( nil )
			if But:getFrame() == Theme.Frame_Win_CloseButtonDown then 
				if Props.releaseSound~= nil and Props.releaseSound > 0 and V.muted ~= true then audio.play(Theme.Sounds[Props.releaseSound], {channel = V.channel}) end
				Win:close() 
				But:setFrame(Theme.Frame_Win_CloseButton)
			end
		end
	end
	
	return true
end


----------------------------------------------------------------
-- PRIVATE: WINDOW RESIZE
----------------------------------------------------------------
V._OnWindowResize = function (event)
	V._RemoveInput() 
end



----------------------------------------------------------------
-- PUBLIC: SHOW / REMOVE KEYBOARD
----------------------------------------------------------------
V.Keyboard_Open = function () return V.Keyboard ~= nil and true or false end

V.Keyboard_Show = function (Props)
	V.Keyboard_Remove()
	-- SET KEYBOARD DEFAULTS
	local k,v; for k,v in pairs(V.KeyboardDefaults) do 
		if Props[k] == nil then Props[k] = V.KeyboardDefaults[k] elseif Props[k] == "" then Props[k] = V.KeyboardDefaults[k] end 
	end

	local Tmp, Grp
	Props.Theme       = V.Themes[next(V.Themes)]; if Props.Theme == nil then V.error("!!! WIDGET ERROR: Keyboard_Show(): At least one theme must be loaded to use the keyboard."); return end
	Props.h           = (string.find(Props.height,"%",1,true) and (V.physicalH/100) *  tonumber(Props.height:sub(1,Props.height:len()-1)) or Props.height)
	Props.fontSize    = Props.fontSize or Props.Theme.KeyboardFontSize

	-- CREATE KEYBOARD
	V.Keyboard            = display.newGroup()
	V.Keyboard.Props      = Props
	V.Keyboard.CaseTexts  = {}
	V.Keyboard.ShiftIcons = {}
	-- [1] BG GROUP
	Grp = display.newGroup()
	V.Keyboard.isVisible = false
	V.Keyboard:insert(Grp)
	-- [1][1] CLICK-THROUGH PREVENTER
	Tmp = V.newSprite (Props.Theme.Set, Props.Theme.Frame_Transparent)
	Tmp.xScale  = V.physicalW / Tmp.width
	Tmp.yScale  = V.physicalH / Tmp.height
	Tmp.anchorX = 0
	Tmp.anchorY = 0
	Grp:insert(Tmp)
	if Props.align == "bottom" then Tmp.y = -V.physicalH + Props.h end
	Tmp.onTouch = function(event) 
				if event.phase == "began" then
					local Props  = V.Keyboard.Props
					local y      = event.y
					-- TOUCHED OUTSIDE KEYBOARD? QUIT!
					if (Props.align == "bottom" and y < V.physicalH-Props.h) or (Props.align == "top" and y > Props.h) then V.Keyboard_Remove(true) end 
				end
				return true
			end
	Tmp:addEventListener("touch", Tmp.onTouch )
	-- [1][2] TOP SHADOW
	Tmp = V.newSprite (Props.Theme.Set, Props.Theme.Frame_TopShadow)
	Tmp.xScale  = V.physicalW*1.2 / Tmp.width
	Tmp.anchorX = 0
	Tmp.anchorY = 1
	Tmp.x       = 0
	Tmp.y       = 1
	Grp:insert(Tmp)
	-- [1][3] BACKGROUND
	Tmp = display.newRect(0,0,V.physicalW,Props.h)
	Tmp:setStrokeColor   (0,0,0, 0)
	Tmp:setFillColor     (Props.bgColor[1],Props.bgColor[2],Props.bgColor[3], Props.bgColor[4] or 1)
	Tmp.anchorX = 0
	Tmp.anchorY = 0
	Grp:insert(Tmp)
	-- [1][4] TOP LINE
	Tmp = display.newLine(0,0,V.physicalW,0)
	Tmp:setStrokeColor   (1,1,1, .25)
	Tmp.strokeWidth = 1
	Grp:insert(Tmp)
	-- [2] KEY PAGE
	if Props.layout.page1 then V.Keyboard:insert( V._CreateKeyPage(Props.layout.page1) ) end
	-- [3] KEY PAGE
	if Props.layout.page2 then V.Keyboard:insert( V._CreateKeyPage(Props.layout.page2) ) end
	-- [4] KEY PAGE
	if Props.layout.page3 then V.Keyboard:insert( V._CreateKeyPage(Props.layout.page3) ) end

	V.Keyboard_ShowPage  (1)
	V.Keyboard_ChangeCase(Props.case)

	-- TARGET?
	if Props.target then
		if type(Props.target) == "string" then Props.target = V.GetHandle(Props.target) end
		V.Keyboard.Widget = Props.target; if V.Keyboard.Widget == nil then V.error("!!! WIDGET ERROR: Keyboard_Show(): Specified target widget does not exist."); V.Keyboard.Widget = nil end
		if V.Keyboard.Widget.typ ~= V.TYPE_INPUT then print("!!! WIDGET ERROR: Keyboard_Show(): Specified target must be a Widget Candy input text."); V.Keyboard.Widget = nil end
		if V.Keyboard.Widget ~= nil then V.Keyboard.oText  = Props.target:getText() end
		-- CALL onFocus?
		if V.Keyboard.Widget.Props.onFocus then V.Keyboard.Widget.Props.onFocus(
			{
			Widget = V.Keyboard.Widget,
			Props  = V.Keyboard.Widget.Props,
			name   = V.Keyboard.Widget.Props.name,
			value  = V.Keyboard.Widget:getText(),
			}) end
	end

	-- MOVE IN
	V.Keyboard.isVisible = true
	if Props.align == "top" then
		V.Keyboard.x = V.left
		V.Keyboard.y = V.top
		transition.from (V.Keyboard, {time = 350, y = -Props.h, transition = easing.outCubic })
	else 
		V.Keyboard.x = V.left
		V.Keyboard.y = V.bottom - Props.h
		transition.from (V.Keyboard, {time = 350, y = V.physicalH, transition = easing.outCubic }) 
	end

	-- TIMER
	V.Keyboard.Timer  = timer.performWithDelay(1000/display.fps, V._onKeyboardTimer, 0)
end

-- REMOVE KEYBOARD
V.Keyboard_Remove = function (animate)
	local Tmp
	if V.Keyboard == nil then return end
	if V.Keyboard.movingOut == true then return end
	V.Keyboard.movingOut = true
	-- REMOVE TIMER
	timer.cancel(V.Keyboard.Timer); V.Keyboard.Timer = nil
	-- REMOVE EVENT LISTENERS FROM CLICK THROUGH PREVENTER
	Tmp = V.Keyboard[1][1]
	Tmp:removeEventListener("touch", Tmp.onTouch )
	Tmp:removeSelf()
	-- REMOVE NOW?
	if animate ~= true then V._Keyboard_Remove(); return end
	-- SLIDE OUT, THEN REMOVE
	local Props = V.Keyboard.Props
	if Props.align == "top" then
		 transition.to(V.Keyboard, {time = 350, y = -Props.h   , onComplete = function() V._Keyboard_Remove() end, transition = easing.outCubic })
	    else transition.to(V.Keyboard, {time = 350, y = V.physicalH, onComplete = function() V._Keyboard_Remove() end, transition = easing.outCubic }) end
end

V._Keyboard_Remove = function()
	local k,v,Tmp,i,j,Page
	local Props = V.Keyboard.Props
	transition.cancel(V.Keyboard)
	-- REMOVE KEY PAGES
	for j = V.Keyboard.numChildren,2,-1 do
		Page  = V.Keyboard[j]
		for i = Page.numChildren,1,-1 do 
			Tmp = Page[i]
			Tmp.subChars = nil
			if Tmp.myChar then Tmp:removeEventListener("touch", V._OnKeyTouch) end
			Tmp:removeSelf()
		end
		Page:removeSelf()
	end
	-- TARGET SPECIFIED?
	if V.Keyboard.Widget ~= nil then
		-- REMOVE CURSOR
		local txt = V.Keyboard.Widget:getText():gsub("%"..Props.cursor, "")
		if V.Keyboard.Widget.Props.notEmpty == true and txt == "" then
			V.Keyboard.Widget:setText(V.Keyboard.oText)
		   else V.Keyboard.Widget:setText(txt) end
		-- CALL onBlur?
		if V.Keyboard.Widget.Props.onBlur then V.Keyboard.Widget.Props.onBlur(
			{
			Widget = V.Keyboard.Widget,
			Props  = V.Keyboard.Widget.Props,
			name   = V.Keyboard.Widget.Props.name,
			value  = V.Keyboard.Widget:getText(),
			}) end
	end
	-- NIL VARS
	V.Keyboard:removeSelf()
	for i = #V.Keyboard.CaseTexts ,1 do V.Keyboard.CaseTexts [i] = nil end
	for i = #V.Keyboard.ShiftIcons,1 do V.Keyboard.ShiftIcons[i] = nil end
	for k,v in pairs(V.Keyboard.Props) do V.Keyboard.Props[k] = nil end
	for k,v in pairs(V.Keyboard) do V.Keyboard[k] = nil end
	V.Keyboard = nil
	collectgarbage("collect")
end

-- CREATE KEY PAGE
V._CreateKeyPage = function (page)
	if page == nil or #page == 0 then print("!!! WIDGET ERROR: Keyboard_Show(): Invalid layout specified."); return end
	local i,Grp,row,key,Tmp,Tmp2,char,keyW,x,y,color
	local Props  = V.Keyboard.Props
	local margin = Props.margin
	local keyH   = (Props.h-margin) / #page
	
	local Page = display.newGroup()

	y = margin
	-- KEY ROW
	for row = 1,#page do
		-- CALCULATE KEY WIDTH
		local numKeys = 0
		for key = 1,#page[row] do
			char  = page[row][key][1]
			    if char == "SPACE" then numKeys = numKeys + 4
			elseif char == "SHIFT" or char == "DEL" or char == "OK" then numKeys = numKeys + 2
			else   numKeys = numKeys + 1 end
		end
		-- CREATE KEY
		x = margin 
		for key = 1,#page[row] do
			char = page[row][key][1]
			-- KEY WIDTH
			keyW  = (V.physicalW-margin)/numKeys
			    if char == "SPACE" then keyW = keyW * 4
			elseif char == "SHIFT" or char == "DEL" or char == "OK" then keyW = keyW * 2 end
			-- KEY COLOR
			color = Props.keyColor1
			if (tonumber(char) ~= nil and tonumber(char) >= 0 and tonumber(char) <= 9) or char == "SHIFT" or char == "DEL" or char == "PAGE1" or char == "PAGE2" or char == "PAGE3" or char == "SPACE" or char == "OK" or char == "CLEAR" then color = Props.keyColor2 end
			-- GROUP
			Grp = display.newGroup()
			Page:insert(Grp)
			Grp.x = x
			Grp.y = y
			Grp:addEventListener("touch", V._OnKeyTouch)
			Grp.myChar     = char
			Grp.hasSubText = (#page[row][key] > 1 and true or false)
			Grp.allowCase  = page.allowCase
			-- [1] BG
			Tmp = display.newRoundedRect(0,0,keyW-margin,keyH-margin, Props.corners or 4)
			Tmp.strokeWidth   = Props.keyStroke[1]
			Tmp:setStrokeColor (Props.keyStroke[2],Props.keyStroke[3],Props.keyStroke[4], Props.keyStroke[5] or 1)
			Tmp:setFillColor   (color[1],color[2],color[3], color[4] or 1)
			Tmp.anchorX = 0
			Tmp.anchorY = 0
			Grp:insert(Tmp)
			-- [2] SELECTED BG
			Tmp = display.newGroup()
			Grp:insert(Tmp)
			-- [3] TEXT / ICON
			if Props.icons[char] ~= nil then 
				Tmp = V.newSprite(Props.Theme.SetIcons, Props.icons[char]) 
				local scale = (keyH-margin) / Tmp.height; if scale > 1 then scale = 1 end
				Tmp:setFillColor(Props.charColor1[1],Props.charColor1[2],Props.charColor1[3],Props.charColor1[4] or 1)
				Tmp.xScale  = scale
				Tmp.yScale  = scale
				Tmp.anchorX = .5
				Tmp.anchorY = .5
				Tmp.x       = keyW*.5
				Tmp.y       = keyH*.5 - margin*.5
			else
				Tmp         = display.newText(char,0,0,Props.Theme.KeyboardFont,Props.fontSize*2)
				Tmp:setFillColor(Props.charColor1[1],Props.charColor1[2],Props.charColor1[3],Props.charColor1[4] or 1)
				Tmp.anchorX = .5
				Tmp.anchorY = .5
				Tmp.xScale  = .5
				Tmp.yScale  = .5
				Tmp.x       = keyW*.5
				Tmp.y       = keyH*.5
				Tmp.myChar = char
				if page.allowCase == true then V.Keyboard.CaseTexts[#V.Keyboard.CaseTexts+1] = Tmp end
			end
			Grp:insert (Tmp)
			-- [4] SUBCHAR TEXT
			if Grp.hasSubText then
				-- MORE THAN ONE SUBCHARS? SHOW MIDDLE CHAR OF SUBCHARS AS PREVIEW
				local txt = page[row][key][2]
				if #page[row][key] > 2 then
					local p = V.Ceil((#page[row][key]-1)/2)+1
					txt = page[row][key][ p ]
				end
				Tmp         = display.newText(txt,0,0,Props.Theme.KeyboardFont,Props.fontSize*2)
				Tmp:setFillColor(Props.charColor2[1],Props.charColor2[2],Props.charColor2[3],Props.charColor2[4] or 1)
				Tmp.anchorX = 1
				Tmp.anchorY = 0
				Tmp.xScale  = .375
				Tmp.yScale  = .375
				Tmp.x       = keyW-margin
				Tmp.y       = margin
				Tmp.myChar = txt
				if page.allowCase == true then V.Keyboard.CaseTexts[#V.Keyboard.CaseTexts+1] = Tmp end
				Grp:insert(Tmp)
			end
			-- GLOSSY
			if Props.glossy == true then
				local c = V.Ceil(Props.corners*.5)
				Tmp = display.newRoundedRect(c+1,c+1,keyW-margin-c*2-1,keyH*.3, c)
				Tmp.strokeWidth   = 0
				Tmp:setStrokeColor (0,0,0, 0)
				Tmp:setFillColor   (1,1,1, .25)
				Tmp.anchorX = 0
				Tmp.anchorY = 0
				Grp:insert(Tmp)
			end
			-- SHIFT INDICATOR
			if char == "SHIFT" then
				Tmp = V.newSprite(Props.Theme.Set, Props.Theme.Frame_PressHighlight) 
				Tmp.xScale    = (keyH-margin) / Tmp.height
				Tmp.yScale    = Tmp.xScale
				Tmp.anchorX   = .5
				Tmp.anchorY   = .5
				Tmp.blendMode = "screen"
				Tmp.x         = keyW*.5
				Tmp.y         = keyH*.5
				Tmp:setFillColor(.8,.8,1)
				V.Keyboard.ShiftIcons[#V.Keyboard.ShiftIcons+1] = Tmp
				Grp:insert(Tmp)
			end
			-- SUBTEXT MENU
			if Grp.hasSubText then
				local num  = #page[row][key]-1
				local size = Props.subTextSize
				local sp   = 4 -- SPACING
				-- GROUP
				local Grp2 = display.newGroup()
				Grp.subChars = {}
				Grp:insert(Grp2)
				-- [1] BG
				Tmp  = display.newGroup()
				Grp2:insert(Tmp)
				-- [1][1] SHADOW
				Tmp2 = display.newRoundedRect(-sp+4,-sp-4, num*size+sp*2,size+sp*2, Props.corners or 4)
				Tmp2.anchorX       = 0
				Tmp2.anchorY       = 0
				Tmp2.strokeWidth   = 0
				Tmp2:setStrokeColor (0,0,0, 0)
				Tmp2:setFillColor   (0,0,0, .4)
				Tmp:insert(Tmp2)
				-- [1][2] BG
				Tmp2 = display.newRoundedRect(-sp,-sp, num*size+sp*2,size+sp*2, Props.corners or 4)
				Tmp2.anchorX       = 0
				Tmp2.anchorY       = 0
				Tmp2.strokeWidth   = Props.keyStroke[1]
				Tmp2:setStrokeColor (Props.keyStroke[2],Props.keyStroke[3],Props.keyStroke[4],Props.keyStroke[5] or 1)
				Tmp2:setFillColor   (color[1],color[2],color[3], 1)
				Tmp:insert(Tmp2)
				-- [2] MARKER
				Tmp = display.newRoundedRect(0,0,size,size, Props.corners or 4)
				Tmp.anchorX       = 0
				Tmp.anchorY       = 0
				Tmp.strokeWidth   = 0
				Tmp:setStrokeColor (0,0,0, 0)
				Tmp:setFillColor   (1,1,1, .25)
				Grp2:insert(Tmp)
				-- [3...] CHARS
				for i = 1, num do
					local txt = page[row][key][i+1]
					table.insert(Grp.subChars, txt)

					Tmp         = display.newText(txt,0,0,Props.Theme.KeyboardFont,Props.subTextSize*2)
					Tmp:setFillColor(Props.charColor1[1],Props.charColor1[2],Props.charColor1[3],Props.charColor1[4] or 1)
					Tmp.anchorX = .5
					Tmp.anchorY = .5
					Tmp.xScale  = .5
					Tmp.yScale  = .5
					Tmp.x       = size*.5 + (i-1)*size
					Tmp.y       = size*.5
					Tmp.myChar  = txt
					if page.allowCase == true then V.Keyboard.CaseTexts[#V.Keyboard.CaseTexts+1] = Tmp end
					Grp2:insert(Tmp)
				end
				function Grp:showSubText(Obj)
					if self == nil then self = Obj end
					self.parent:insert(self) -- TO FRONT
					local SubMenu = self[self.numChildren]
					local w = self.width
					local h = self.height
					SubMenu.isVisible = true
					--SubMenu.alpha = 0
					--transition.to  (SubMenu, {time = 250, alpha = 1})
					SubMenu.xScale = 1
					SubMenu.yScale = 1
					-- POSITION SUBMENU
					local x = w*.5 - SubMenu.width*.5
					local y = -SubMenu.height + 4
					local maxX,maxY = self:contentToLocal(V.right,V.bottom)
					local minX,minY = self:contentToLocal(V.left ,V.top)
						if x + SubMenu.width >= maxX then x = maxX - SubMenu.width
					elseif x < minX then x = V.Keyboard.Props.margin end
					if y <= minY then y = self[1].height + 4 end
					SubMenu.x = x
					SubMenu.y = y
					SubMenu[2].isVisible = false
				end
				function Grp:hideSubText()
					local SubMenu = self[self.numChildren]
					SubMenu.x         = 0
					SubMenu.y         = 0
					SubMenu.xScale    = .0001
					SubMenu.yScale    = .0001
					SubMenu.isVisible = false
				end
				-- HIDE
				Grp:hideSubText()
			end
			x = x + keyW
		end
		y = y + keyH
	end
	return Page
end

V.Keyboard_ShowPage = function(page)
	if V.Keyboard == nil then return end
	-- REMEMBER CURRENT PAGE
	    if page == 1 then V.Keyboard.currPage = 1 
	elseif page == 2 then V.Keyboard.currPage = 2 
	else V.Keyboard.currPage = 3 end
	-- SHOW PAGE, HIDE OTHERS
	local i; for i = 2, V.Keyboard.numChildren do
		V.Keyboard[i].isVisible = ((i-1) == page and true or false)
		V.Keyboard[i].xScale    = ((i-1) == page and 1 or .0001   )
		V.Keyboard[i].yScale    = ((i-1) == page and 1 or .0001   )
	end
end

V.Keyboard_ChangeCase = function(case)
	if V.Keyboard == nil then return end
	local i,txt,Obj
	local Props = V.Keyboard.Props
	if case < 0 or case > 2 then case = 0 end
	Props.case = case
	-- SHIFT INDICATOR
	for i = 1, #V.Keyboard.ShiftIcons do
		V.Keyboard.ShiftIcons[i].isVisible = (case  > 0 and true or false)
		V.Keyboard.ShiftIcons[i].alpha     = (case == 2 and 1 or .5)
	end
	-- LOOP THROUGH TEXT OBJECTS
	for i = 1, #V.Keyboard.CaseTexts do
		Obj = V.Keyboard.CaseTexts[i]
		txt = Obj.myChar -- UPPERCASE
		-- LOWERCASE?
		if case == 0 then txt = V.utf8lower(txt) end
		Obj.text = txt
	end
end

-- CALLED FREQUENTLY WHILE KEYBOARD OPEN
V._onKeyboardTimer = function(event)
	if V.Keyboard == nil then return end
	local Props = V.Keyboard.Props
	local now   = V.Time()
	-- SHOW SUBTEXT MENU?
	if V.Keyboard.touchStart and V.Keyboard.CurrKey and now-V.Keyboard.touchStart >= Props.subTextDelay then
		if Props.subTextSound~= nil and Props.subTextSound > 0 and V.muted ~= true then audio.play(Props.Theme.Sounds[Props.subTextSound], {channel = V.channel}) end
		V.Keyboard.CurrKey:showSubText()
		V.Keyboard.CurrKey = nil
	end
	-- STAY ON TOP
	local P = V.Keyboard.parent
	local n = P.numChildren
	local i = V.Highlight ~= nil and 1 or 0
	if V.Keyboard ~= P[n-i] then P:insert(n, V.Keyboard) end
	-- CURSOR
	if V.Keyboard.Widget and Props.cursor ~= "" then
		local state = V.Abs(V.Ceil(V.Sin(now*.01)))
		if state ~= V.Keyboard.lastState then
			local Widget = V.Keyboard.Widget
			local txt    = Widget:getText():gsub("%"..Props.cursor, "")
			Widget:setText(state == 1 and txt..Props.cursor or txt)
			V.Keyboard.lastState = state
		end
	end
	-- DEL KEY PRESSED? (REPEAT)
	if V.Keyboard.delPressed then
		if now-V.Keyboard.lastDel >= 100 then
			-- SOUND
			if V.Keyboard.lastDel ~= 0 and Props.tapSound ~= nil and Props.tapSound > 0 and V.muted ~= true then audio.play(Props.Theme.Sounds[Props.tapSound], {channel = V.channel}) end
			-- TARGET SPECIFIED?
			if V.Keyboard.Widget ~= nil then
				local txt    = V.Keyboard.Widget:getText():gsub("%"..Props.cursor, "")
				local newTxt = ""
				local char
				local cnt = V.utf8len(txt)
				for char in string.gfind(txt, "([%z\1-\127\194-\244][\128-\191]*)") do
					cnt = cnt - 1; if cnt == 0 then break end
					newTxt = newTxt..char
				end
				V.Keyboard.Widget:setText(newTxt)
				if V.Keyboard.Widget.Props.onChange then V.Keyboard.Widget.Props.onChange(
					{
					Widget = V.Keyboard.Widget,
					Props  = V.Keyboard.Widget.Props,
					name   = V.Keyboard.Widget.Props.name,
					value  = V.Keyboard.Widget:getText(),
					}) 
				end 
			end
			if Props.onType then Props.onType( {char = "DEL"} ) end
			V.Keyboard.lastDel = V.Keyboard.lastDel == 0 and now + 500 or now
		end
	end
end

-- ON KEY TOUCH
V._OnKeyTouch = function(event)
	local Obj   = event.target
	local phase = event.phase
	local Props = V.Keyboard.Props
	local ex,ey = Obj:contentToLocal(event.x, event.y)
	local hit   = false; if ex > 0 and ex < Obj[1].width and ey > 0 and ey < Obj[1].height then hit = true end

	local SubText, Marker, lx,ly, pos
	if Obj.hasSubText then
		SubText = Obj[Obj.numChildren]
		Marker  = SubText[2]
		lx, ly  = SubText:contentToLocal(event.x, event.y)
		pos     = V.Floor(lx/Props.subTextSize)+1
		if pos < 1 then pos = 1 elseif pos > #Obj.subChars then pos = #Obj.subChars end
	end

	local insideSubMenu = (Obj.hasSubText and SubText.isVisible == true and ex > SubText.x and ex < SubText.x+SubText.width and ey > SubText.y and ey < SubText.y+SubText.height) and true or false

	if phase == "began" then
		local char, Tmp
		Obj.isFocus = true; display.getCurrentStage():setFocus( Obj ) 
		if Obj.hasSubText then
			V.Keyboard.touchStart = V.Time()
			V.Keyboard.CurrKey    = Obj
		end
		-- TAP SOUND
		if Props.tapSound~= nil and Props.tapSound > 0 and V.muted ~= true then audio.play(Props.Theme.Sounds[Props.tapSound], {channel = V.channel}) end
		-- HIGHLIGH KEY
		Tmp = display.newRoundedRect(0,0,Obj.width,Obj.height, Props.corners or 4)
		Tmp.anchorX       = 0
		Tmp.anchorY       = 0
		Tmp.strokeWidth   = 0
		Tmp:setStrokeColor (0,0,0, 0)
		Tmp:setFillColor   (Props.pressColor[1],Props.pressColor[2],Props.pressColor[3],Props.pressColor[4] or 1)
		Obj:insert(3, Tmp)
		-- TOUCH HIGHLIGHT EFFECT?
		if V.Highlight then V._ShowTouch(event.x, event.y) end
		-- DEL?
		V.Keyboard.delPressed = Obj.myChar == "DEL" and true or false
		V.Keyboard.lastDel    = 0

	elseif Obj.isFocus then
		-- INSIDE SUBTEXT MENU?
		if insideSubMenu then 
			Marker.isVisible = true
			Marker.x         = (pos-1) * Props.subTextSize
		elseif Marker then Marker.isVisible = false end
		-- RELEASE?
		if phase == "ended" or phase == "cancelled" then
			local char
			Obj.isFocus           = false; display.getCurrentStage():setFocus( nil )
			V.Keyboard.touchStart = nil
			V.Keyboard.delPressed = false
			-- DE-HIGHLIGHT KEY
			Obj[3]:removeSelf()
			-- INSIDE SUBTEXT MENU?
			if insideSubMenu then 
				Marker.x = (pos-1) * Props.subTextSize
				char = Obj.subChars[pos] 
			-- INSIDE KEY
			elseif ex > 0 and ex < Obj[1].width then
				char = Obj.myChar 
			end
			if char then
				-- LOWERCASE?
				if Props.case == 0 and Obj.allowCase == true and char ~= "PAGE1" and char ~= "PAGE2" and char ~= "PAGE3" and char~= "SHIFT" and char ~= "DEL" and char ~= "OK" and char ~= "CLEAR" and char ~= "SPACE" then 
					char = V.utf8lower(char)
				end
				local EventData = { Widget = V.Keyboard.Widget, char = (char == "SPACE" and " " or char), }
				-- RELEASE SOUND
				if char ~= "DEL" and Props.releaseSound~= nil and Props.releaseSound > 0 and V.muted ~= true then audio.play(Props.Theme.Sounds[Props.releaseSound], {channel = V.channel}) end
				-- SWITCH TO PAGE1?
				    if char == "PAGE1" then V.Keyboard_ShowPage(1)
				-- SWITCH TO PAGE2?
				elseif char == "PAGE2" then V.Keyboard_ShowPage(2) 
				-- SWITCH TO PAGE3?
				elseif char == "PAGE3" then V.Keyboard_ShowPage(3) 
				-- SHIFT?
				elseif char == "SHIFT" then 
					local case = V.Keyboard.Props.case
					if case == 0 then case = 1 elseif case == 1 then case = 2 else case = 0 end
					V.Keyboard_ChangeCase(case)
				-- OK?
				elseif char == "OK" then
					if Props.onOK then Props.onOK(EventData) end
					if V.Keyboard.Widget ~= nil and V.Keyboard.Widget.Props.onOK then V.Keyboard.Widget.Props.onOK(EventData) end
					V.Keyboard_Remove (true)
				-- IS CHAR / DEL / CLEAR
				elseif char ~= "DEL" then
					-- CLEAR TEXT?
					if char == "CLEAR" then
						-- TARGET SPECIFIED?
						if V.Keyboard.Widget ~= nil then
							V.Keyboard.Widget:setText("")
						end
					elseif char ~= "DEL" then
						-- SHIFT IS ACTIVE?
						if Props.case == 1 then V.Keyboard_ChangeCase(0) end
						-- TARGET SPECIFIED?
						if V.Keyboard.Widget ~= nil then
							local txt = V.Keyboard.Widget:getText():gsub("%"..Props.cursor, "")
							local g = txt..EventData.char
							V.Keyboard.Widget:setText(txt..EventData.char)
						end
					end
					-- SEND CHAR
					if Props.onType then Props.onType(EventData) end
					-- TARGET HAS onChange LISTENER?
					if V.Keyboard.Widget ~= nil and V.Keyboard.Widget.Props.onChange then V.Keyboard.Widget.Props.onChange(
						{
						Widget = V.Keyboard.Widget,
						Props  = V.Keyboard.Widget.Props,
						name   = V.Keyboard.Widget.Props.name,
						value  = V.Keyboard.Widget:getText(),
						}) 
					end 
				end
			end
			if Obj.hasSubText then Obj:hideSubText() end
		end
	end

	return true
end

----------------------------------------------------------------
-- PRIVATE: INPUT TEXT FUNCTIONS
----------------------------------------------------------------
V._CreateInput = function(Widget)
	V._RemoveInput()
	local Tmp
	local Props     = Widget.Props
	local Theme     = V.Themes[Props.theme]
	local Window    = V.Widgets[Props.myWindow]
	local scale     = Window ~= nil and Window.Props.scale or Props.scale
	local size      = Props.fontSize + 8

	local isAndroid = "Android" == system.getInfo( "platformName" )
	local fontAdjust = 0
	if ( isAndroid ) then
		fontAdjust = -3
	    size = size + 15
	end	

	local w         = (V.screenW - 40)-- * (1/scale)
	local y         = (size + 10) * scale
	local margin    = 10

	V.Input           = {}
	V.Input.MyObject  = Widget
	V.Input.oText     = Widget.Props.caption

	-- MODAL BG
	if V.Fader == nil then
		V.Fader       = display.newGroup()
		V.Fader.x     = display.screenOriginX
		V.Fader.y     = display.screenOriginY
		V.Fader.alpha = 0
		Tmp             = display.newRect(V.Fader,0,0,V.physicalW,V.physicalH)
		Tmp.anchorX     = 0
		Tmp.anchorY     = 0
		Tmp:setFillColor (0,0,0,.5)
		Tmp.strokeWidth = 0
		V.Fader:addEventListener("touch", function() V._RemoveInput(); return true end)
	end
	transition.to (V.Fader, {time = 750, alpha = 1.0})
	V.numModals = V.numModals + 1

	-- BORDER
	Tmp              = display.newRoundedRect(0,0,w,(size+margin*2)*scale, 8)
	Tmp.anchorX      = .5
	Tmp.anchorY      = .5
	Tmp.x            = V.screenW * .5
	Tmp.y            = y
	Tmp.strokeWidth  = 1
	Tmp:setFillColor  (0,0,0,.6)
	Tmp:setStrokeColor(1,1,1,1)
	V.Input.Border   = Tmp
	

	-- INPUT TEXT
	Tmp = native.newTextField(0,0,w-margin*2,(size+4+2)*scale)
	Tmp:addEventListener("userInput", V._OnInput)
	Tmp.x            = V.screenW * .5
	Tmp.y            = y
	Tmp.text         = Props.caption

	Tmp.size         = Props.fontSize + fontAdjust + 8
	Tmp.isSecure     = Props.isSecure  ~= nil and Props.isSecure  or false
	Tmp.inputType    = Props.inputType ~= nil and Props.inputType or "default"
	Tmp.isEditable   = true
	--Tmp:setFillColor(0,0,0,1)  
	V.Input.Txt      = Tmp
	native.setKeyboardFocus(V.Input.Txt)
	V.Input.Txt:setSelection( 9999, 9999 )
	if Widget.Props.onFocus then Widget.Props.onFocus(
		{
		Widget = Widget,
		Props  = Widget.Props,
		name   = Widget.Props.name,
		value  = Widget.Props.caption,
		}) end
	
	-- QUIT CAPTION
	Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
	Tmp.xScale = .5 * scale
	Tmp.yScale = .5 * scale
	Tmp.x      = V.screenW * .5
	Tmp.y      = y + size + margin*2
	Tmp.text   = Props.quitCaption
	V.Input.QuitTxt = Tmp

end

V._OnInput = function(event)
	if V.Input == nil then return end
	local O     = V.Input.MyObject
	local Props = O.Props
	local Theme = V.Themes[Props.theme]

	-- CHECK FOR ALLOWED CHARS
	if Props.allowedChars ~= nil then
		for i = 1, V.Input.Txt.text:len() do
			local found = false 
			for j = 1, Props.allowedChars:len() do
				if V.Input.Txt.text:sub(i,i) == Props.allowedChars:sub(j,j) then found = true; break end
			end
			if found == false then V.Input.Txt.text = V.Input.Txt.text:sub(1,V.Input.Txt.text:len()-1) end
		end
	end

	O:set("caption", V.Input.Txt.text)
	if event.phase == "editing" then 
		if Props.changeSound~= nil and V.muted ~= true then audio.play(Theme.Sounds[Props.changeSound], {channel = V.channel}) end
		if Props.onChange then Props.onChange(
			{
			Widget = O,
			Props  = Props,
			name   = Props.name,
			value  = V.Input.Txt.text,
			}) end 
	--elseif event.phase == "ended" or event.phase == "submitted" then
		--V._RemoveInput()
	end
end

V._RemoveInput = function(restore)
	if V.Input ~= nil then
		local O   = V.Input.MyObject
		local txt = V.Input.Txt.text; if (txt == "" and O.Props.notEmpty == true) or restore == true then txt = V.Input.oText end
		
		V.Input.MyObject:set("caption", txt)
		if O.Props.onBlur then O.Props.onBlur(
			{
			Widget = O,
			Props  = O.Props,
			name   = O.Props.name,
			value  = txt,
			}) end
		
		V.Input.Txt:removeSelf()
		V.Input.QuitTxt:removeSelf()
		V.Input.Border:removeSelf()
		V.Input.Border   = nil
		V.Input.MyObject = nil
		V.Input.Txt      = nil
		V.Input.QuitTxt  = nil
		V.Input          = nil
		native.setKeyboardFocus(nil)

		-- REMOVE MODAL BG?
		V.numModals = V.numModals - 1
		if V.numModals == 0 then V.Fader:removeSelf(); V.Fader = nil end
	end
	return true
end


----------------------------------------------------------------
-- PRIVATE: CREATE A NEW SPRITE
----------------------------------------------------------------
V.newSprite = function(Set, frame)
	local Img = display.newSprite(Set.Sheet, Set.Sequence)
	function Img:getFrame() return self.frame end
	Img:setSequence("all")
	Img:setFrame   ( frame ~= nil and frame or 1 )
	return Img
end



----------------------------------------------------------------


----------------------------------------------------------------
-- PUBLIC: LOAD A THEME
----------------------------------------------------------------
V.LoadTheme = function ( themeName, folderPath)
	local i, Theme

	if V.Themes[themeName] ~= nil then V.error("!!! WIDGET ERROR: LoadTheme(): Theme '"..themeName.."' already loaded!"); return end
	
	Theme = require(themeName)
	
	-- LOAD SOUNDS
	Theme.Sounds = {}
	for i = 1,#Theme.SoundFiles do
		table.insert(Theme.Sounds, audio.loadSound(folderPath..Theme.SoundFiles[i]))
	end

	-- LOAD IMAGE SHEET
	local SheetOptions =
		{
		sheetContentWidth  = Theme.widgetSheetSize,
		sheetContentHeight = Theme.widgetSheetSize,
		width              = Theme.widgetFrameSize,
		height             = Theme.widgetFrameSize,
		numFrames          = V.Floor(Theme.widgetSheetSize / Theme.widgetFrameSize) * V.Floor(Theme.widgetSheetSize / Theme.widgetFrameSize),
		}

	Theme.Set = 
		{
		Sheet    = graphics.newImageSheet(folderPath..Theme.widgetGraphics, SheetOptions),
		Sequence = { name = "all", start = 1, count = SheetOptions.numFrames },
		}

	local IconOptions =
		{
		sheetContentWidth  = Theme.iconSheetSize,
		sheetContentHeight = Theme.iconSheetSize,
		width              = Theme.iconFrameSize,
		height             = Theme.iconFrameSize,
		numFrames          = V.Floor(Theme.iconSheetSize / Theme.iconFrameSize) * V.Floor(Theme.iconSheetSize / Theme.iconFrameSize),
		}

	Theme.SetIcons = 
		{
		Sheet    = graphics.newImageSheet(folderPath..Theme.iconGraphics  , IconOptions),
		Sequence = { name = "all", start = 1, count = IconOptions.numFrames},
		}

	V.Themes[themeName] = Theme
	V.Themes[themeName].folderPath = folderPath
	V.Themes[themeName].color      = {1,1,1, 1}

	V.print("--> Widgets.LoadTheme(): Loaded theme '"..themeName.."'.")
end


----------------------------------------------------------------
-- PUBLIC: SET THEME COLOR
----------------------------------------------------------------
V.SetThemeColor = function ( themeName, color, excludeInputFields)
	if V.Themes[themeName] == nil then V.error("!!! WIDGET ERROR: SetThemeColor(): Theme '"..themeName.."' does not exist!"); return end
	
	V.Themes[themeName].color = color
	
	-- LOOP THROUGH EXISTING WIDGETS, APPLY COLOR
	local name, Widget
	for name,Widget in pairs(V.Widgets) do 
		if excludeInputFields ~= true or (excludeInputFields == true and Widget.typ ~= V.TYPE_INPUT) then
			Widget.Props.color = color
			Widget:_update()
		end
	end

	collectgarbage("collect")
end

----------------------------------------------------------------
-- PUBLIC: SET DEFAULT THEME
----------------------------------------------------------------
V.SetTheme = function(name, applyNow, color) 
	local k,v,W
	if V.Themes[name] == nil then V.error("!!! WIDGET ERROR: SetTheme(): Theme '"..name.."' does not exist!"); return end

	V.defaultTheme = name 
	
	if color then V.Themes[name].color = color end

	if applyNow == true then
		-- APPLY TO EXISTING WIDGETS
		for k,v in pairs(V.Widgets) do
			V.Widgets[k].Props.theme = name
			V.Widgets[k]:_create()
		end
		-- RE-LAYOUT WINDOWS
		for k,v in pairs(V.Widgets) do if V.Widgets[k].Widgets then V.Widgets[k]:layout() end end
	end
end

----------------------------------------------------------------
-- PUBLIC: UNLOAD A THEME
----------------------------------------------------------------
V.UnloadTheme = function (themeName)
	local Theme = V.Themes[themeName]; if Theme == nil then V.error("!!! WIDGET ERROR: UnloadTheme(): No theme named '"..themeName.."' found!"); return end

	-- UNLOAD SOUNDS
	while #Theme.Sounds > 0 do
		audio.dispose(Theme.Sounds[#Theme.Sounds])
		table.remove(Theme.Sounds)
	end
	
	-- UNLOAD IMAGES
	if Theme.Sheet      ~= nil then Theme.Sheet:dispose() end
	if Theme.SheetIcons ~= nil then Theme.SheetIcons:dispose() end
	
	-- NEW IMAGE API USED?
	Theme.Set.Sheet         = nil 
	Theme.Set.Sequence      = nil 
	Theme.SetIcons.Sheet    = nil 
	Theme.SetIcons.Sequence = nil 
	
	-- AND BYE!
	Theme.Sounds                     = nil
	Theme.SwitchOnColor              = nil   
	Theme.SwitchRange                = nil         
	Theme.WindowCaptionColor1        = nil
	Theme.WindowCaptionColor2        = nil
	Theme.WidgetTextColor            = nil
	Theme.ButtonTextColor            = nil
	Theme.EmbossColorHigh            = nil
	Theme.EmbossColorLow             = nil
	Theme.BubbleTextColor            = nil
	Theme.SliderTickStrokeColor      = nil
	Theme.SliderTickFillColor        = nil
	Theme.ListItemTextColor          = nil
	Theme.ListItemSelectedColor      = nil
	Theme.InputTextColor             = nil
	Theme.CalendarTextColor          = nil
	V.Themes[themeName]              = nil

	V.print("--> Widgets.UnloadTheme(): Removed theme '"..themeName.."'.")
end


----------------------------------------------------------------
-- PRIVATE: REMOVE A WIDGET
----------------------------------------------------------------
V._RemoveWidget = function (name)

	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: RemoveWidget(): No widget named '"..name.."' found!"); return end

	if Widget.typ ~= V.TYPE_LABEL then Widget:removeEventListener("touch", V._OnWidgetTouch ) end
	if V.Input ~= nil and V.Input.MyObject == Widget then V._RemoveInput() end

	local k,v; for k,v in pairs(Widget.Props) do Widget.Props[k] = nil end
	
	if Widget.FadeTrans ~= nil then transition.cancel(Widget.FadeTrans); Widget.FadeTrans = nil end
	
	if Widget.makeDraggable then Widget:makeDraggable(false) end

	-- REMOVE .customData 
	if Widget.Props.customData then
		if type(Widget.Props.customData) == "table" then for k,v in pairs(Widget.Props.customData) do Widget.Props.customData[k] = nil end end
		Widget.Props.customData = nil
	end
	
	Widget.show          = nil
	Widget.enable        = nil
	Widget.set           = nil
	Widget.get           = nil
	Widget.getShape      = nil
	Widget.getHandle     = nil
	Widget.destroy       = nil
	Widget.Props         = nil
	Widget._drawDragged  = nil
	Widget._drawPressed  = nil
	Widget._drawReleased = nil
	Widget._create       = nil
	Widget._update       = nil
	display.remove(Widget)
	V.Widgets[name]      = nil
	Widget               = nil

	V.print("--> Widgets: Removed widget '"..name.."'.")
end


----------------------------------------------------------------
-- PUBLIC: REMOVE ALL WIDGETS
----------------------------------------------------------------
V.RemoveAllWidgets = function (unloadThemes)
	local i,v
	if unloadThemes == true then for i,v in pairs(V.Themes) do V.UnloadTheme(i) end end
	for i,v in pairs(V.Widgets) do V._RemoveWidget(i) end
	collectgarbage("collect")
end


----------------------------------------------------------------
-- PUBLIC: SET / GET WIDGET PROPERTIES
----------------------------------------------------------------
V.Set = function (name, A, B)
	local i,v
	local list   = {}
	local create = false
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: Set(): Widget '"..name.."' does not exist!"); return end

	-- SINGLE PROPERTY OR LIST OF PROPERTIES?
	if type(A) == "string" then list[A] = B else list = A end

	-- SET PROPERTIES
	for i,v in pairs(list) do Widget.Props[i] = v; if i == "theme" then create = true end end

	V._CheckProps(Widget)

	-- NEED TO RE-CREATE GRAPHICS?
	if create == true then Widget:_create() else Widget:_update() end

	-- INCLUDE CHILDREN?
	if B == true and Widget.Widgets then
		for i = 1, Widget.Widgets.numChildren do V.Set(Widget.Widgets[i].Props.name, A,B) end
		Widget:layout()
	end
	V.print("--> Widgets.Set(): Updated properties of widget '"..name.."'.")
end

V.Get = function (name, A)
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: get(): Widget '"..name.."' does not exist!"); return end
	local n,v
	local values = {}
	-- RETURN A TABLE WITH ALL PROPERTIES
	if A == nil then
		for n,v in pairs(Widget.Props) do values[n] = v end; return values
	-- RETURN A SINGLE PROPERTY VALUE ONLY
	elseif type(A) == "string" then 
		return Widget.Props[A] 
	-- RETURN A TABLE WITH SELECTED VALUES
	else
		for n,v in pairs(A) do values[v] = Widget.Props[v] end; return values
	end
end

V.Show = function (name, state, animTime) 
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: show(): Widget '"..name.."' does not exist!"); return end
	if Widget.isVisible == state then return end
	if Widget.FadeTrans ~= nil   then transition.cancel(Widget.FadeTrans); Widget.FadeTrans = nil end
	if type(animTime) == "boolean" and animTime == true then animTime = 300 end
	if animTime == nil or animTime == false then
		Widget.isVisible = state
	else
		Widget.isVisible = true
		Widget.alpha     = state == true and 0 or Widget.Props.alpha
		local alpha      = state == true and Widget.Props.alpha or 0
		Widget.isFading  = true
		Widget.FadeTrans = transition.to(Widget, {time = animTime, alpha = alpha, onComplete = function() Widget.alpha = Widget.Props.alpha; Widget.isVisible = state; Widget.isFading = nil end})
	end
end

V.Enable = function (name, state) 
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: Enable(): Widget '"..name.."' does not exist!"); return end
	Widget.Props.enabled = state
	Widget.alpha = Widget.Props.enabled == true and Widget.Props.alpha or Widget.Props.alpha * V.Themes[Widget.Props.theme].WidgetDisabledAlpha
end

V.GetShape = function (name)
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: GetShape(): Widget '"..name.."' does not exist!"); return end
	return Widget.Props.Shape
end

V.GetHandle = function (name) return V.Widgets[name] end

V.GetDepth = function (name)
	local Widget = V.Widgets[name]; if Widget == nil then V.error("!!! WIDGET ERROR: GetDepth(): Widget '"..name.."' does not exist!"); return end
	if Widget.parent ~= nil then
		local i
		local n = Widget.parent.numChildren
		for i = 1,n do if Widget.parent[i] == Widget then return i end end
	end
	return nil
end




----------------------------------------------------------------





----------------------------------------------------------------
-- PUBLIC: CREATE A BUTTON
----------------------------------------------------------------
V.NewButton = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewButton(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewButton(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_BUTTON
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 2.1
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.oldCaption = ""

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Button_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- MIDDLE
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Button_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = size
		Tmp.y       = 0
		self:insert(Tmp)
		-- RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Button_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)
		-- ICON 
		Tmp         = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
	
		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize

		-- FIT BUTTON WIDTH TO TEXT?
		if Props.width == "auto" then
			self[5].xScale  = 1
			self[5].yScale  = 1
			self[5].text    = Props.caption 
			Props.width     = (V.Round(self[5].width * .5) + size + 4) * Props.scale
			V._CheckProps(self)
			Props.width     = "auto"
		end

		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.ButtonTextColor; if textColor == nil then textColor = Theme.WidgetTextColor end
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 2, 4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
		end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- MIDDLE
		self[3].xScale = (w - size*2) / self[3].width
		-- RIGHT CAP
		self[4].x      = w
		-- CAPTION
		local textW = Props.icon ~= 0 and w-size-4 or w-4
		self[5].text   = Props.caption
		self[5]:setFillColor(textColor[1],textColor[2],textColor[3],1)
		V._WrapGadgetText(self[5], textW, Theme.WidgetFont, Props.fontSize)
		self[5].xScale  = 1
		self[5].yScale  = 1
		self[5].anchorX = 0
		self[5].anchorY = .5
		self[5].xScale  = .5
		self[5].yScale  = .5
		self[5].y       = size*.5 + Theme.WidgetTextYOffset
		self[5].x       = Theme.MarginX; if Props.textAlign == "right" then self[5].x = Props.Shape.w - Theme.MarginX - self[5].width*.5 elseif Props.textAlign == "center" then self[5].x = Props.Shape.w*.5 -  self[5].width*.25 end
		-- ICON 
		self[6].xScale = Props.iconSize / self[6].width
		self[6].yScale = Props.iconSize / self[6].height
		self[6].xScale = Props.flipIconX == true and -V.Abs(self[6].xScale) or V.Abs(self[6].xScale)
		self[6].yScale = Props.flipIconY == true and -V.Abs(self[6].yScale) or V.Abs(self[6].yScale)
		local halfW = (self[6].width*V.Abs(self[6].xScale))*.5
		self[6]:setFrame( Props.icon > 0 and Props.icon or 1 )
		self[6].isVisible    = Props.icon > 0 and true or false
		self[6].x = halfW + Theme.MarginX; if Props.textAlign == "right" then self[6].x = Props.Shape.w - halfW-Theme.MarginX elseif Props.textAlign == "center" then self[6].x = Props.Shape.w*.5 end
		self[6].y = size*.5

		if Props.icon > 0 and Props.caption ~= "" then 
			    if Props.textAlign == "left"   then self[5].x = self[6].x + halfW + 4 
			elseif Props.textAlign == "center" then self[5].x = self[5].x + halfW + 2; self[6].x = self[5].x - halfW - 4 
			elseif Props.textAlign == "right"  then self[6].x = w - halfW - Theme.MarginX; self[5].x = self[5].x - halfW*2 - 8 end

			if Props.iconAlign == "left"  then
			    	self[6].x = Theme.MarginX + halfW; 
			    	if Props.textAlign == "center" then self[5].x = self[5].x - halfW - 2 end
			    	if Props.textAlign == "right"  then self[5].x = self[5].x + halfW*2 + 8 end
			elseif Props.iconAlign == "right" then 
				self[6].x = w - halfW - Theme.MarginX 
				if Props.textAlign == "left" then self[5].x = self[5].x - halfW*2 - 4 end
			end
		end

		self.tx   = self[5].x
		self.ty   = self[5].y
		self.ix   = self[6].x
		self.iy   = self[6].y
		
		-- BUTTON CURRENTLY PRESSED OR NORMAL STATE?
		if self.isFocus and self.inside then self:_drawPressed() else self:_drawReleased() end
		
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
		if EventData.inside then self:_drawPressed(EventData) else self:_drawReleased(EventData) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		-- LEFT CAP
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_ButtonDown_L or Theme.Frame_ButtonToggled_L)
		-- MIDDLE
		self[3]:setFrame( Props.toggleState == false and Theme.Frame_ButtonDown_M or Theme.Frame_ButtonToggled_M)
		-- RIGHT CAP
		self[4]:setFrame(Props.toggleState == false and  Theme.Frame_ButtonDown_R or Theme.Frame_ButtonToggled_R)
		
		if Props.disableOffset ~= true then
			-- CAPTION
			self[5].x = self.tx + 1; self[5].y = self.ty + 1
			-- ICON 
			self[6].x = self.ix + 1; self[6].y = self.iy + 1
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]
		
		-- TOGGLE?
		if EventData then
			if EventData.inside and Props.toggleButton then Props.toggleState = not Props.toggleState end
		end

		-- UNCHECK OTHERS?
		if Props.toggleButton and Props.toggleState == true then
			for i,v in pairs(V.Widgets) do
				local W  = V.Widgets[i]
				if W.typ == V.TYPE_BUTTON and W.Props.toggleButton and Props.toggleGroup ~= nil and W.Props.toggleGroup == Props.toggleGroup and W.Props.toggleState and W ~= self then
					W.Props.toggleState = false
					W:_drawReleased()
				end
			end
		end
		
		-- LEFT CAP
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_Button_L or Theme.Frame_ButtonToggled_L )
		-- MIDDLE
		self[3]:setFrame( Props.toggleState == false and Theme.Frame_Button_M or Theme.Frame_ButtonToggled_M )
		-- RIGHT CAP
		self[4]:setFrame( Props.toggleState == false and Theme.Frame_Button_R or Theme.Frame_ButtonToggled_R )
		-- CAPTION
		self[5].x = self.tx; self[5].y = self.ty
		-- ICON 
		self[6].x = self.ix; self[6].y = self.iy
		
	end
	
	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewButton(): Created new button '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SHAPE BUTTON
----------------------------------------------------------------
V.NewShapeButton = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewShapeButton(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewShapeButton(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_SHAPEBUTTON
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = 16
	Props.minH = 16
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.oldCaption = ""

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- PRESS COLOR & SHINE
		Tmp = display.newGroup(); self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)
		-- ICON 
		Tmp         = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.xScale  = Props.iconSize / Tmp.width
		Tmp.yScale  = Props.iconSize / Tmp.height
		self:insert(Tmp)

		self.imgFile = nil
		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
	
		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize

		if Props.pressColor == nil then Props.pressColor = {0,0,0,100} elseif Props.pressColor[4] == nil then Props.pressColor[4] = 100 end

		-- FIT BUTTON WIDTH TO TEXT?
		if Props.width == "auto" then
			self[3].xScale  = 1
			self[3].yScale  = 1
			self[3].text    = Props.caption 
			Props.width     = (V.Round(self[3].width * .5) + size + 4) * Props.scale
			V._CheckProps(self)
			Props.width     = "auto"
		end

		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.ButtonTextColor; if textColor == nil then textColor = Theme.WidgetTextColor end
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]


		while self[2].numChildren > 0 do self[2][1]:removeSelf() end
		-- PRESS COLOR
		Tmp = display.newRoundedRect(4,4,w-8,h-8,4)
		Tmp.anchorX      = 0
		Tmp.anchorY      = 0
		Tmp.strokeWidth  = 0
		Tmp:setFillColor (Props.pressColor[1],Props.pressColor[2],Props.pressColor[3],Props.pressColor[4])
		self[2]:insert(Tmp)
		-- SHINE
		if self[2][2] then self[2][2]:removeSelf() end
		if #Props.border > 0 then
			Tmp = display.newRoundedRect(4,4,w-8,(h*.5)-8,4)
			Tmp.anchorX      = 0
			Tmp.anchorY      = 0
			Tmp.strokeWidth  = 0
			Tmp:setFillColor (1,1,1,Props.shineAlpha or .125)
			self[2]:insert(Tmp)
		end

		-- CAPTION
		self[3].text   = Props.caption
		self[3]:setFillColor(textColor[1],textColor[2],textColor[3],1)
		V._WrapGadgetText(self[3], w-size-4, Theme.WidgetFont, Props.fontSize)
		self[3].xScale  = 1
		self[3].yScale  = 1
		self[3].anchorX = 0
		self[3].anchorY = .5
		self[3].xScale  = .5
		self[3].yScale  = .5
		self[3].y       = h*.5 + Theme.WidgetTextYOffset
		self[3].x       = Theme.MarginX; if Props.textAlign == "right" then self[3].x = Props.Shape.w - Theme.MarginX - self[3].width*.5 elseif Props.textAlign == "center" then self[3].x = Props.Shape.w*.5 -  self[3].width*.25 end

		-- ICON 
		self[4]:setFrame( Props.icon > 0 and Props.icon or 1 )
		self[4].isVisible    = Props.icon > 0 and true or false
		if Props.caption ~= nil and Props.caption ~= "" then
			-- WITH CAPTION
			local halfW    = (self[4].width*V.Abs(self[4].xScale))*.5
			self[4].xScale = Props.iconSize / self[4].width
			self[4].yScale = Props.iconSize / self[4].height
			if Props.flipIconX == true then self[4].xScale = -self[4].xScale end
			if Props.flipIconY == true then self[4].yScale = -self[4].yScale end
			self[4].x      = halfW + Theme.MarginX; if Props.textAlign == "right" then self[4].x = Props.Shape.w - halfW-Theme.MarginX elseif Props.textAlign == "center" then self[4].x = Props.Shape.w*.5 end
			self[4].y      = self[3].y
			if Props.icon > 0 and Props.caption ~= "" then 
					if Props.textAlign == "left"   then self[3].x = self[4].x + halfW + 4 
				elseif Props.textAlign == "center" then self[3].x = self[3].x + halfW + 2; self[4].x = self[3].x - halfW - 4 
				elseif Props.textAlign == "right"  then self[4].x = Props.Shape.w - halfW - Theme.MarginX; self[3].x = self[3].x - halfW*2 - 4 end
			end
		else
			-- NO CAPTION
			self[4].xScale = (w-8) / self[4].width
			self[4].yScale = (h-8) / self[4].height
			self[4].x      = w*.5
			self[4].y      = h*.5
		end
	
		-- CUSTOM IMAGE?
		local Img
		if Props.image ~= self.imgFile then
			if self[5] then self[5]:removeSelf() end
			self.imgFile = Props.image

			if Props.image ~= nil and Props.image ~= "" then
				self[4].isVisible = false -- HIDE ICON
				self:insert( display.newImage(Props.image, Props.baseDir) )
				self[5].x          = self[4].x
				self[5].y          = self[4].y
				self[5].xScale     = (w-8) / self[5].width
				self[5].yScale     = (h-8) / self[5].height
				if Props.flipIconX == true then self[5].xScale = -self[5].xScale end
				if Props.flipIconY == true then self[5].yScale = -self[5].yScale end
			end
		end

		self.tx   = self[3].x
		self.ty   = self[3].y
		self.ix   = self[4].x
		self.iy   = self[4].y
		
		-- BUTTON CURRENTLY PRESSED OR NORMAL STATE?
		if self.isFocus and self.inside then self:_drawPressed() else self:_drawReleased() end
		
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
		if EventData.inside then self:_drawPressed(EventData) else self:_drawReleased(EventData) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]
		
		-- PRESS COLOR
		self[2][1].isVisible = true
		
		if Props.disableOffset ~= true then
			-- CAPTION
			self[3].x = self.tx + 1; self[3].y = self.ty + 1
			-- ICON 
			self[4].x = self.ix + 1; self[4].y = self.iy + 1
			-- IMAGE 
			if self[5] then self[5].x = self.ix + 1; self[5].y = self.iy + 1 end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		-- TOGGLE?
		if EventData then
			if EventData.inside and Props.toggleButton then Props.toggleState = not Props.toggleState end
		end

		-- UNCHECK OTHERS?
		if Props.toggleButton and Props.toggleState == true then
			for i,v in pairs(V.Widgets) do
				local W  = V.Widgets[i]
				if W.typ == V.TYPE_SHAPEBUTTON and W.Props.toggleButton and Props.toggleGroup ~= nil and W.Props.toggleGroup == Props.toggleGroup and W.Props.toggleState and W ~= self then
					W.Props.toggleState = false
					W:_drawReleased()
				end
			end
		end
		
		-- PRESS COLOR
		self[2][1].isVisible = Props.toggleState
		-- CAPTION
		self[3].x = self.tx; self[3].y = self.ty
		-- ICON 
		self[4].x = self.ix; self[4].y = self.iy
		-- IMAGE 
		if self[5] then self[5].x = self.ix; self[5].y = self.iy end
		
	end
	
	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewShapeButton(): Created new shape button '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SQUARE BUTTON
----------------------------------------------------------------
V.NewSquareButton = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewSquareButton(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewSquareButton(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_SQUAREBUTTON
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = Props.minW
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- BUTTON
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_SquareButton)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- ICON 
		Tmp         = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.xScale  = Props.iconSize / Tmp.width
		Tmp.yScale  = Props.iconSize / Tmp.height
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize
		local w        = Props.Shape.w
		local h        = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale    = Props.scale
		self.yScale    = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- BUTTON
		self[2]:setFrame( Theme.Frame_SquareButton )
		self[2].x      = 0
		self[2].y      = 0
		-- ICON 
		self[3]:setFrame  ( Props.icon > 0 and Props.icon or 1 )
		self[3].isVisible = Props.icon > 0 and true or false
		self[3].x         = size*.5
		self[3].y         = size*.5
		self.ix           = self[3].x
		self.iy           = self[3].y
		self[3].xScale    = Props.flipIconX == true and -V.Abs(self[3].xScale) or V.Abs(self[3].xScale)
		self[3].yScale    = Props.flipIconY == true and -V.Abs(self[3].yScale) or V.Abs(self[3].yScale)

		-- BUTTON CURRENTLY PRESSED OR NORMAL STATE?
		if self.isFocus and self.inside then self:_drawPressed() else self:_drawReleased() end

	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
		if EventData.inside then self:_drawPressed(EventData) else self:_drawReleased(EventData) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]
		-- BUTTON
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_SquareButtonDown or Theme.Frame_SquareButtonToggled )

		if Props.disableOffset ~= true then
			-- ICON 
			self[3].x = self.ix + 1; self[3].y = self.iy + 1
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		-- TOGGLE?
		if EventData then
			if EventData.inside and Props.toggleButton then Props.toggleState = not Props.toggleState end
		end

		-- UNCHECK OTHERS
		if Props.toggleButton and Props.toggleState == true then
			for i,v in pairs(V.Widgets) do
				local W  = V.Widgets[i]
				if W.typ == V.TYPE_SQUAREBUTTON and W.Props.toggleButton and Props.toggleGroup ~= nil and W.Props.toggleGroup == Props.toggleGroup and W.Props.toggleState and W ~= self then
					W.Props.toggleState = false
					W:_drawReleased()
				end
			end
		end

		-- BUTTON
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_SquareButton or Theme.Frame_SquareButtonToggled )
		-- ICON 
		self[3].x = self.ix; self[3].y = self.iy
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewSquareButton(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A DRAG BUTTON
----------------------------------------------------------------
V.NewDragButton = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewDragButton(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewDragButton(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_DRAGBUTTON
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = Props.minW
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp, Bubble
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- BUTTON
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_DragButton)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- BUBBLE GROUP
		local Bubble = display.newGroup()
		self:insert(Bubble)
		Bubble.x     = -size*.5
		Bubble.y     = size*.5
		Bubble.alpha = 0
		-- BUBBLE L
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_L)
		Tmp.anchorX = 1
		Tmp.anchorY =.5
		Tmp.y       = 0
		Bubble:insert(Tmp)
		-- BUBBLE M
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_M)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.y       = 0
		Bubble:insert(Tmp)
		-- BUBBLE R
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_R)
		Tmp.anchorX = 0
		Tmp.anchorY = .5
		Tmp.y       = 0
		Bubble:insert(Tmp)
		-- CAPTION		
		Tmp         = display.newText("000",0,0,size,Props.fontSize+4,Theme.WidgetFont,Props.fontSize)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Bubble:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize
		local w        = Props.Shape.w
		local h        = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale    = Props.scale
		self.yScale    = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(event)
		self.sx     = event.lx
		self.sy     = event.ly
		self.val    = self.Props.value
		-- BUTTON
		self[2]:setFrame( V.Themes[self.Props.theme].Frame_DragButtonDown )
		-- SHOW BUBBLE
		if self.Props.hideBubble ~= true then
			self.Trans = transition.to(self[3], {time = 250, alpha = 1})
		end
		self:_setValue(event)
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(event)
		local Props = self.Props
		local val   = Props.value
		self:_setValue(event)
		if Props.value ~= val and Props.onChange then 
			if Props.changeSound~= nil and V.muted ~= true then audio.play(V.Themes[Props.theme].Sounds[Props.changeSound], {channel = V.channel}) end
			local EventData =
				{
				Widget = self,
				Props  = Props,
				name   = Props.name,
				value  = Props.value,
				}
			Props.onChange(EventData) 
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased()
		-- BUTTON
		self[2]:setFrame( V.Themes[self.Props.theme].Frame_DragButton )
		-- HIDE BUBBLE
		if self.Trans then transition.cancel(self.Trans) end
		self[3].alpha  = 0
	end

	---------------------------------------------
	-- PRIVATE METHOD: SET VALUE
	---------------------------------------------
	function Grp:_setValue(event)
		local Props       = self.Props
		local sensitivity = Props.sensitivity ~= nil and Props.sensitivity or 0.05
		local Theme       = V.Themes [Props.theme]
		local size        = Theme.widgetFrameSize
		local Bubble      = self[3]
		local step        = Props.step ~= nil and Props.step or 1
		local textColor   = Props.textColor ~= nil and Props.textColor or Theme.BubbleTextColor

		Props.value  = self.val + (V.Round( (self.sy - event.ly) * sensitivity )*step)
		    if Props.value < Props.minValue then Props.value = Props.minValue
		elseif Props.value > Props.maxValue then Props.value = Props.maxValue end
		
		-- CAPTION
		Bubble[4].text   = Props.textFormatter == nil and Props.value or Props.textFormatter(Props.value)
		Bubble[4].x      = -Bubble[4].contentWidth*.5
		Bubble[4].y      = -2 + Theme.TooltipTextYOffset
		Bubble[4]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		-- MIDDLE
		Bubble[2].xScale =  (Bubble[4].width) / Bubble[2].width
		Bubble[2].x = Bubble[4].x - Bubble[4].contentWidth * .25
		Bubble[2].y = 0
		-- LEFT CAP
		Bubble[1].x = Bubble[2].x - (Bubble[2].width*Bubble[2].xScale)*.5
		-- RIGHT CAP
		Bubble[3].x =  Bubble[2].x + (Bubble[2].width*Bubble[2].xScale)*.5
		-- POSITION BUBBLE
		--Bubble.x = 0 -- -(Bubble[4].width*.5 + size*.5)
		--Bubble.y = 0
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewDragButton(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A CHECKBOX
----------------------------------------------------------------
V.NewCheckbox = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewCheckbox(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewCheckbox(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_CHECKBOX
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local currentFrame

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- BUTTON
		currentFrame = Props.toggleState == false and Theme.Frame_CheckBox or Theme.Frame_CheckBoxChecked
		Tmp         = V.newSprite(Theme.Set, currentFrame)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- CAPTION
		self[3].text   = Props.caption
		self[3]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		V._WrapGadgetText(self[3], w-size-4, Theme.WidgetFont, Props.fontSize)
		self[3].xScale  = 1
		self[3].yScale  = 1
		self[3].anchorX = 0
		self[3].anchorY = .5
		self[3].xScale  = .5
		self[3].yScale  = .5
		self[3].y       = size*.5 + Theme.WidgetTextYOffset

		-- TEXT ALIGN
		if Props.textAlign == "right" then
			self[2].x = 0
			self[3].x = size + 4
		else
			self[2].x = w-size
			self[3].x = w-size - 4 - self[3].width*.5
		end

		-- IS SELECTED?
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_CheckBox or Theme.Frame_CheckBoxChecked )
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed() 
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		Props.toggleState = not Props.toggleState
		self[2]:setFrame( Props.toggleState == false and Theme.Frame_CheckBox or Theme.Frame_CheckBoxChecked )
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased() end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewCheckbox(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A RADIO BUTTON
----------------------------------------------------------------
V.NewRadiobutton = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewRadiobutton(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewRadiobutton(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_RADIO
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local currentFrame

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- BUTTON
		currentFrame = Props.toggleState == false and Theme.Frame_RadioButton or Theme.Frame_RadioButtonChecked
		Tmp          = V.newSprite(Theme.Set, currentFrame)
		Tmp.anchorX  = 0
		Tmp.anchorY  = 0
		Tmp.y        = 0
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- CAPTION
		self[3].text   = Props.caption
		self[3]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		V._WrapGadgetText(self[3], w-size, Theme.WidgetFont, Props.fontSize)
		self[3].xScale  = 1
		self[3].yScale  = 1
		self[3].anchorX = 0
		self[3].anchorY = .5
		self[3].xScale  = .5
		self[3].yScale  = .5
		self[3].y       = size*.5 + Theme.WidgetTextYOffset

		-- TEXT ALIGN
		if Props.textAlign == "right" then
			self[2].x = 0
			self[3].x = size
		else
			self[2].x = w-size
			self[3].x = w-size - self[3].width*.5
		end
		
		-- IS SELECTED?
		if Props.toggleState == true then self:_drawPressed() end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed() 
		local i,v
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		-- CHECK THIS
		Props.toggleState =  true 
		self[2]:setFrame( Theme.Frame_RadioButtonChecked )
		-- UNCHECK OTHERS
		for i,v in pairs(V.Widgets) do
			if V.Widgets[i].typ == V.TYPE_RADIO and V.Widgets[i].Props.toggleGroup == Props.toggleGroup and V.Widgets[i] ~= self then
				V.Widgets[i].Props.toggleState = false
				V.Widgets[i][2]:setFrame( V.Themes[V.Widgets[i].Props.theme].Frame_RadioButton )
			end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased() end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewRadiobutton(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A MULTILINE TEXT
----------------------------------------------------------------
V.NewText = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewText(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewText(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_TEXT
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Floor(V.Themes[Props.theme].WidgetFontSize * 1.5)
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local w        = Props.Shape.w
		local h        = Props.Shape.h

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)

		local i,c,Tmp,brk,old,new,pos
		local maxW  =  w*2 - Props.fontSize*2
		local lineH =  Props.fontSize + Props.lineSpacing
		local y     =  2
		local autoH = false; if Props.height == 0 or Props.height == "auto" then autoH = true end
		local lines = {}

		-- SPLIT TEXT BY LINE FEEDS ("|")
		pos = 1
		while pos < #Props.caption do
			brk = Props.caption:find('|', pos, true); if brk == nil then brk = #Props.caption end
			c   = Props.caption:sub(brk, brk)
			i   = 0 if c == "|" or c == " " then i = 1 end
			table.insert(lines, Props.caption:sub(pos, brk-i) )
			pos = brk + 1
		end

		-- CREATE EACH LINE AND WRAP IT, IF NECCESSARY
		for i = 1, #lines do
			if autoH == false and y + lineH > h then break end

			-- NEW TEXT LINE?
			if lines[i] ~= "" then
				Tmp    = display.newText(self,"",0,y,Theme.WidgetFont,Props.fontSize*2)
				Tmp.yy = y
			end

			y = y + lineH

			pos = 1
			while pos <= #lines[i] do
				brk = lines[i]:find('[ %-%;,]', pos, false); if brk == nil then brk = #lines[i] end
				new = lines[i]:sub(pos, brk)
				old = Tmp.text
				Tmp.text = Tmp.text..new
				-- NEW TEXT LINE?
				if Tmp.width > maxW then
					Tmp.text = old:gsub("[%s]*$", "")
					if autoH == false and y + lineH > h then break end
					Tmp      =  display.newText(self,new,0,y,Theme.WidgetFont,Props.fontSize*2)
					Tmp.yy   =  y
					y        =  y + lineH
				end
				pos = brk + 1
			end
		end

		-- APPLY AUTO-HEIGHT?
		if autoH then 
			Props.Shape.h = Tmp ~= nil and Tmp.yy + Tmp.height*.5 + 2 or 0
			if Props.Shape.h < Props.minH then Props.Shape.h = Props.minH end
		end

		self.oldCaption = Props.caption
		self.oldWidth   = Props.Shape.w
		self.oldHeight  = Props.Shape.h

		self:_update() 

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
		local Tmp,i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- RE-CREATE TEXT LINES?
		if Props.caption ~= self.oldCaption or w ~= self.oldWidth or h ~= self.oldHeight then 
			self:_create()
		end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- ALIGN TEXT LINES, SET COLOR
		for i = 2, self.numChildren do
			if self[i].text then
				self[i]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
				self[i].xScale  = 1
				self[i].yScale  = 1
				self[i].anchorX = 0
				self[i].anchorY = 0
				self[i].xScale  = .5
				self[i].yScale  = .5
				self[i].x       = Props.fontSize*.5; if Props.textAlign == "center" then self[i].x = w*.5 - self[i].width*.25 elseif Props.textAlign == "right" then self[i].x = w - self[i].width*.5 - Props.fontSize*.5 end
				self[i].y       = self[i].yy
			end
		end
		
		-- RE-ALIGN ON SCREEN
		self:setPos(self.Props.x, self.Props.y)

	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewText(): Created new widget '"..Props.name.."'.")

	return Grp
end





----------------------------------------------------------------
-- PUBLIC: CREATE A MULTILINE TEXT (SIMPLE)
----------------------------------------------------------------
V.NewTextSimple = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewText(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewText(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount = V.widgetCount + 1
	Grp           = display.newGroup()
	Grp.typ       = V.TYPE_TEXT_SIMPLE
	Grp.Props     = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW    = V.Themes[Props.theme].widgetFrameSize
	Props.minH    = V.Floor(V.Themes[Props.theme].WidgetFontSize * 1.5)
	Props.maxW    = 9999
	Props.maxH    = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		while self.numChildren > 0 do self[1]:removeSelf() end
		
		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)

		self:_update() 

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
		local Tmp,i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local w         = Props.Shape.w
		local h         = Props.height == "auto" and 0 or Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- CREATE TEXT
		Props.caption = Props.caption:gsub("|", "\n")  
		if self[2] ~= nil then self[2]:removeSelf() end
		Tmp =  display.newText(self,Props.caption,4,4,w-8,h-8,Theme.WidgetFont,Props.fontSize)
		self[2].anchorX = 0
		self[2].anchorY = 0
		self[2]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		-- AUTO HEIGHT?
		if h == 0 then Props.Shape.h = Tmp.height + 8 end
		-- RE-ALIGN ON SCREEN
		self:setPos(self.Props.x, self.Props.y)
		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewTextSimple(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A PROGRESS BAR
----------------------------------------------------------------
V.NewProgBar = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewProgBar(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewProgBar(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount = V.widgetCount + 1
	Grp           = display.newGroup()
	Grp.typ       = V.TYPE_PROGBAR
	Grp.Props     = Props
	
	Grp.Mask      = graphics.newMask(V.Themes[Props.theme].folderPath..V.Themes[Props.theme].maskImage)
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 3
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp, G
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)
		-- LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Progress_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- MIDDLE
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Progress_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Progress_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- BAR
		local Grp = display.newGroup()
		Grp:setMask(self.Mask)
		Grp.maskScaleY      = size / Theme.maskImageSize
		Grp.maskY           = size*.5
		Grp.isHitTestMasked = true
		self:insert(Grp)

		Tmp         = V.newSprite(Theme.Set, Theme.Frame_ProgressBar_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Grp:insert(Tmp)

		Tmp         = V.newSprite(Theme.Set, Theme.Frame_ProgressBar_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Grp:insert(Tmp)

		Tmp         = V.newSprite(Theme.Set, Theme.Frame_ProgressBar_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Grp:insert(Tmp)
		-- CAPTION SHADOW
		Tmp = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp:setFillColor(Theme.EmbossColorLow[1],Theme.EmbossColorLow[2],Theme.EmbossColorLow[3],1)  
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		for i = 2,4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- LEFT CAP
		self[2].x      = 0
		self[2].y      = 0
		-- MIDDLE
		self[3].x      = size
		self[3].y      = 0
		self[3].xScale = (w-(size*2)) / self[3].width
		-- RIGHT CAP
		self[4].x      = w
		self[4].y      = 0
		-- BAR
		self:_setValue(Props.value)
		self[5][1].x      = 0
		self[5][1].y      = 0
		self[5][2].x      = size
		self[5][2].y      = 0
		self[5][2].xScale = (w-(size*2)) / self[5][2].width
		self[5][3].x      = w
		self[5][3].y      = 0
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE WIDGET'S VALUE (AND BAR)
	---------------------------------------------
	function Grp:_setValue(value)
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor

		    if value  < Props.minValue then value = Props.minValue 
		elseif value  > Props.maxValue then value = Props.maxValue end
		Props.percent = V.Floor( value*100 )
		Props.value   = value

		-- BAR
		local v = Props.value == 0 and 0.001 or Props.value
		self[5].maskScaleX = (v * (Props.Shape.w)) / Theme.maskImageSize
		self[5].maskX      =  v * (Props.Shape.w)*.5

		-- CAPTION
		self[6].text    = Props.textFormatter == nil and Props.value or Props.textFormatter(Props.value)
		V._WrapGadgetText(self[6], Props.Shape.w-Theme.widgetFrameSize-4, Theme.WidgetFont, Props.fontSize)
		self[6].xScale  = 1
		self[6].yScale  = 1
		self[6].anchorX = 0
		self[6].anchorY = .5
		self[6].xScale  = .5
		self[6].yScale  = .5
		self[6].y       = (Theme.widgetFrameSize*.5 + Theme.WidgetTextYOffset)+1
		self[6].x       = (Props.Shape.w*.5 - self[6].width*.25)+1

		self[7]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		self[7].text    = self[6].text
		self[7].xScale  = 1
		self[7].yScale  = 1
		self[7].anchorX = 0
		self[7].anchorY = .5
		self[7].xScale  = .5
		self[7].yScale  = .5
		self[7].x       = self[6].x-1
		self[7].y       = self[6].y-1
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(event)
		if self.Props.allowDrag then self:_setValue( event.lx / self.Props.Shape.w ) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased() end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(event) 
		if self.Props.allowDrag then self:_setValue ( event.lx / self.Props.Shape.w ) end
	end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy() 
		self[5]:setMask(nil)
		self.Mask     = nil
		V._RemoveWidget(self.Props.name) 
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewProgBar(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A BORDER
----------------------------------------------------------------
V.NewBorder = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewBorder(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewBorder(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_BORDER
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create() 
		Tmp = display.newGroup(); self:insert(Tmp)

		Grp:_update() 

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
		local Tmp,i,v
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize

		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale    = Props.scale
		self.yScale    = Props.scale

		Props.includeInLayout = false

		-- FIT TO A WIDGET GROUP
		if Props.group ~= "" then
			Props.x      = 0
			Props.y      = 0
			local minX   =  9999
			local maxX   = -9999
			local minY   =  9999
			local maxY   = -9999
			local Parent = Props.parentGroup
			local P
			for i,v in pairs(V.Widgets) do 
				P = V.Widgets[i].Props
				if P ~= nil and V.Widgets[i].isVisible == true and P.parentGroup == Parent and (P.group == Props.group or Props.group == "auto") and P.name ~= Props.name then
					if P.Shape.x < minX then minX = P.Shape.x end
					if P.Shape.x+P.Shape.w*P.scale > maxX then maxX = P.Shape.x + P.Shape.w*P.scale end
					if P.Shape.y < minY then minY = P.Shape.y end
					if P.Shape.y+P.Shape.h*P.scale > maxY then maxY = P.Shape.y + P.Shape.h*P.scale end
				end
			end
			self.x        = minX
			self.y        = minY
			Props.Shape.x = minX
			Props.Shape.y = minY
			Props.Shape.w = maxX-minX
			Props.Shape.h = maxY-minY
		end
		
		-- BACKGROUND & BORDER
		V._AddBorder(self)

	end


	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewBorder(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SWITCH
----------------------------------------------------------------
V.NewSwitch = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewSwitch(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewSwitch(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_SWITCH
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 2
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.lastState = Grp.Props.toggleState

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)
		-- LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Switch_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Switch_R)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- SLIDER 
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Switch_Button)
		Tmp.anchorX =.5
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 2, 4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
		end

		-- SET SWITCH COLOR
		self:_setColor()

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- CAPTION
		self[5].text    = Props.caption
		self[5]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		V._WrapGadgetText(self[5], w-(size*2)-4, Theme.WidgetFont, Props.fontSize)
		self[5].xScale  = 1
		self[5].yScale  = 1
		self[5].anchorX = 0
		self[5].anchorY = .5
		self[5].xScale  = .5
		self[5].yScale  = .5
		self[5].y       = size*.5 + Theme.WidgetTextYOffset
		-- TEXT ALIGN
		if Props.textAlign == "left" then
			self[2].x = 0
			self[3].x = size
			self[5].x = size*2 + 4
		else
			self[2].x = w-size*2
			self[3].x = w-size
			self[5].x = self[2].x - 4 - self[5].width*.5
		end
		-- SLIDER POSITIONS
		local range = Theme.SwitchRange; if range == nil then range = size*.5 end
		self[4].x1  = self[3].x - range--Theme.widgetFrameSize * 0.5
		self[4].x2  = self[3].x + range--Theme.widgetFrameSize * 1.5
		self[4].x   = Props.toggleState == true and self[4].x2 or self[4].x1
		
		-- CHECK IF TOGGLE STATE CHANGED PROGRAMMATICALLY?
		self:_changed()

	end

	---------------------------------------------
	-- PRIVATE METHOD: CURRENTLY DRAGGED
	---------------------------------------------
	function Grp:_setPos( event )
		local Props    = self.Props
		local Knob     = self[4]
		local size     = V.Themes[Props.theme].widgetFrameSize
		local x        = event.lx
		if x < Knob.x1 then x = Knob.x1 elseif x > Knob.x2 then x = Knob.x2 end
		Knob.x         = x

		-- SET TOGGLESTATE
		Props.toggleState = x > self[3].x and true or false
		
		-- SET SWITCH COLOR
		self:_setColor()
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: APPLY CUSTOM COLOR
	---------------------------------------------
	function Grp:_setColor()
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		-- SET COLOR?
		if Theme.SwitchOnColor then
			if Props.toggleState == true then 
				self[2]:setFillColor(Theme.SwitchOnColor[1],Theme.SwitchOnColor[2],Theme.SwitchOnColor[3],1) 
				self[3]:setFillColor(Theme.SwitchOnColor[1],Theme.SwitchOnColor[2],Theme.SwitchOnColor[3],1) 
			else
				self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) 
				self[3]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) 
			end
		end
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: TOGGLE STATE CHANGED
	---------------------------------------------
	function Grp:_changed()
		local Props = self.Props
		if self.lastState ~= Props.toggleState then
			self.lastState = Props.toggleState
			if Props.changeSound~= nil and V.muted ~= true then audio.play(V.Themes[Props.theme].Sounds[Props.changeSound], {channel = V.channel}) end
			if Props.onChange   ~= nil then Props.onChange(
				{
				Widget      = self,
				Props       = Props,
				name        = Props.name,
				toggleState = Props.toggleState,
				}) 
			end
		end
	end
	
	---------------------------------------------
	-- PRIVATE METHODS: PRESSED / DRAGGED / RELEASED
	---------------------------------------------
	function Grp:_drawPressed ( event ) Grp:_setPos(event) end
	function Grp:_drawDragged ( event ) Grp:_setPos(event) end

	function Grp:_drawReleased( event ) 
		-- SLIDE OUT, THEN CALL _changed()		
		self.SlideTimer = timer.performWithDelay(1,
			function(event)
				local Widget = event.source.Widget
				local Knob   = Widget[4]
				local x      = Widget.Props.toggleState == true and Knob.x2 or Knob.x1
				Knob.x       = Knob.x - (Knob.x - x)/2
				if V.Abs(Knob.x - x) < 1 then
					Knob.x = V.Round(x)
					timer.cancel(Widget.SlideTimer)
					event.source.Widget.SlideTimer = nil
					event.source.Widget            = nil
					Widget:_changed()
				end
			end	,0)
		self.SlideTimer.Widget  = self
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewSwitch(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SLIDER
----------------------------------------------------------------
V.NewSlider = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewSlider(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewSlider(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_SLIDER
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	if Props.vertical == true then
		Props.minW = V.Themes[Props.theme].widgetFrameSize * 1
		Props.minH = V.Themes[Props.theme].widgetFrameSize * 3
		Props.maxW = Props.minW
		Props.maxH = 9999
	else
		Props.minW = V.Themes[Props.theme].widgetFrameSize * 3
		Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
		Props.maxW = 9999
		Props.maxH = Props.minH
	end

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.oldValue = Grp.Props.value

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)
		-- LEFT CAP
		Tmp = V.newSprite(Theme.Set, Theme.Frame_Slider_L)
		if Props.vertical then 
			Tmp.anchorX  = 0
			Tmp.anchorY  = 1
			Tmp.rotation = 90
			Tmp.x        = size
			Tmp.y        = 0
			Tmp.yScale   = -1 
		else
			Tmp.anchorX  = 0
			Tmp.anchorY  = 0
			Tmp.x        = 0
			Tmp.y        = 0
		end
		self:insert(Tmp)
		-- MIDDLE
		Tmp = V.newSprite(Theme.Set, Theme.Frame_Slider_M)
		if Props.vertical then 
			Tmp.anchorX  = 0
			Tmp.anchorY  = 0
			Tmp.rotation = 90
			Tmp.x        = 0
			Tmp.y        = size 
			Tmp.yScale   = -1 
		else
			Tmp.anchorX  = 0
			Tmp.anchorY  = 0
			Tmp.x        = size
			Tmp.y        = 0
		end
		self:insert(Tmp)
		-- RIGHT CAP
		Tmp = V.newSprite(Theme.Set, Theme.Frame_Slider_R)
		if Props.vertical then 
			Tmp.anchorX  = 1
			Tmp.anchorY  = 0
			Tmp.rotation = 90
			Tmp.x        = 0 
			Tmp.yScale   = -1 
		else
			Tmp.anchorX  = 1
			Tmp.anchorY  = 0
			Tmp.y        = 0
		end
		self:insert(Tmp)
		-- TICKS GROUP
		local Grp = display.newGroup(); self:insert(Grp)
		-- SLIDER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Slider_Button)
		Tmp.anchorX = .5
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		if Props.vertical then 
			Tmp.rotation = 90
			Tmp.yScale   = -1
		end
		self:insert(Tmp)
		-- BUBBLE GROUP
		local Grp = display.newGroup(); self:insert(Grp)
		Grp.alpha = Props.alwaysShowBubble ~= true and 0 or 1
		-- BUBBLE L
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_L)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Tmp.y       = 0
		Grp:insert(Tmp)
		-- BUBBLE M
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_M)
		Tmp.anchorX = .5
		Tmp.anchorY = 0
		Tmp.y       = 0
		Grp:insert(Tmp)
		-- BUBBLE R
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Tooltip_R)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.y       = 0
		Grp:insert(Tmp)
		-- CAPTION		
		Tmp           = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale    = .5
		Tmp.yScale    = .5
		Grp:insert(Tmp)
		
		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize
		local w        = Props.Shape.w
		local h        = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale    = Props.scale
		self.yScale    = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 2, 4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
			self[6]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1)
		end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		-- MIDDLE
		if Props.vertical then self[3].xScale = (h-(size*2)) / self[3].width else self[3].xScale = (w-(size*2)) / self[3].width end
		-- RIGHT CAP
		if Props.vertical then self[4].y = h else self[4].x = w end
		-- SLIDER
		self:_setValue(Props.value)
		-- TICKS
		self[5]:removeSelf()
		local Grp = display.newGroup(); self:insert(5, Grp)
		local stepSize
		if Props.tickStep and Props.tickStep > 1 then
			if Props.vertical then
				stepSize = (h-size) / ((Props.maxValue-Props.minValue)/Props.tickStep)
				for i = size*.5, h-size*.5, stepSize do
					Tmp = display.newRect(Grp,size*.5+Theme.SliderTicksCenterOffset,V.Floor(i), 4,1)
					Tmp.strokeWidth  = 1
					Tmp:setStrokeColor(Theme.SliderTickStrokeColor [1],Theme.SliderTickStrokeColor [2],Theme.SliderTickStrokeColor [3])
					Tmp:setFillColor  (Theme.SliderTickFillColor[1],Theme.SliderTickFillColor[2],Theme.SliderTickFillColor[3])
				end
			else
				stepSize = (w-size) / ((Props.maxValue-Props.minValue)/Props.tickStep)
				for i = size*.5, w-size*.5, stepSize do
					Tmp = display.newRect(Grp,V.Floor(i),size*.5+Theme.SliderTicksCenterOffset, 1,4)
					Tmp.strokeWidth  = 1
					Tmp:setStrokeColor(Theme.SliderTickStrokeColor [1],Theme.SliderTickStrokeColor [2],Theme.SliderTickStrokeColor [3])
					Tmp:setFillColor  (Theme.SliderTickFillColor[1],Theme.SliderTickFillColor[2],Theme.SliderTickFillColor[3])
				end
			end
		end

	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE WIDGET'S VALUE (AND KNOB)
	---------------------------------------------
	function Grp:_setValue(value)
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.BubbleTextColor
		local size      = Theme.widgetFrameSize
		local Knob      = self[6]
		local Bubble    = self[7]

		    if value  < Props.minValue then value = Props.minValue 
		elseif value  > Props.maxValue then value = Props.maxValue end
		Props.percent = V.Floor( ((value-Props.minValue) / (Props.maxValue-Props.minValue))*100 )
		Props.value   = value

		-- SLIDER
		if Props.vertical == true then 
			Knob.y = Props.reversed == true and V.Floor((Props.Shape.h-size*.5) - (Props.percent/100) * (Props.Shape.h-size)) or V.Floor(size*.5 + (Props.percent/100) * (Props.Shape.h-size))
		else 
			Knob.x = Props.reversed == true and V.Floor((Props.Shape.w-size*.5) - (Props.percent/100) * (Props.Shape.w-size)) or V.Floor(size*.5 + (Props.percent/100) * (Props.Shape.w-size)) 
		end

		-- CAPTION
		Bubble[4].text    = Props.textFormatter == nil and Props.value or Props.textFormatter(Props.value)
		Bubble[4].xScale  = 1
		Bubble[4].yScale  = 1
		Bubble[4].anchorX = .5
		Bubble[4].anchorY = .5
		Bubble[4].xScale  = .5
		Bubble[4].yScale  = .5
		Bubble[4].y       = size*.5 + Theme.TooltipTextYOffset
		Bubble[4]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		-- MIDDLE / LEFT / RIGHT CAPS
		Bubble[2].xScale =  (Bubble[4].width*.5) / Bubble[2].width
		Bubble[1].x      = -(Bubble[4].width*.25)
		Bubble[3].x      =  (Bubble[4].width*.25)
		-- POSITION BUBBLE
		if self.Props.vertical then Bubble.x = Knob.x+size*.5; Bubble.y = Knob.y-size*1.5
		                       else Bubble.x = Knob.x; Bubble.y = Knob.y-size end
		local minX, minY = self:contentToLocal(0,0)
		local maxX, maxY = self:contentToLocal(V.screenW,V.screenH)
		local bounds     = Bubble.contentBounds
		if Bubble.x < minX + Bubble.contentWidth*.5 then Bubble.x = minX + Bubble.contentWidth*.5 elseif Bubble.x > maxX - Bubble.contentWidth*.5 then Bubble.x = maxX - Bubble.contentWidth *.5 end
		if Bubble.y < minY then Bubble.y = Knob.y + size end
		-- ON CHANGE
		if self.oldValue ~= Props.value then
			self.oldValue = Props.value

			if Props.changeSound~= nil and V.muted ~= true then audio.play(Theme.Sounds[Props.changeSound], {channel = V.channel}) end
			if Props.onChange then Props.onChange(
				{
				Widget = self,
				Props  = Props,
				name   = Props.name,
				value  = Props.value,
				}) 
			end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: PRESSED
	---------------------------------------------
	function Grp:_drawPressed( event )
		-- SHOW BUBBLE
		if Props.hideBubble ~= true then
			self.Trans = transition.to(self[7], {time = 250, alpha = 1})
		end
		-- POSITION KNOB
		if self.Props.vertical then Grp:_setPosV(event) else Grp:_setPosH(event) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAGGED
	---------------------------------------------
	function Grp:_drawDragged( event ) 
		-- POSITION KNOB
		if self.Props.vertical then Grp:_setPosV(event) else Grp:_setPosH(event) end
	end

	---------------------------------------------
	-- PRIVATE METHOD: MOVE KNOB
	---------------------------------------------
	function Grp:_setPosH( event )
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		event.lx    = Props.reversed == true and Props.Shape.w - event.lx - Theme.widgetFrameSize*.5 or event.lx - Theme.widgetFrameSize*.5
		-- STEP
		if Props.step then
			local stepSize = (Props.Shape.w-Theme.widgetFrameSize) / ((Props.maxValue-Props.minValue)/Props.step)
			event.lx       = V.Floor(event.lx / stepSize) * stepSize
		end
		-- GET VALUE & PERCENT, POSITION KNOB
		local percent = event.lx / (Props.Shape.w-Theme.widgetFrameSize)
		local value   = (Props.minValue + (Props.maxValue-Props.minValue)*percent)
		self:_setValue  (value)
	end

	function Grp:_setPosV( event )
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		event.ly    = Props.reversed == true and Props.Shape.h - event.ly - Theme.widgetFrameSize*.5 or event.ly - Theme.widgetFrameSize*.5
		-- STEP
		if Props.step then
			local stepSize = (Props.Shape.h-Theme.widgetFrameSize) / ((Props.maxValue-Props.minValue)/Props.step)
			event.ly       = V.Floor(event.ly / stepSize) * stepSize
		end
		-- GET VALUE & PERCENT, POSITION KNOB
		local percent = event.ly / (Props.Shape.h-Theme.widgetFrameSize)
		local value   = (Props.minValue + (Props.maxValue-Props.minValue)*percent)
		self:_setValue  (value)
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased() 
		-- HIDE BUBBLE
		if self.Trans then transition.cancel(self.Trans) end
		self[7].alpha  = self.Props.alwaysShowBubble ~= true and 0 or 1
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewSlider(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A LIST
----------------------------------------------------------------
V.NewList = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewList(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewList(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount = V.widgetCount + 1
	Grp           = display.newGroup()
	Grp.typ       = V.TYPE_LIST
	Grp.Props     = Props

	Grp.Mask      = graphics.newMask(V.Themes[Props.theme].folderPath..V.Themes[Props.theme].maskImage)
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 5
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1.5
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Props.editMode = false

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup()
		self:insert(Tmp)
		-- BG
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- R
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- L
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- T
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_T)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- B
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_B)
		Tmp.anchorX = 0
		Tmp.anchorY = 1
		self:insert(Tmp)
		-- BR CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_BR)
		Tmp.anchorX = 1
		Tmp.anchorY = 1
		self:insert(Tmp)
		-- TL CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_TL)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- TR CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_TR)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- BL CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_BL)
		Tmp.anchorX = 0
		Tmp.anchorY = 1
		self:insert(Tmp)
		-- GROUP FOR LINE ITEMS
		Tmp = display.newGroup()
		self:insert(Tmp)
		-- BACK BUTTON
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_List_BackButton)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 4
		Tmp.y       = 0
		self:insert(Tmp)
		-- CAPTION		
		Tmp              = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale       = .5
		Tmp.yScale       = .5
		Grp:insert(Tmp)
		-- BOTTOM CAPTION		
		Tmp              = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale       = .5
		Tmp.yScale       = .5
		Tmp.isVisible    = false
		Grp:insert(Tmp)
		-- SCROLLBAR
		Tmp              = display.newGroup()
		Tmp.name         = "ScrollbarGroup"
		Grp:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update(animate)

		local i, Grp1, Grp2, Item, Tmp
		local Props       = self.Props
		local Theme       = V.Themes [Props.theme]
		local size        = Theme.widgetFrameSize
		local itemH       = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local w           = Props.Shape.w
		local h           = Props.Shape.h
		local textColor   = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale       = Props.scale
		self.yScale       = Props.scale

		if Props.list == nil then Props.list = {} end

		self.listMinY     = Props.caption ~= "" and -(((#Props.list*itemH-h)+itemH*2)) or -((#Props.list*itemH-h)+itemH)
		self.itemOffset   = 0
		self.lastOffset   = -1
		self.numItems     = Props.caption ~= "" and V.Floor(h / itemH)+1 or V.Floor(h / itemH)+2
		self.margin       = size*.25 + Theme.MarginX
		
		-- SAME LIST AS BEFORE?
		if Props.list == self.lastList then
			if self.listY < self.listMinY then 
				self.listY          = self.listMinY 
				if Props.selectedIndex > #Props.list then Props.selectedIndex = #Props.list end
			end
		-- SWITCHED TO ANOTHER LIST
		else self.listY = 0; Props.selectedIndex = 0 end

		self.lastList = Props.list

		-- COLORIZE PARTS?
		for i = 2,10 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		
		-- CREATE NEW LIST
		self[11]:setMask(nil)
		self[11]:removeSelf()
		Grp1 = display.newGroup()
		self:insert(11,Grp1)
		Grp1:setMask(self.Mask)
		self:_adjustMask()

		Grp2 = display.newGroup()
		Grp1:insert(Grp2)
		for i = 1, self.numItems do
			Item  = display.newGroup()
			Grp2:insert(Item)
			Item.anchorX = 0
			Item.anchorY = 0
			Item.x       = 0
			Item.y       = (i-1)*itemH
			-- ITEM BG GRAPHIC
			Tmp = V.newSprite(Theme.Set, Theme.Frame_List_ItemBG)
			Tmp.anchorX      = 0
			Tmp.anchorY      = 0
			Tmp.x            = 0
			Tmp.y            = 0
			Tmp.xScale       = w / Tmp.width
			Tmp.yScale       = itemH / Tmp.height
			Item:insert(Tmp)
			-- ITEM BG COLOR
			Tmp = display.newRect(0,0,w,itemH-1)
			Tmp.anchorX      = 0
			Tmp.anchorY      = 0
			Tmp.strokeWidth  = 0
			Item:insert(Tmp)
			-- ITEM CAPTION (DUMMY)
			Tmp = display.newGroup()
			Tmp.oldWidth = 0
			Item:insert(Tmp)
			-- RIGHT ICON
			Tmp = V.newSprite(Theme.SetIcons)
			Tmp.anchorX = .5
			Tmp.anchorY = .5
			Tmp.xScale       = Props.iconSize / Tmp.width
			Tmp.yScale       = Props.iconSize / Tmp.height
			Tmp.x            = (w-self.margin) - Props.iconSize * .5
			Tmp.y            = itemH*.5
			Item:insert(Tmp)
			-- LEFT ICON
			Tmp              = V.newSprite(Theme.SetIcons)
			Tmp.anchorX      = .5
			Tmp.anchorY      = .5
			Tmp.xScale       = Props.iconSize / Tmp.width
			Tmp.yScale       = Props.iconSize / Tmp.height
			Tmp.x            = self.margin + Props.iconSize * .5
			Tmp.y            = itemH*.5
			Item:insert(Tmp)
		end
		self:_arrangeList()
		
		-- ANIMATION?
		if animate then
			Grp2.x     = animate == "right" and -w or w
			Grp2.Trans = transition.to(Grp2, {time = 250, x = 0})
		end
		
		-- BG
		self[2].x       = size
		self[2].y       = size
		self[2].xScale  = (w-(size*2)) / self[2].width
		self[2].yScale  = (h-(size*2)) / self[2].height
		-- R
		self[3].x       = w
		self[3].y       = size
		self[3].yScale  = (h-(size*2)) / self[3].height
		-- L
		self[4].x       = 0
		self[4].y       = size
		self[4].yScale  = (h-(size*2)) / self[4].height
		-- T
		self[5].x       = size
		self[5].y       = 0
		self[5].xScale  = (w-(size*2)) / self[5].width
		-- B
		self[6].x       = size
		self[6].y       = h
		self[6].xScale  = (w-(size*2)) / self[6].width
		-- BR CORNER
		self[7].x = w; self[7].y = h
		-- TR CORNER
		self[9].x = w; self[9].y = 0
		-- BL CORNER
		self[10].x = 0; self[10].y = h
		-- CAPTION
		self[13].text = Props.caption
		self[13]:setFillColor(textColor[1],textColor[2],textColor[3])
		V._WrapGadgetText(self[13], w-size-8, Theme.WidgetFont, Props.fontSize)
		self[13].xScale  = 1
		self[13].yScale  = 1
		self[13].anchorX = 0
		self[13].anchorY = .5
		self[13].xScale  = .5
		self[13].yScale  = .5
		self[13].y       = size*.5 + Theme.WidgetTextYOffset
		self[13].x       = w*.5 - self[13].width*.25 -- CENTER
		-- BACK BUTTON?
		if Props.list.parentList ~= nil then
			self[12].isVisible = true
			self[12].alpha     = 0
			transition.to(self[12], {time = 250, alpha = 1 })
			if self[13].x < size+8 then transition.to(self[13], { time = 150, x = (w-4)-self[13].width*.5 }) end
		else
			self[12].isVisible = false
		end
		-- BOTTOM CAPTION
		self[14]:setFillColor(textColor[1],textColor[2],textColor[3])

		self:_applyScrollbar()
	end

	---------------------------------------------
	-- PRIVATE METHOD: APPLY SCROLLBAR
	---------------------------------------------
	function Grp:_applyScrollbar()
		local Tmp1, Tmp2
		local Props = self.Props; if Props == nil then return end
		local w     = Props.Shape.w
		local h     = Props.Shape.h
		local size  = V.Themes [Props.theme].widgetFrameSize
		local Tmp   = self[15]
		while Tmp.numChildren > 0 do Tmp[1]:removeSelf() end
		if Props.scrollbar ~= "never" then
			local barWidth  = 4
			local barHeight = Props.caption == "" and h-8 or h-size-8; if Props.editMode == true then barHeight = barHeight - size end
			local barH      = (self.numItems / #Props.list); if barH > 1 then barH = 1 elseif barH <= 0 then barH = 0.001 end
			local barAlpha  = Props.scrollbarAlpha ~= nil and Props.scrollbarAlpha or 1
			Tmp.x = w-barWidth-4
			Tmp.y = self[11].y + (Props.caption == "" and 2 or size+2)
			-- SCROLLBAR BG
			Tmp1              = display.newRect(0,0,barWidth,barHeight)
			Tmp1.anchorX      = 0
			Tmp1.anchorY      = 0
			Tmp1.strokeWidth  = 0
			Tmp1:setFillColor  (Props.scrollbarBGColor[1],Props.scrollbarBGColor[2],Props.scrollbarBGColor[3], barAlpha)
			Tmp1:setStrokeColor(0,0,0, .78)
			Tmp:insert(Tmp1)
			-- SCROLLBAR THUMB
			Tmp2              = display.newRect(0,0,barWidth,Tmp1.height*barH) 
			Tmp2.strokeWidth  = 0
			Tmp2:setFillColor  (Props.scrollbarColor[1],Props.scrollbarColor[2],Props.scrollbarColor[3], .78)
			Tmp2:setStrokeColor(1,1,1, 0)
			Tmp2.anchorX      = 0
			Tmp2.anchorY      = 0
			Tmp2.maxY         = barHeight-Tmp2.height
			Tmp:insert(Tmp2)
			self:_positionScrollbar(true)
			if Props.scrollbar == "onScroll" then Tmp.alpha = 0 end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: POSITION SCROLLBAR ACCORDING TO CURRENT LIST SCROLL
	---------------------------------------------
	function Grp:_positionScrollbar(hide)
		if self[15][2] == nil then return end
		local scrollbar = self.Props.scrollbar
		if scrollbar == nil or scrollbar == "never" or hide == true then 
			self[15].alpha = 0
		elseif scrollbar == "always" or (scrollbar == "onScroll" and self.isSliding == true) then
			self[15].alpha = 1 
			-- POSITION SCROLLBAR
			self[15][2].y  = (self.listY / (self.listMinY/100) / 100) * (self[15][2].maxY) 
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: POSITION LIST, UPDATE ITEMS
	---------------------------------------------
	function Grp:_arrangeList()
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.ListItemTextColor
		local size      = Theme.widgetFrameSize
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local Items     = self[11][1]
		local i, num, data, maxTextW, Img, Item, Tmp, isTable, imgSize, txt
		
		-- POSITION LIST
		if self.listMinY >= 0 then self.listY = 0
		else
			if self.listY > 0 then self.listY = 0; self.speedY = 0 elseif self.listY < self.listMinY then self.listY = self.listMinY; self.speedY = 0 end
		end
		Items.y = Props.caption ~= "" and size + V.Floor(self.listY % -itemH) or V.Floor(self.listY % -itemH)

		-- POSITION SCROLLBAR
		self:_positionScrollbar()

		-- UPDATE ITEMS
		self.itemOffset = (V.Floor(-self.listY / itemH))
		if self.lastOffset ~= self.itemOffset then
			self.lastOffset = self.itemOffset
			for i = 1,Items.numChildren do
				num      = i + self.itemOffset
				data     = Props.list[num]
				isTable  = type(data) == "table" and true or false
				Item     = Items[i]
				
				-- NORMAL / SELECTED BACKGROUND?
				if num == Props.selectedIndex then
					Item[2].alpha     = 1
					Item[2].isVisible = true
					Item[2]:setFillColor(unpack(Theme.ListItemSelectedColor))
				   else Item[2].isVisible = false end

				-- IS TABLE ITEM?
				if isTable then
					-- BG COLOR
					if Props.disableBGColor ~= true and num ~= Props.selectedIndex then
						Item[2].isVisible = true
						if data.bgColor ~= nil then 
							Item[2]:setFillColor(data.bgColor[1],data.bgColor[2],data.bgColor[3],1)
							Item[2].alpha = data.bgColor[4] or 1
						else 	Item[2].alpha = 0 end
					end
					-- RIGHT ICON
					if data.iconR ~= nil and data.iconR > 0 then Item[4].isVisible = true; Item[4]:setFrame( data.iconR ) else Item[4].isVisible = false end
					-- LEFT ICON
					if data.iconL ~= nil and data.iconL > 0 then Item[5].isVisible = true; Item[5]:setFrame( data.iconL ) else Item[5].isVisible = false end
				
					-- CUSTOM IMAGE
					if data.image ~= Item.imgFile or data.imageSize ~= Item.imgSize then
						if Item[6] then Item[6]:removeSelf() end
						Item.imgFile = data.image
						Item.imgSize = data.imageSize ~= nil and data.imageSize or Props.iconSize

						if data.image ~= nil and data.image ~= "" then
							Img        = display.newImage(data.image, data.baseDir) 
							Item:insert(6, Img)
							Img.x      = Item.imgSize *.5 + self.margin
							Img.y      = Item[5].y
							Img.xScale = Item.imgSize / Img.width
							Img.yScale = Item.imgSize / Img.height
						end
					end 
				end
				
				if Props.editMode and data then
					-- SHOW DELETE ICON?
					if Props.allowDelete then 
						if Item.imgFile then Item[4].isVisible = true; Item[4]:setFrame( Theme.Icon_List_Delete )
						                else Item[5].isVisible = true; Item[5]:setFrame( Theme.Icon_List_Delete ) end
					end
					-- SHOW SORT ICON?
					if Props.allowSort   then Item[4].isVisible = true; Item[4]:setFrame( Theme.Icon_List_Move ) end
				end
				
				--if Props.disableWrapping ~= true then V._WrapGadgetText(Item[3], maxTextW, Theme.WidgetFont, Props.fontSize) end

				-- ITEM CAPTION
				
				-- CALCULATE MAX. WIDTH, ROUND TO NEAREST MULTIPLE OF 4
				maxTextW = Props.Shape.w - 8
				maxTextW = V.Ceil(maxTextW / 4) * 4
				if Item[4].isVisible then     -- HAS RIGHT ICON?
					maxTextW = maxTextW - (Props.iconSize + 16) 
				end
				if Item[6] ~= nil then        -- HAS CUSTOM IMAGE?
					maxTextW = maxTextW - (Item.imgSize + 16)
				elseif Item[5].isVisible then -- HAS LEFT ICON?
					maxTextW = maxTextW - (Props.iconSize + 16) 
				end
				-- SET TEXT
				if isTable == false or data == nil then
					txt = data ~= nil and data or " "
				else
					txt = data.caption
				end
				-- CHANGED WIDTH OR TEXT?
				if maxTextW ~= Item[3].oldWidth or txt ~= Item[3].text then
					Item[3]:removeSelf()
					Tmp = display.newText(txt,0,0,maxTextW,0,Theme.WidgetFont,Props.fontSize)
					Item:insert(3,Tmp)
					Tmp.anchorX  = 0
					Tmp.anchorY  = .5
					Tmp.oldWidth = maxTextW
				end
				-- SET COLOR
				if isTable == false or data == nil then
					Item[3]:setFillColor(textColor[1],textColor[2],textColor[3],1)
					Item[4].isVisible = false
					Item[5].isVisible = false
					if Item[6] then Item[6]:removeSelf(); Item.imgFile = nil end
				else
					if data.textColor then Item[3]:setFillColor(data.textColor[1],data.textColor[2],data.textColor[3],1) 
					                  else Item[3]:setFillColor(textColor[1],textColor[2],textColor[3],1) end
				end
				-- POSITION TEXT
				Item[3].x = self.margin
				if Item[6] ~= nil then                -- HAS CUSTOM IMAGE?
					Item[3].x = (Item[6].x + Item.imgSize*.5 + 4)
				elseif Item[5].isVisible == true then -- HAS LEFT ICON?
					Item[3].x = Item[3].x + Props.iconSize + 4 
				end
				Item[3].y = itemH * .5
			end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(event) 
		local Props    = self.Props
		local Theme    = V.Themes[Props.theme]
		local size     = Theme.widgetFrameSize
		local itemH    = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local List     = self[11][1]
		local item     = V.Ceil( (event.ly-List.y) / itemH)

		-- BACK BUTTON PRESSED?
		if self[12].isVisible and event.lx < size and event.ly < size then
			self.backButtonPressed = true
			self[12]:setFrame( Theme.Frame_List_BackButtonDown )
			return
		-- BOTTOM BUTTON PRESSED?
		elseif Props.editMode == true and event.ly > Props.Shape.h - size then
			self.bottomButtonPressed = true
			self[6 ]:setFrame( Theme.Frame_List_B3 )
			self[7 ]:setFrame( Theme.Frame_List_BR3)
			self[10]:setFrame( Theme.Frame_List_BL3)
			return
		-- DEL ICON PRESSED?
		elseif Props.editMode and Props.allowDelete and ((List[item].imgFile == nil and event.lx < 8 + Props.iconSize) or (List[item].imgFile ~= nil and event.lx > (Props.Shape.w - 8 - Props.iconSize) ) ) then
			self.delIconPressed = true
			local i
			local index  = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)

			local data   = Props.list[index]
			if data and data.selectable ~= false and data.deletable ~= false then
				-- CONFIRM?
				if Props.onItemRemoveRequest then
					Props.onItemRemoveRequest( { Widget = self, Props = Props, list = Props.list, List = Props.list, pos = index } )
				-- REMOVE!
				else self:deleteItem(Props.list,index,true) end
				return
			end
		-- LEFT ICON PRESSED
		elseif event.lx < 8 + Props.iconSize then
			local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
			if Props.list[index] and Props.list[index].iconL and Props.list[index].iconL > 0 then self.iconPressed = index end
		-- RIGHT ICON PRESSED
		elseif event.lx > Props.Shape.w - Props.iconSize - self.margin then
			local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
			if Props.list[index] and Props.list[index].iconR and Props.list[index].iconR > 0 then self.iconPressedR = index end
		
		-- SORT ICON PRESSED?
		--elseif Props.editMode and Props.allowSort and event.lx > Props.Shape.w - Props.iconSize then
		--	local List = self[11][1]
		--	self.sortIconPressed = true
		--	self.DragItem        = List[V.Ceil( (event.ly-List.y) / size)]
		--	self.DragItem.sy     = self.DragItem.y            -- ORIGINAL Y-POS
		--	self.DragItem.oy     = event.ly - self.DragItem.y -- DRAG OFFSET
		end
		-- INIT DRAG
		if self.Timer ~= nil then timer.cancel(self.Timer); self.Timer = nil end
		self.speedY    = 0
		self.clickedX  = event.lx
		self.clickedY  = event.ly
		self.lastY     = event.ly
		self.currListY = self.listY
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(event) 
		-- BUTTON DOWN?
		if self.delIconPressed or self.backButtonPressed or self.bottomButtonPressed or self.iconPressed or self.iconPressedR then return end
		-- ITEM DRAGGING?
		--if self.DragItem then
		--	self.DragItem.y = event.ly - self.DragItem.oy
		--	return
		--end
		if self.Props.noScroll ~= true then
			self.listY     = self.currListY + (event.ly-self.clickedY)
			self.speedY    = event.ly - self.lastY
			self.lastY     = event.ly
			self.isSliding = true
			self:_arrangeList()
		end
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(event) 
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		local size  = Theme.widgetFrameSize
		local itemH = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local Items = self[11][1]

		--self.isSliding = false; self:_positionScrollbar(true)

		-- BACK BUTTON RELEASED?
		if self.backButtonPressed then
			self.backButtonPressed = false
			self[12]:setFrame( Theme.Frame_List_BackButton )
			--if Props.onBackButton then Props.onBackButton(Props.list, Props.selectedIndex) end
			if Props.onBackButton ~= nil then
				local EventData =
					{
					Widget = self,
					Props  = Props,
					name   = Props.name,
					List   = Props.list,
					Item   = Props.list[index],
					selectedIndex = Props.selectedIndex,
					} 
				Props.onBackButton(EventData)
			end
			if Props.list ~= nil and Props.list.parentList ~= nil then 
				self:setList(Props.list.parentList, "right")
			end
			return
		
		-- BOTTOM BUTTON RELEASED?
		elseif self.bottomButtonPressed then
			self.bottomButtonPressed  = false
			self:editMode(false)
			return
			
		-- DEL ICON PRESSED?
		elseif self.delIconPressed then
			self.delIconPressed = false
			return
			
		-- LEFT ICON PRESSED?
		elseif self.iconPressed then
			local index = self.iconPressed
			self.iconPressed = nil
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				if Props.list[index] and Props.list[index].selectable ~= false and Props.list[index].iconL then
					if self.Props.onIconPress then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							selectedIndex = index,
							x      = event.x,
							y      = event.y,
							lx     = event.lx,
							ly     = event.ly,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onIconPress(event.source.EventData)
									event.source.EventData   = nil
									event.source.onIconPress = nil
							end	,1)
						Timer.EventData   = EventData
						Timer.onIconPress = self.Props.onIconPress
					end
				end
			end
			return

		-- RIGHT ICON PRESSED?
		elseif self.iconPressedR then
			local index = self.iconPressedR
			self.iconPressedR = nil
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				if Props.list[index] and Props.list[index].selectable ~= false and Props.list[index].iconR then
					if self.Props.onIconPressR then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							selectedIndex = index,
							x      = event.x,
							y      = event.y,
							lx     = event.lx,
							ly     = event.ly,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onIconPressR(event.source.EventData)
									event.source.EventData    = nil
									event.source.onIconPressR = nil
							end	,1)
						Timer.EventData    = EventData
						Timer.onIconPressR = self.Props.onIconPressR
					end
				end
			end
			return
			
		-- SWIPE RIGHT -ENTER EDIT MODE?
		elseif (Props.allowDelete or Props.allowSort) and V.Abs(event.ly - self.clickedY) < size and event.lx - self.clickedX > size then 
			self:editMode(true)
			return
		
		else
			-- ITEM CLICKED?
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
				if Props.list[index] and Props.list[index].selectable ~= false then
					Props.selectedIndex = index
					self.lastOffset     = -1
					self:_arrangeList()
					-- CHANGE TO CHILD LIST?
					-- if Props.list[index].childList ~= nil then 
					-- 	self:setList(Props.list[index].childList, "left")
					-- end
					-- ON SELECT LISTENER?
					if Props.selectSound ~= nil and V.muted ~= true then audio.play(Theme.Sounds[Props.selectSound], {channel = V.channel}) end
					if self.Props.onSelect then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							lx     = event.lx,
							ly     = event.ly,
							x      = event.x,
							y      = event.y,
							selectedIndex = Props.selectedIndex,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onSelect(event.source.EventData)
									event.source.EventData = nil
									event.source.onSelect  = nil
							end	,1)
						Timer.EventData = EventData
						Timer.onSelect  = self.Props.onSelect
					end
				end
				return
			end
		end
		
		-- SCROLLED - DRAG SLIDE-OUT
		self.Timer = timer.performWithDelay(33,
			function(event)
				local Widget     = event.source.Widget
				Widget.isSliding = true
				Widget.listY     = Widget.listY + Widget.speedY
				Widget.speedY    = Widget.speedY * (Props.slideOut or .95)
				Widget:_arrangeList()
				if V.Abs(Widget.speedY) < 0.1 then 
					event.source.Widget = nil
					timer.cancel(Widget.Timer) 
					Widget.isSliding = nil
					Widget.Timer     = nil
					-- HIDE SCROLLBAR?
					if Widget.Props ~= nil and Widget.Props.scrollbar ~= "always" then transition.to(Widget[15], {time = 300, alpha = 0}) end
				end
			end	,0)
		self.Timer.Widget = self
	end

	---------------------------------------------
	-- PRIVATE METHOD: ADJUST MASK
	---------------------------------------------
	function Grp:_adjustMask()
		--self[11]:setMask(nil)
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		local size  = Theme.widgetFrameSize
		self[11].maskScaleX = Props.Shape.w / Theme.maskImageSize
		self[11].maskX      = Props.Shape.w*.5
		if Props.caption == "" then
			self[11].maskScaleY = Props.editMode == true and (Props.Shape.h-size*.5-size*.25) / Theme.maskImageSize or Props.Shape.h / Theme.maskImageSize
			self[11].maskY      = Props.editMode == true and Props.Shape.h*.5 - size*.4 or Props.Shape.h*.5
		else
			self[11].maskScaleY = Props.editMode == true and (Props.Shape.h-size*2) / Theme.maskImageSize or (Props.Shape.h-size) / Theme.maskImageSize
			self[11].maskY      = Props.editMode == true and Props.Shape.h*.5 or Props.Shape.h*.5 + size*.45 
		end
	end

	---------------------------------------------
	-- PUBLIC METHODS: SCROLL LIST PROGRAMMATICALLY
	---------------------------------------------
	function Grp:scrollBy(numItems)
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or Theme.widgetFrameSize; if itemH < Theme.widgetFrameSize then itemH = Theme.widgetFrameSize end
		self.listY      = V.Floor( (self.listY - (numItems * itemH))/ itemH) * itemH
		self:_arrangeList()
	end

	function Grp:scrollTo(numItems)
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or Theme.widgetFrameSize; if itemH < Theme.widgetFrameSize then itemH = Theme.widgetFrameSize end
		self.listY      = -(numItems-1) * itemH
		self:_arrangeList()
	end
	
	---------------------------------------------
	-- PUBLIC METHODS: LISTS & ITEMS
	---------------------------------------------
	function Grp:setIndex(index)
		local Props = self.Props
		if index < 0 then index = 0 elseif index > #Props.list then index = #Props.list end
		if index == 0 or Props.list[index].selectable ~= false then
			Props.selectedIndex = index 
			self.lastOffset     = -1
			self:_arrangeList()
		end
	end

	function Grp:getIndex() return Props.selectedIndex end

	function Grp:setList(List, slideDirection)
		local Props = self.Props
		if Props.list == List then return end
		if Props.list == nil then V.error("!!! WIDGET ERROR: List:setList(): Specified list table does not exist."); return end
		-- CURRENT LIST IS EMPTY? NO ANIMATION
		-- if Props.list == self.emptyList then Props.list = List; self:_update(); return end

		-- CHANGE WITH / WITHOUT ANIMATION
		Props.list = List
		if Props.noSlide == true then self:_update()
		else
			local x = slideDirection == "left" and -Props.Shape.w or Props.Shape.w
			transition.to(self[11][1], {time = 250, x = x, onComplete = function() self:_update(slideDirection) end })
			transition.to(self[12]  , {time = 250, alpha = 0})
		end
	end

	function Grp:getCurrList() return self.Props.list end

	function Grp:deleteItem(list, pos, animate)
		local k,v,i
		local Props = self.Props

		if list      == nil then V.error("!!! WIDGET ERROR: List:deleteItem(): Specified list table does not exist."); return end
		if list[pos] == nil then V.error("!!! WIDGET ERROR: List:deleteItem(): Specified item index does not exist."); return end

		-- ANIMATE LIST ITEMS FIRST, THEN DELETE
		if animate == true then
			local Items = self[11][1]
			local item  = pos-self.itemOffset
			for i = Items.numChildren,item+1,-1 do
				transition.to (Items[i], { time = 200, y = Items[i-1].y })
			end
			transition.to (Items[item], { time = 200, alpha = 0.999, onComplete = function() self:deleteItem(Props.list,pos,false) end })
			return
		-- NO ANIMATION, DELETE NOW!
		else
			-- REMOVE TABLE ITEM
			if type(list[pos]) == "table" then
				for k,v in pairs(list[pos]) do list[pos][k] = nil end
			end
			table.remove(list, pos)
			-- CALL LISTENER FUNCTION
			if Props.onItemRemove then
				local EventData =
					{
					Widget = self,
					Props  = Props,
					name   = Props.name,
					List   = list,
					list   = list,
					pos    = pos,
					selectedIndex = Props.selectedIndex,
					} 
				Props.onItemRemove(EventData)
			end
			if Props.list == list then self:_update() end
		end
	end
	
	---------------------------------------------
	-- PUBLIC METHOD: ENABLE / DISABLE EDIT MODE
	---------------------------------------------
	function Grp:editMode(mode)
		local Props,i  = self.Props
		local Theme    = V.Themes[Props.theme]
		local size     = Theme.widgetFrameSize
		local List     = self[11][1]
		if Props.editMode == mode then return false end
		Props.editMode = mode == true and mode or false

		if mode == true then
			-- SHOW BOTTOM BUTTON
			self[6]:setFrame ( Theme.Frame_List_B2 )
			self[7]:setFrame ( Theme.Frame_List_BR2)
			self[10]:setFrame( Theme.Frame_List_BL2)
			-- BOTTOM CAPTION
			self[14].text      = Props.readyCaption
			V._WrapGadgetText (self[14], Props.Shape.w-size-8, Theme.WidgetFont, Props.fontSize)
			self[14].xScale    = 1
			self[14].yScale    = 1
			self[14].anchorX   = 0
			self[14].anchorY   = .5
			self[14].xScale    = .5
			self[14].yScale    = .5
			self[14].y         = (Props.Shape.h - size*.5) + Theme.WidgetTextYOffset
			self[14].x         = Props.Shape.w*.5 - self[14].width*.25 -- CENTER
			self[14].isVisible = true
		else
			self[6]:setFrame ( Theme.Frame_List_B )
			self[7]:setFrame ( Theme.Frame_List_BR)
			self[10]:setFrame( Theme.Frame_List_BL)
			self[14].isVisible   = false
		end
		-- ADJUST MASK
		self:_adjustMask()
		-- RESIZE SCROLLBAR
		self:_applyScrollbar()
		-- ANIMATE ICONS
		for i = 1, List.numChildren do
			if Props.allowSort == true then
				List[i][4].xScale, List[i][4].yScale = 0.001, 0.001
				transition.to(List[i][4], {time = 200, xScale = 1, yScale = 1})
			end
			if Props.allowDelete == true then
				List[i][5].xScale, List[i][5].yScale = 0.001, 0.001
				transition.to(List[i][5], {time = 200, xScale = Props.iconSize / List[i][5].width, yScale = Props.iconSize / List[i][5].height})
			end
		end
		self.lastOffset = -1
		self:_arrangeList()
	end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy() 
		self.setIndex      = nil
		self.getIndex      = nil
		self.getCurrList   = nil
		self.deleteItem    = nil
		self.editMode      = nil
		self._arrangeList  = nil
		self._adjustMask   = nil
		-- DELETE MASK
		self[11]:setMask (nil)
		self.Mask         = nil
		self.DragItem     = nil
		-- DELETE TIMER
		if self.Timer    ~= nil then timer.cancel(self.Timer); self.Timer = nil end
		-- DELETE LISTS
		local k,v
		self.Props.list         = nil
		self.Props.onSelect     = nil
		self.Props.onIconPress  = nil
		self.Props.onIconPressR = nil
		self.Props.onItemRemove = nil
		self.lastList           = nil
		V._RemoveWidget(self.Props.name) 
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewList(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A CUSTOM LIST
----------------------------------------------------------------
V.NewCustomList = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewCustomList(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewCustomList(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount = V.widgetCount + 1
	Grp           = display.newGroup()
	Grp.typ       = V.TYPE_CUSTOMLIST
	Grp.Props     = Props

	Grp.Mask      = graphics.newMask(V.Themes[Props.theme].folderPath..V.Themes[Props.theme].maskImage)
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 5
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 3
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Props.editMode = false

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup()
		self:insert(Tmp)
		-- BG
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_M)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 0
		self:insert(Tmp)
		-- R
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_R)
		Tmp.anchorX   = 1
		Tmp.anchorY   = 0
		self:insert(Tmp)
		-- L
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_L)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 0
		self:insert(Tmp)
		-- T
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_T)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 0
		self:insert(Tmp)
		-- B
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_B)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 1
		self:insert(Tmp)
		-- BR CORNER
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_BR)
		Tmp.anchorX   = 1
		Tmp.anchorY   = 1
		self:insert(Tmp)
		-- TL CORNER
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_TL)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 0
		Tmp.x = 0
		Tmp.y = 0
		self:insert(Tmp)
		-- TR CORNER
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_TR)
		Tmp.anchorX   = 1
		Tmp.anchorY   = 0
		self:insert(Tmp)
		-- BL CORNER
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_BL)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 1
		self:insert(Tmp)
		-- GROUP FOR LINE ITEMS
		Tmp = display.newGroup()
		self:insert(Tmp)
		-- BACK BUTTON
		Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_BackButton)
		Tmp.anchorX   = 0
		Tmp.anchorY   = 0
		Tmp.x         = 4
		Tmp.y         = 0
		self:insert(Tmp)
		-- CAPTION		
		Tmp              = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale       = .5
		Tmp.yScale       = .5
		Grp:insert(Tmp)
		-- BOTTOM CAPTION		
		Tmp              = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale       = .5
		Tmp.yScale       = .5
		Tmp.isVisible    = false
		Grp:insert(Tmp)
		-- SCROLLBAR
		Tmp              = display.newGroup()
		Tmp.name         = "ScrollbarGroup"
		Grp:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update(animate)

		local i, Grp1, Grp2, Item, Tmp
		local Props       = self.Props
		local Theme       = V.Themes [Props.theme]
		local size        = Theme.widgetFrameSize
		local itemH       = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local w           = Props.Shape.w
		local h           = Props.Shape.h
		local textColor   = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale       = Props.scale
		self.yScale       = Props.scale

		if Props.list == nil then Props.list = {} end

		self.listMinY     = Props.caption ~= "" and -(((#Props.list*itemH-h)+itemH*2)) or -((#Props.list*itemH-h)+itemH)
		self.itemOffset   = 0
		self.lastOffset   = -1
		self.numItems     = Props.caption ~= "" and V.Floor(h / itemH)+1 or V.Floor(h / itemH)+2
		self.margin       = size*.25 + Theme.MarginX
		
		-- SAME LIST AS BEFORE?
		if Props.list == self.lastList then
			if self.listY < self.listMinY then 
				self.listY          = self.listMinY 
				if Props.selectedIndex > #Props.list then Props.selectedIndex = #Props.list end
			end
		-- SWITCHED TO ANOTHER LIST
		else self.listY = 0; Props.selectedIndex = 0 end

		self.lastList = Props.list
		
		-- INITIALLY HIDE ALL CUSTOM LIST ITEMS, SHOW NEEDED ONES ONLY
		for i = 1, #Props.list do 
			if Props.list[i].content ~= nil then 
				Props.list[i].content.isVisible = false 
				display.currentStage:insert(Props.list[i].content)
			end 
		end

		-- COLORIZE PARTS?
		for i = 2,10 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]
		
		-- CREATE NEW LIST
		self[11]:setMask(nil)
		self[11]:removeSelf()
		Grp1 = display.newGroup()
		self:insert(11,Grp1)
		Grp1:setMask(self.Mask)
		self:_adjustMask()

		Grp2 = display.newGroup()
		Grp1:insert(Grp2)
		for i = 1, self.numItems do
			Item  = display.newGroup()
			Grp2:insert(Item)
			Item.x = 0
			Item.y = (i-1)*itemH
			-- ITEM BG GRAPHIC
			Tmp           = V.newSprite(Theme.Set, Theme.Frame_List_ItemBG)
			Tmp.anchorX   = 0
			Tmp.anchorY   = 0
			Tmp.x         = 0
			Tmp.y         = 0
			Tmp.xScale    = w / Tmp.width
			Tmp.yScale    = itemH / Tmp.height
			Item:insert(Tmp)
			-- ITEM BG COLOR
			Tmp             = display.newRect(0,0,w,itemH-1)
			Tmp.anchorX     = 0
			Tmp.anchorY     = 0
			Tmp.strokeWidth = 0
			Item:insert(Tmp)
			-- ITEM CAPTION (DUMMY)
			Tmp = display.newGroup()
			Tmp.oldWidth = 0
			Item:insert(Tmp)
			-- RIGHT ICON
			Tmp         = V.newSprite(Theme.SetIcons)
			Tmp.anchorX = .5
			Tmp.anchorY = .5
			Tmp.xScale  = Props.iconSize / Tmp.width
			Tmp.yScale  = Props.iconSize / Tmp.height
			Tmp.x       = (w-self.margin) - Props.iconSize * .5
			Tmp.y       = itemH*.5
			Item:insert(Tmp)
			-- LEFT ICON
			Tmp         = V.newSprite(Theme.SetIcons)
			Tmp.anchorX = .5
			Tmp.anchorY = .5
			Tmp.xScale  = Props.iconSize / Tmp.width
			Tmp.yScale  = Props.iconSize / Tmp.height
			Tmp.x       = self.margin + Props.iconSize * .5
			Tmp.y       = itemH*.5
			Item:insert(Tmp)
		end
		self:_arrangeList()
		
		-- ANIMATION?
		if animate then
			Grp2.x     = animate == "right" and -w or w
			Grp2.Trans = transition.to(Grp2, {time = 250, x = 0})
		end
		
		-- BG
		self[2].x       = size
		self[2].y       = size
		self[2].xScale  = (w-(size*2)) / self[2].width
		self[2].yScale  = (h-(size*2)) / self[2].height
		-- R
		self[3].x       = w
		self[3].y       = size
		self[3].yScale  = (h-(size*2)) / self[3].height
		-- L
		self[4].x       = 0
		self[4].y       = size
		self[4].yScale  = (h-(size*2)) / self[4].height
		-- T
		self[5].x       = size
		self[5].y       = 0
		self[5].xScale  = (w-(size*2)) / self[5].width
		-- B
		self[6].x       = size
		self[6].y       = h
		self[6].xScale  = (w-(size*2)) / self[6].width
		-- BR CORNER
		self[7].x = w; self[7].y = h
		-- TR CORNER
		self[9].x = w; self[9].y = 0
		-- BL CORNER
		self[10].x = 0; self[10].y = h
		-- CAPTION
		self[13].text = Props.caption
		self[13]:setFillColor(textColor[1],textColor[2],textColor[3])
		V._WrapGadgetText(self[13], w-size-8, Theme.WidgetFont, Props.fontSize)
		self[13].xScale  = 1
		self[13].yScale  = 1
		self[13].anchorX = 0
		self[13].anchorY = .5
		self[13].xScale  = .5
		self[13].yScale  = .5
		self[13].y       = size*.5 + Theme.WidgetTextYOffset
		self[13].x       = w*.5 - self[13].width*.25 -- CENTER
		-- BACK BUTTON?
		if Props.list.parentList ~= nil then
			self[12].isVisible = true
			self[12].alpha     = 0
			transition.to(self[12], {time = 250, alpha = 1 })
			if self[13].x < size+8 then transition.to(self[13], { time = 150, x = (w-4)-self[13].width*.5 }) end
		else
			self[12].isVisible = false
		end
		-- BOTTOM CAPTION
		self[14]:setFillColor(textColor[1],textColor[2],textColor[3])
		
		self:_applyScrollbar()
	end

	---------------------------------------------
	-- PRIVATE METHOD: APPLY SCROLLBAR
	---------------------------------------------
	function Grp:_applyScrollbar()
		local Tmp1, Tmp2
		local Props = self.Props; if Props == nil then return end
		local w     = Props.Shape.w
		local h     = Props.Shape.h
		local size  = V.Themes [Props.theme].widgetFrameSize
		local Tmp   = self[15]
		while Tmp.numChildren > 0 do Tmp[1]:removeSelf() end
		if Props.scrollbar ~= "never" then
			local barWidth  = 4
			local barHeight = Props.caption == "" and h-8 or h-size-8; if Props.editMode == true then barHeight = barHeight - size end
			local barH      = (self.numItems / #Props.list); if barH > 1 then barH = 1 elseif barH <= 0 then barH = 0.001 end
			local barAlpha  = Props.scrollbarAlpha ~= nil and Props.scrollbarAlpha or 1
			Tmp.x = w-barWidth-4
			Tmp.y = self[11].y + (Props.caption == "" and 2 or size+2)
			-- SCROLLBAR BG
			Tmp1              = display.newRect(0,0,barWidth,barHeight)
			Tmp1.anchorX      = 0
			Tmp1.anchorY      = 0
			Tmp1.strokeWidth  = 0
			Tmp1:setFillColor  (Props.scrollbarBGColor[1],Props.scrollbarBGColor[2],Props.scrollbarBGColor[3], barAlpha)
			Tmp1:setStrokeColor(0,0,0, .78)
			Tmp:insert(Tmp1)
			-- SCROLLBAR THUMB
			Tmp2              = display.newRect(0,0,barWidth,Tmp1.height*barH) 
			Tmp2.strokeWidth  = 0
			Tmp2:setFillColor (Props.scrollbarColor[1],Props.scrollbarColor[2],Props.scrollbarColor[3], .78)
			Tmp2:setStrokeColor (1,1,1, 0)
			Tmp2.anchorX      = 0
			Tmp2.anchorY      = 0
			Tmp2.maxY         = barHeight-Tmp2.height
			Tmp:insert(Tmp2)
			self:_positionScrollbar(true)
			if Props.scrollbar == "onScroll" then Tmp.alpha = 0 end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: POSITION SCROLLBAR ACCORDING TO CURRENT LIST SCROLL
	---------------------------------------------
	function Grp:_positionScrollbar(hide)
		if self[15][2] == nil then return end
		local scrollbar = self.Props.scrollbar
		if scrollbar == nil or scrollbar == "never" or hide == true then 
			self[15].alpha = 0
		elseif scrollbar == "always" or (scrollbar == "onScroll" and self.isSliding == true) then
			self[15].alpha = 1 
			-- POSITION SCROLLBAR
			self[15][2].y  = (self.listY / (self.listMinY/100) / 100) * (self[15][2].maxY) 
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: POSITION LIST, UPDATE ITEMS
	---------------------------------------------
	function Grp:_arrangeList()
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.ListItemTextColor
		local size      = Theme.widgetFrameSize
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local Items     = self[11][1]
		local i, num, data, maxTextW, Img, Item, Tmp, isTable, imgSize, txt
		
		-- POSITION LIST
		if self.listMinY >= 0 then self.listY = 0
		else
			if self.listY > 0 then self.listY = 0; self.speedY = 0 elseif self.listY < self.listMinY then self.listY = self.listMinY; self.speedY = 0 end
		end
		Items.y = Props.caption ~= "" and size + V.Floor(self.listY % -itemH) or V.Floor(self.listY % -itemH)

		-- POSITION SCROLLBAR
		self:_positionScrollbar()

		-- UPDATE ITEMS
		self.itemOffset = (V.Floor(-self.listY / itemH))
		if self.lastOffset ~= self.itemOffset then
			self.lastOffset = self.itemOffset
			for i = 1,Items.numChildren do
				num      = i + self.itemOffset
				data     = Props.list[num]
				isTable  = type(data) == "table" and true or false
				Item     = Items[i]
				
				-- NORMAL / SELECTED BACKGROUND?
				if num == Props.selectedIndex then
					 Item[2].isVisible = true
					 Item[2]:setFillColor(unpack(Theme.ListItemSelectedColor))
				    else Item[2].isVisible = false end

				-- IS TABLE ITEM?
				if isTable then
					-- BG COLOR
					if Props.disableBGColor ~= true and num ~= Props.selectedIndex then
						Item[2].isVisible = true
						if data.bgColor ~= nil then 
							Item[2]:setFillColor(data.bgColor[1],data.bgColor[2],data.bgColor[3],.25) 
						else
							Item[2]:setFillColor(Theme.color[1],Theme.color[2],Theme.color[3],.25) 
						end
					end
					-- RIGHT ICON
					if data.iconR ~= nil and data.iconR > 0 then Item[4].isVisible = true; Item[4]:setFrame( data.iconR ) else Item[4].isVisible = false end
					-- LEFT ICON
					if data.iconL ~= nil and data.iconL > 0 then Item[5].isVisible = true; Item[5]:setFrame( data.iconL ) else Item[5].isVisible = false end
				end
				
				if Props.editMode and data then
					-- SHOW DELETE ICON?
					if Props.allowDelete then 
						Item[5].isVisible = true; Item[5]:setFrame( Theme.Icon_List_Delete )
					end
					-- SHOW SORT ICON?
					if Props.allowSort   then Item[4].isVisible = true; Item[4]:setFrame( Theme.Icon_List_Move ) end
				end
				
				-- CUSTOM ITEM
				
				-- REMOVE PREVIOUS?
				if Item[3][1] ~= nil and Item[3][1] ~= data.content then
					Item[3][1].isVisible = false
					display.currentStage:insert(Item[3][1])
				end
				-- ADD CURRENT
				if data and data.content then
					Item[3]:insert(data.content)
					Item[3][1].anchorX   = 0
					Item[3][1].anchorY   = 0
					Item[3][1].x         = 0
					Item[3][1].y         = 0
					Item[3][1].isVisible = true
				end
				
				-- NO CONTENT?
				if isTable == false or data == nil then
					if Item[3][1] then Item[3][1]:removeSelf() end
					Item[4].isVisible = false
					Item[5].isVisible = false
				end
				
				-- POSITION CUSTOM ITEM
				Item[3].x = self.margin
				if Item[5].isVisible == true then -- HAS LEFT ICON?
					Item[3].x = Item[3].x + Props.iconSize + 4 
				end
			end
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(event) 
		local Props    = self.Props
		local Theme    = V.Themes[Props.theme]
		local size     = Theme.widgetFrameSize
		local itemH    = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local List     = self[11][1]
		local item     = V.Ceil( (event.ly-List.y) / itemH)
		-- BACK BUTTON PRESSED?
		if self[12].isVisible and event.lx < size and event.ly < size then
			self.backButtonPressed = true
			self[12]:setFrame( Theme.Frame_List_BackButtonDown )
			return
		-- BOTTOM BUTTON PRESSED?
		elseif Props.editMode == true and event.ly > Props.Shape.h - size then
			self.bottomButtonPressed = true
			self[6 ]:setFrame( Theme.Frame_List_B3 )
			self[7 ]:setFrame( Theme.Frame_List_BR3)
			self[10]:setFrame( Theme.Frame_List_BL3)
			return
		-- DEL ICON PRESSED?
		elseif Props.editMode and Props.allowDelete and ((List[item].imgFile == nil and event.lx < 8 + Props.iconSize) or (List[item].imgFile ~= nil and event.lx > (Props.Shape.w - 8 - Props.iconSize) ) ) then
			self.delIconPressed = true
			local i
			local index  = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
			local data   = Props.list[index]
			if data and data.selectable ~= false and data.deletable ~= false then
				-- CONFIRM?
				if Props.onItemRemoveRequest then
					Props.onItemRemoveRequest( { Widget = self, Props = Props, list = Props.list, List = Props.list, pos = index } )
				-- REMOVE!
				else self:deleteItem(Props.list,index,true) end
				return
			end
		-- LEFT ICON PRESSED
		elseif event.lx < 8 + Props.iconSize then
			local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
			if Props.list[index] and Props.list[index].iconL and Props.list[index].iconL > 0 then self.iconPressed = index end
		-- RIGHT ICON PRESSED
		elseif event.lx > Props.Shape.w - Props.iconSize - self.margin then
			local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
			if Props.list[index] and Props.list[index].iconR and Props.list[index].iconR > 0 then self.iconPressedR = index end
		
		-- SORT ICON PRESSED?
		--elseif Props.editMode and Props.allowSort and event.lx > Props.Shape.w - Props.iconSize then
		--	local List = self[11][1]
		--	self.sortIconPressed = true
		--	self.DragItem        = List[V.Ceil( (event.ly-List.y) / size)]
		--	self.DragItem.sy     = self.DragItem.y            -- ORIGINAL Y-POS
		--	self.DragItem.oy     = event.ly - self.DragItem.y -- DRAG OFFSET
		end
		-- INIT DRAG
		if self.Timer ~= nil then timer.cancel(self.Timer); self.Timer = nil end
		self.speedY    = 0
		self.clickedX  = event.lx
		self.clickedY  = event.ly
		self.lastY     = event.ly
		self.currListY = self.listY
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(event) 
		-- BUTTON DOWN?
		if self.delIconPressed or self.backButtonPressed or self.bottomButtonPressed or self.iconPressed or self.iconPressedR then return end
		-- ITEM DRAGGING?
		--if self.DragItem then
		--	self.DragItem.y = event.ly - self.DragItem.oy
		--	return
		--end
		
		if self.Props.noScroll ~= true then
			self.listY     = self.currListY + (event.ly-self.clickedY)
			self.speedY    = event.ly - self.lastY
			self.lastY     = event.ly
			self.isSliding = true
			self:_arrangeList()
		end
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(event) 
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		local size  = Theme.widgetFrameSize
		local itemH = Props.itemHeight ~= nil and Props.itemHeight or size; if itemH < size then itemH = size end
		local Items = self[11][1]

		--self.isSliding = false; self:_positionScrollbar(true)
		
		-- BACK BUTTON RELEASED?
		if self.backButtonPressed then
			self.backButtonPressed = false
			self[12]:setFrame( Theme.Frame_List_BackButton )
			--if Props.onBackButton then Props.onBackButton(Props.list, Props.selectedIndex) end
			if Props.onBackButton ~= nil then
				local EventData =
					{
					Widget = self,
					Props  = Props,
					name   = Props.name,
					List   = Props.list,
					Item   = Props.list[index],
					selectedIndex = Props.selectedIndex,
					} 
				Props.onBackButton(EventData)
			end
			if Props.list ~= nil and Props.list.parentList ~= nil then 
				self:setList(Props.list.parentList, "right")
			end
			return
		
		-- BOTTOM BUTTON RELEASED?
		elseif self.bottomButtonPressed then
			self.bottomButtonPressed  = false
			self:editMode(false)
			return
			
		-- DEL ICON PRESSED?
		elseif self.delIconPressed then
			self.delIconPressed = false
			return
			
		-- LEFT ICON PRESSED?
		elseif self.iconPressed then
			local index = self.iconPressed
			self.iconPressed = nil
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				if Props.list[index] and Props.list[index].selectable ~= false and Props.list[index].iconL then
					if self.Props.onIconPress then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							selectedIndex = index,
							x      = event.x,
							y      = event.y,
							lx     = event.lx,
							ly     = event.ly,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onIconPress(event.source.EventData)
									event.source.EventData   = nil
									event.source.onIconPress = nil
							end	,1)
						Timer.EventData   = EventData
						Timer.onIconPress = self.Props.onIconPress
					end
				end
			end
			return

		-- RIGHT ICON PRESSED?
		elseif self.iconPressedR then
			local index = self.iconPressedR
			self.iconPressedR = nil
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				if Props.list[index] and Props.list[index].selectable ~= false and Props.list[index].iconR then
					if self.Props.onIconPressR then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							selectedIndex = index,
							x      = event.x,
							y      = event.y,
							lx     = event.lx,
							ly     = event.ly,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onIconPressR(event.source.EventData)
									event.source.EventData    = nil
									event.source.onIconPressR = nil
							end	,1)
						Timer.EventData    = EventData
						Timer.onIconPressR = self.Props.onIconPressR
					end
				end
			end
			return
			
		-- SWIPE RIGHT -ENTER EDIT MODE?
		elseif (Props.allowDelete or Props.allowSort) and V.Abs(event.ly - self.clickedY) < size and event.lx - self.clickedX > size then 
			self:editMode(true)
			return
		
		else
			-- ITEM CLICKED?
			if Props.editMode == false and V.Abs(self.clickedX - event.lx) < 10 and V.Abs(self.clickedY - event.ly) < 10 then
				local index = Props.caption ~= "" and V.Ceil(((event.ly-size)-self.listY) / itemH) or V.Ceil((event.ly-self.listY) / itemH)
				if Props.list[index] and Props.list[index].selectable ~= false then
					Props.selectedIndex = index
					self.lastOffset     = -1
					self:_arrangeList()
					-- CHANGE TO CHILD LIST?
					-- if Props.list[index].childList ~= nil then 
					-- 	self:setList(Props.list[index].childList, "left")
					-- end
					-- ON SELECT LISTENER?
					if Props.selectSound ~= nil and V.muted ~= true then audio.play(Theme.Sounds[Props.selectSound], {channel = V.channel}) end
					if self.Props.onSelect then
						local EventData =
							{
							Widget = self,
							Props  = Props,
							name   = Props.name,
							List   = Props.list,
							Item   = Props.list[index],
							selectedIndex = Props.selectedIndex,
							lx     = event.lx,
							ly     = event.ly,
							x      = event.x,
							y      = event.y,
							} 
						local Timer = timer.performWithDelay(50,
							function(event)
									event.source.onSelect(event.source.EventData)
									event.source.EventData = nil
									event.source.onSelect  = nil
							end	,1)
						Timer.EventData = EventData
						Timer.onSelect  = self.Props.onSelect
					end
				end
				return
			end
		end
		
		-- SCROLLED - DRAG SLIDE-OUT
		self.Timer    = timer.performWithDelay(33,
			function(event)
				local Widget = event.source.Widget
				Widget.isSliding = true
				Widget.listY     = Widget.listY + Widget.speedY
				Widget.speedY    = Widget.speedY * (Props.slideOut or .95)
				Widget:_arrangeList()
				if V.Abs(Widget.speedY) < 0.1 then 
					event.source.Widget = nil
					timer.cancel(Widget.Timer) 
					Widget.isSliding = nil
					Widget.Timer     = nil
					-- HIDE SCROLLBAR?
					if Widget.Props.scrollbar ~= "always" then transition.to(Widget[15], {time = 300, alpha = 0}) end
				end
			end	,0)
		self.Timer.Widget = self
	end

	---------------------------------------------
	-- PRIVATE METHOD: ADJUST MASK
	---------------------------------------------
	function Grp:_adjustMask()
		--self[11]:setMask(nil)
		local Props = self.Props
		local Theme = V.Themes[Props.theme]
		local size  = Theme.widgetFrameSize
		self[11].maskScaleX = Props.Shape.w / Theme.maskImageSize
		self[11].maskX      = Props.Shape.w*.5
		if Props.caption == "" then
			self[11].maskScaleY = Props.editMode == true and (Props.Shape.h-size*.5-size*.25) / Theme.maskImageSize or Props.Shape.h / Theme.maskImageSize
			self[11].maskY      = Props.editMode == true and Props.Shape.h*.5 - size*.4 or Props.Shape.h*.5
		else
			self[11].maskScaleY = Props.editMode == true and (Props.Shape.h-size*2) / Theme.maskImageSize or (Props.Shape.h-size) / Theme.maskImageSize
			self[11].maskY      = Props.editMode == true and Props.Shape.h*.5 or Props.Shape.h*.5 + size*.45 
		end
	end

	---------------------------------------------
	-- PUBLIC METHODS: SCROLL LIST PROGRAMMATICALLY
	---------------------------------------------
	function Grp:scrollBy(numItems)
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or Theme.widgetFrameSize; if itemH < Theme.widgetFrameSize then itemH = Theme.widgetFrameSize end
		self.listY      = V.Floor( (self.listY - (numItems * itemH))/ itemH) * itemH
		self:_arrangeList()
	end

	function Grp:scrollTo(numItems)
		local Props     = self.Props; if Props == nil then return end
		local Theme     = V.Themes[Props.theme]
		local itemH     = Props.itemHeight ~= nil and Props.itemHeight or Theme.widgetFrameSize; if itemH < Theme.widgetFrameSize then itemH = Theme.widgetFrameSize end
		self.listY      = -(numItems-1) * itemH
		self:_arrangeList()
	end
	
	---------------------------------------------
	-- PUBLIC METHODS: LISTS & ITEMS
	---------------------------------------------
	function Grp:setIndex(index)
		local Props = self.Props
		if index < 0 then index = 0 elseif index > #Props.list then index = #Props.list end
		if index == 0 or Props.list[index].selectable ~= false then
			Props.selectedIndex = index 
			self.lastOffset     = -1
			self:_arrangeList()
		end
	end

	function Grp:getIndex() return Props.selectedIndex end

	function Grp:setList(List, slideDirection)
		local Props = self.Props
		if Props.list == List then return end
		if Props.list == nil then V.error("!!! WIDGET ERROR: List:setList(): Specified list table does not exist."); return end
		-- CURRENT LIST IS EMPTY? NO ANIMATION
		-- if Props.list == self.emptyList then Props.list = List; self:_update(); return end

		-- CHANGE WITH / WITHOUT ANIMATION
		Props.list = List
		if Props.noSlide == true then self:_update()
		else
			local x = slideDirection == "left" and -Props.Shape.w or Props.Shape.w
			transition.to(self[11][1], {time = 250, x = x, onComplete = function() self:_update(slideDirection) end })
			transition.to(self[12]  , {time = 250, alpha = 0})
		end
	end

	function Grp:getCurrList() return self.Props.list end

	function Grp:deleteItem(list, pos, animate)
		local k,v,i
		local Props = self.Props
		if list      == nil then V.error("!!! WIDGET ERROR: List:deleteItem(): Specified list table does not exist."); return end
		if list[pos] == nil then V.error("!!! WIDGET ERROR: List:deleteItem(): Specified item index does not exist."); return end

		-- ANIMATE LIST ITEMS FIRST, THEN DELETE
		if animate == true then
			local Items = self[11][1]
			local item  = pos-self.itemOffset
			for i = Items.numChildren,item+1,-1 do
				transition.to (Items[i], { time = 200, y = Items[i-1].y })
			end
			transition.to (Items[item], { time = 200, alpha = 0.999, onComplete = function() self:deleteItem(Props.list,pos,false) end })
			return
		-- NO ANIMATION, DELETE NOW!
		else
			-- REMOVE TABLE ITEM
			if type(list[pos]) == "table" then
				if list[pos].content ~= nil then 
					list[pos].content:removeSelf()
					list[pos].content = nil
				end
				for k,v in pairs(list[pos]) do list[pos][k] = nil end
			end
			table.remove(list, pos)
			-- CALL LISTENER FUNCTION
			if Props.onItemRemove then
				local EventData =
					{
					Widget = self,
					Props  = Props,
					name   = Props.name,
					List   = list,
					list   = list,
					pos    = pos,
					selectedIndex = Props.selectedIndex,
					} 
				Props.onItemRemove(EventData)
			end
			if Props.list == list then self:_update() end
		end
	end

	---------------------------------------------
	-- PUBLIC METHOD: ENABLE / DISABLE EDIT MODE
	---------------------------------------------
	function Grp:editMode(mode)
		local Props,i  = self.Props
		local Theme    = V.Themes[Props.theme]
		local size     = Theme.widgetFrameSize
		local List     = self[11][1]
		if Props.editMode == mode then return false end
		Props.editMode = mode == true and mode or false

		if mode == true then
			-- SHOW BOTTOM BUTTON
			self[6]:setFrame ( Theme.Frame_List_B2 )
			self[7]:setFrame ( Theme.Frame_List_BR2)
			self[10]:setFrame( Theme.Frame_List_BL2)
			-- BOTTOM CAPTION
			self[14].text      = Props.readyCaption
			V._WrapGadgetText (self[14], Props.Shape.w-size-8, Theme.WidgetFont, Props.fontSize)
			self[14].xScale    = 1
			self[14].yScale    = 1
			self[14].anchorX   = 0
			self[14].anchorY   = .5
			self[14].xScale    = .5
			self[14].yScale    = .5
			self[14].y         = (Props.Shape.h - size*.5) + Theme.WidgetTextYOffset
			self[14].x         = Props.Shape.w*.5 - self[14].width*.25 -- CENTER
			self[14].isVisible = true
		else
			self[6]:setFrame ( Theme.Frame_List_B )
			self[7]:setFrame ( Theme.Frame_List_BR)
			self[10]:setFrame( Theme.Frame_List_BL)
			self[14].isVisible   = false
		end
		-- ADJUST MASK
		self:_adjustMask()
		-- RESIZE SCROLLBAR
		self:_applyScrollbar()
		-- ANIMATE ICONS
		for i = 1, List.numChildren do
			if Props.allowSort == true then
				List[i][4].xScale, List[i][4].yScale = 0.001, 0.001
				transition.to(List[i][4], {time = 200, xScale = 1, yScale = 1})
			end
			if Props.allowDelete == true then
				List[i][5].xScale, List[i][5].yScale = 0.001, 0.001
				transition.to(List[i][5], {time = 200, xScale = Props.iconSize / List[i][5].width, yScale = Props.iconSize / List[i][5].height})
			end
		end
		self.lastOffset = -1
		self:_arrangeList()
	end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy() 
		self.setIndex      = nil
		self.getIndex      = nil
		self.getCurrList   = nil
		self.deleteItem    = nil
		self.editMode      = nil
		self._arrangeList  = nil
		self._adjustMask   = nil
		-- DELETE MASK
		self[11]:setMask (nil)
		self.Mask         = nil
		self.DragItem     = nil
		-- DELETE TIMER
		if self.Timer    ~= nil then timer.cancel(self.Timer); self.Timer = nil end
		-- DELETE LISTS
		local k,v
		self.Props.list         = nil
		self.Props.onSelect     = nil
		self.Props.onIconPress  = nil
		self.Props.onIconPressR = nil
		self.Props.onItemRemove = nil
		self.lastList           = nil
		V._RemoveWidget(self.Props.name) 
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewCustomList(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A WINDOW
----------------------------------------------------------------
V.NewWindow = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewWindow(): Invalid theme specified."); return end
	if V.Widgets[Props.name] ~= nil then V.error("!!! WIDGET ERROR: NewWindow(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_WINDOW
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 3
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 3
	Props.maxW = 9999
	Props.maxH = 9999

	-- WINDOW DRAG VARS
	Grp.fx = 0
	Grp.fy = 0
	Grp.lx = 0
	Grp.ly = 0
	Grp.sx = 0
	Grp.sy = 0

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	Grp.Shadow  = display.newGroup()
	Grp:insert(Grp.Shadow)
	
	Grp.Parts   = display.newGroup()
	Grp.Parts:addEventListener("touch", V._OnWindowTouch )
	Grp:insert(Grp.Parts)

	Grp.Widgets = display.newGroup()
	Grp.Widgets.isContainer = true
	Grp:insert(Grp.Widgets)

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )
	

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local Parts = self.Parts
		local size  = Theme.widgetFrameSize

		while Parts.numChildren > 0 do self.Parts[1]:removeSelf() end

		-- BG
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_BG)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		-- R
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		-- L
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		Tmp.x       = 0
		-- T
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_T)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		Tmp.y       = 0
		-- B
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_B)
		Tmp.anchorX = 0
		Tmp.anchorY = 1
		Parts:insert(Tmp)
		-- BR CORNER
		Tmp = V.newSprite(Theme.Set, Theme.Frame_Win_BR)
		Tmp.anchorX = 1
		Tmp.anchorY = 1
		Parts:insert(Tmp)
		-- TL CORNER
		Tmp = V.newSprite(Theme.Set, Theme.Frame_Win_TL)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		Tmp.x       = 0
		Tmp.y       = 0
		-- TR CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_TR)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Parts:insert(Tmp)
		Tmp.y       = 0
		-- BL CORNER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_BL)
		Tmp.anchorX = 0
		Tmp.anchorY = 1
		Parts:insert(Tmp)
		Tmp.x       = 0
		-- GROUP FOR GRADIENT SHADE
		Tmp = display.newGroup()
		Parts:insert(Tmp)
		-- CLOSE BUTTON?
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_CloseButton)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Tmp:addEventListener ("touch", V._OnWindowClose)
		Parts:insert(Tmp)
		Tmp.y       = 0
		-- RESIZE BUTTON?
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Win_ResizeButton)
		Tmp.anchorX = 1
		Tmp.anchorY = 1
		Tmp:addEventListener ("touch", V._OnWindowResize)
		Parts:insert(Tmp)
		-- ICON 
		Tmp         = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Parts:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WindowCaptionFont,Theme.WindowFontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		Parts:insert(Tmp)
		Tmp        = display.newText(" ",0,0,Theme.WindowCaptionFont,Theme.WindowFontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		Parts:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end

	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local Parts     = self.Parts
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		self.Widgets.y   = Theme.widgetFrameSize
		self.Parts.alpha = Props.windowAlpha or Theme.WindowFrameAlpha

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 1,9 do Parts[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
		end

		-- ADD SHADOW?
		if self.Shadow.numChildren > 0 then self.Shadow[1]:removeSelf() end
		if Props.shadow == true then
			Tmp             = display.newRoundedRect(Theme.WindowShadowOffset,Theme.WindowShadowOffset,w,h, Theme.WindowShadowCornerSize)
			Tmp.anchorX     = 0
			Tmp.anchorY     = 0
			Tmp.strokeWidth = 0
			Tmp:setFillColor  (0,0,0,Theme.WindowShadowAlpha)
			self.Shadow:insert(Tmp)
		end

		-- BG
		Parts[1].x       = size
		Parts[1].y       = size
		Parts[1].xScale  = (w-(size*2)) / Parts[1].width
		Parts[1].yScale  = (h-(size*2)) / Parts[1].height
		-- R
		Parts[2].x       = w
		Parts[2].y       = size
		Parts[2].yScale  = (h-(size*2)) / Parts[2].height
		-- L
		Parts[3].y       = size
		Parts[3].yScale  = (h-(size*2)) / Parts[3].height
		-- T
		Parts[4].x       = size
		Parts[4].xScale  = (w-(size*2)) / Parts[4].width
		-- B
		Parts[5].x       = size
		Parts[5].y       = h
		Parts[5].xScale  = (w-(size*2)) / Parts[5].width
		-- BR CORNER
		Parts[6].x       = w
		Parts[6].y       = h
		-- TR CORNER
		Parts[8].x       = w
		-- BL CORNER
		Parts[9].y       = h
		-- WINDOW SHADE
		if Parts[10].numChildren > 0 then Parts[10][1]:removeSelf() end
		if Props.gradientColor1 ~= nil and Props.gradientColor2 ~= nil then
			Tmp              = display.newRoundedRect(Parts[10],Theme.WindowGradientMargin,Theme.WindowGradientMargin,w-Theme.WindowGradientMargin*2,h-Theme.WindowGradientMargin*2,8)
			Tmp.anchorX      = 0
			Tmp.anchorY      = 0
			Tmp.strokeWidth  = 0
			Tmp:setStrokeColor(0,0,0,0)
			Tmp:setFillColor  ( { type="gradient", color1 = Props.gradientColor1, color2 = Props.gradientColor2, direction = Props.gradientDirection } )
		end
		-- CLOSE BUTTON
		Parts[11].x         = w
		Parts[11].isVisible = Props.closeButton == true and true or false
		-- RESIZE BUTTON
		Parts[12].x         = w
		Parts[12].y         = h
		Parts[12].isVisible = Props.resizable == true and true or false
		-- ICON 
		Parts[13].xScale    = Props.iconSize / Parts[13].width
		Parts[13].yScale    = Props.iconSize / Parts[13].height
		Parts[13].x         = size*.5 + Theme.WindowIconOffsetX
		Parts[13].y         = size*.5 + Theme.WindowCaptionOffsetY
		Parts[13].isVisible = Props.icon > 0 and true or false
		if Props.icon     > 0 then Parts[13]:setFrame( Props.icon ) end
		-- CAPTION
		Parts[15].text   = Props.caption
		Parts[15]:setFillColor(Theme.WindowCaptionColor1[1],Theme.WindowCaptionColor1[2],Theme.WindowCaptionColor1[3],1)  
		V._WrapGadgetText(Parts[15], w-(size*2)-8, Theme.WindowCaptionFont, Props.fontSize)
		Parts[15].xScale  = 1
		Parts[15].yScale  = 1
		Parts[15].anchorX = .5
		Parts[15].anchorY = .5
		Parts[15].xScale  = .5
		Parts[15].yScale  = .5
		Parts[15].x       = w*.5
		Parts[15].y       = size*.5 + Theme.WindowCaptionOffsetY
		Parts[15].isVisible = true
		
		Parts[14].text    = Parts[15].text
		Parts[14]:setFillColor(Theme.WindowCaptionColor2[1],Theme.WindowCaptionColor2[2],Theme.WindowCaptionColor2[3],1)  
		Parts[14].xScale  = 1
		Parts[14].yScale  = 1
		Parts[14].anchorX = .5
		Parts[14].anchorY = .5
		Parts[14].xScale  = .5
		Parts[14].yScale  = .5
		Parts[14].isVisible = true
		-- TEXT ALIGN
		if Props.caption ~= "" then 
			    if Props.textAlign == "left"   then 
			    	local iw = Parts[13].isVisible == true and Props.iconSize + 4 or 0 
			    	Parts[15].x = 4 + iw + Parts[15].width*.25
			elseif Props.textAlign == "right"  then 
			   	local iw = Parts[11].isVisible == true and size + 4 or 0 
				Parts[15].x = w-4 - iw - Parts[15].width*.25 
			end
		end
		Parts[14].x = Parts[15].x + 1
		Parts[14].y = Parts[15].y + 1
		
		-- NO TITLE?
		if Props.noTitle == true then
			self.Widgets.y = 0
			Parts[11].isVisible = false
			Parts[13].isVisible = false
			Parts[14].isVisible = false
			Parts[15].isVisible = false
		end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased()
	end

	---------------------------------------------
	-- PRIVATE METHOD: KEEP INSIDE DRAG AREA
	---------------------------------------------
	function Grp:_keepInsideArea()
		local minX,minY,maxX,maxY
		local Props = self.Props
		local w     = self.Props.Shape.w*Props.scale
		local h     = self.Props.Shape.h*Props.scale
		if Props.dragArea ~= "auto" then
			minX = Props.dragArea[1] -- DRAG AREA X
			minY = Props.dragArea[2] -- DRAG AREA Y
			maxX = Props.dragArea[3] -- DRAG AREA W
			maxY = Props.dragArea[4] -- DRAG AREA H
		else
			minX = 0
			minY = 0
			maxX = V.screenW
			maxY = V.screenH
			--if h > V.screenH then minY = -(h - V.screenH); maxY = h + V.Abs(minY) end
			--if w > V.screenW then minX = -(w - V.screenW); maxX = w + V.Abs(minX) end
			if h > V.screenH then minY = -(h - V.screenH) - display.screenOriginY; maxY = h + V.Abs(minY) + display.screenOriginY end
			if w > V.screenW then minX = -(w - V.screenW) - display.screenOriginX; maxX = w + V.Abs(minX) + display.screenOriginX end
		end
		
		if self.x < minX then self.x = minX elseif self.x + w > minX+maxX then self.x = (minX+maxX) - w end
		if self.y < minY then self.y = minY elseif self.y + h > minY+maxY then self.y = (minY+maxY) - h end
	end
	
	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy()
		-- IS MODAL WINDOW?
		if self.Props.modal == true then
			V.numModals = V.numModals - 1
			if V.numModals == 0 then V.Fader:removeSelf(); V.Fader = nil end
		end
		
		while self.Widgets.numChildren > 0 do self.Widgets[1]:destroy() end
		self.Parts:removeEventListener("touch", V._OnWindowTouch )
		self.Widgets:removeSelf(); self.Widgets = nil
		self.Shadow:removeSelf (); self.Shadow  = nil
		self.Parts:removeSelf  (); self.Parts   = nil
		if self.DragTimer ~= nil then timer.cancel(self.DragTimer); self.DragTimer.Win = nil; self.DragTimer = nil end
		V._RemoveWidget(self.Props.name) 
		collectgarbage("collect")
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	-- IS MODAL WINDOW?
	if Props.modal  == true then
		if V.Fader == nil then
			V.Fader       = display.newGroup()
			V.Fader.x     = display.screenOriginX
			V.Fader.y     = display.screenOriginY
			V.Fader.alpha = 0
			Tmp         = display.newRect(V.Fader,0,0,V.physicalW,V.physicalH)
			Tmp.anchorX = 0
			Tmp.anchorY = 0
			Tmp:setFillColor (0,0,0,.5)
			Tmp.strokeWidth = 0
			V.Fader:addEventListener("touch", function() V._RemoveInput(); return true end)
		end
		transition.to (V.Fader, {time = 750, alpha = 1.0})
		V.numModals = V.numModals + 1
	end
	-- PLACE FADER ON TOP OF EVERYTHING, BUT BELOW MODAL WINDOWS
	if V.Fader then display.getCurrentStage():insert(display.getCurrentStage().numChildren-V.numModals, V.Fader) end

	V.print("--> Widgets.NewWindow(): Created new window '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A CONTAINER
----------------------------------------------------------------
V.NewContainer = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewContainer(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewContainer(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	-- BORDER WIDGET
	local Border = V.NewBorder(
		{
		parentGroup       = Props.parentGroup,
		theme             = Props.theme,
		group             = Props.group,
		border            = Props.groupBorder,
		} )

	Props.collapsed   = false
	Props.border      = Props.titleBorder
	
	-- LABEL WIDGET
	local Label       = V.NewLabel(Props)
	Label.isContainer = true
	Label.borderName  = Border.Props.name
	Label.iconOpen    = Props.icon
	Label.iconClosed  = Props.iconClosed or Props.icon
	Label.oGroup      = Props.group

	function Label:collapse(state)
		local i, Widget, Shape
		local Parent    = self.parent
		local Props     = self.Props
		if state == nil then state = not Props.collapsed end
		if state ~= Props.collapsed then
			-- COLLAPSE STATE
			Props.collapsed = state

			-- CHANGE GROUP NAME WHILE COLLAPSED
			if Props.collapsed == true then 
				self.Props.group = "GRP_"..self.Props.name 
				self:set("icon", self.iconClosed)
			else 
				self.Props.group = self.oGroup 
				self:set("icon", self.iconOpen)
			end
			V.GetHandle(self.borderName).Props.group = self.Props.group

			-- INCLUDE / EXCLUDE CONTAINER CHILDS FROM LAYOUT
			for i = 1,Parent.numChildren do
				Widget = Parent[i]
				if Widget.Props and Widget.Props.group == self.oGroup and Widget ~= self and Widget.Props.name ~= self.borderName and Widget.Props.name ~= self.iconName then
					if Props.collapsed == true then
						Widget.oInclude              = Widget.Props.includeInLayout
						Widget.Props.includeInLayout = false
						Widget.isVisible             = false
					else
						Widget.Props.includeInLayout = Widget.oInclude
						Widget.isVisible             = true
					end
				end
			end
			-- INSIDE WINDOW? -ARRANGE!
			if self.parent.parent and self.parent.parent.typ == V.TYPE_WINDOW then self.parent.parent:layout() end
		end

		return true
	end
	function Label:tap(event) self:collapse() end
	Label:addEventListener("tap", Label)
	
	return Label
end


----------------------------------------------------------------
-- PUBLIC: CREATE A LABEL
----------------------------------------------------------------
V.NewLabel = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewLabel(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewLabel(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_LABEL
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 1
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	-- Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)
		-- ICON 
		Tmp = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.WidgetTextColor

		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- FIT BUTTON WIDTH TO TEXT?
		if Props.width == "auto" then
			self[2].xScale  = 1
			self[2].yScale  = 1
			self[2].text    = Props.caption 
			Props.width     = (V.Round(self[2].width * .5) + size + 4) * Props.scale
			V._CheckProps(self)
			Props.width     = "auto"
			w               = Props.Shape.w
		end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- CAPTION
		--self[2].size   = Props.fontSize*2
		self[2].text   = Props.caption
		self[2]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		V._WrapGadgetText(self[2], w-8, Theme.WidgetFont, Props.fontSize)
		self[2].xScale  = 1
		self[2].yScale  = 1
		self[2].anchorX = 0
		self[2].anchorY = .5
		self[2].xScale  = .5
		self[2].yScale  = .5
		self[2].y       = size*.5 + Theme.WidgetTextYOffset
		self[2].x       = Theme.MarginX; if Props.textAlign == "right" then self[2].x = w - self[2].width*.5 - Theme.MarginX elseif Props.textAlign == "center" then self[2].x = w*.5 -  self[2].width*.25 end
		-- ICON 
		local halfW = (self[3].width*self[3].xScale)*.5
		self[3]:setFrame( Props.icon > 0 and Props.icon or 1 )
		self[3].isVisible    = Props.icon > 0 and true or false
		self[3].xScale  = Props.iconSize / self[3].width
		self[3].yScale  = Props.iconSize / self[3].height
		self[3].xScale = Props.flipIconX == true and -V.Abs(self[3].xScale) or V.Abs(self[3].xScale)
		self[3].yScale = Props.flipIconY == true and -V.Abs(self[3].yScale) or V.Abs(self[3].yScale)
		self[3].x       = Theme.MarginX + halfW; if Props.textAlign == "right" then self[3].x = w elseif Props.textAlign == "center" then self[3].x = w*.5 end
		self[3].y       = size*.5

		if Props.icon > 0 and Props.caption ~= "" then 
			    if Props.textAlign == "left"   then self[2].x = self[3].x + halfW + 4 
			elseif Props.textAlign == "center" then self[2].x = self[2].x + halfW + 2; self[3].x = self[2].x - halfW - 4 
			elseif Props.textAlign == "right"  then self[3].x = w - halfW - Theme.MarginX; self[2].x = self[2].x - halfW*2 - 8 end

			if Props.iconAlign == "left"  then
			    	self[3].x = Theme.MarginX + halfW; 
			    	if Props.textAlign == "center" then self[2].x = self[2].x - halfW - 2 end
			    	if Props.textAlign == "right"  then self[2].x = self[2].x + halfW*2 + 8 end
			elseif Props.iconAlign == "right" then 
				self[3].x = w - halfW - Theme.MarginX 
				if Props.textAlign == "left" then self[2].x = self[2].x - halfW*2 - 4 end
			end
		end
		
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy()
		local Props = self.Props
		-- IS CONTAINER?
		if self.isContainer then
			self:removeEventListener("tap", self)
			local Border = V.GetHandle(self.borderName)
			if Border then Border:destroy() end
		end
		V._RemoveWidget(Props.name) 
	end

	---------------------------------------------
	-- PUBLIC METHOD: GET / SET TEXT
	---------------------------------------------
	function Grp:getText() return self.Props.caption end
	function Grp:setText(txt) self.Props.caption = txt; self:_update() end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewLabel(): Created new label '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE AN INPUT FIELD
----------------------------------------------------------------
V.NewInput = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewInput(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewInput(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_INPUT
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Round(V.Themes[Props.theme].widgetFrameSize * 2.1)
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()

		
		if _G.NoEditShow == true then return end

		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Input_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- MIDDLE
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Input_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = size
		Tmp.y       = 0
		self:insert(Tmp)
		-- RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Input_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- CAPTION
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()


		local i
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local textColor = Props.textColor ~= nil and Props.textColor or Theme.InputTextColor
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h

		--print("Bobby")

		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 2, 4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
		end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- MIDDLE
		self[3].xScale = (w-(size*2)) / self[3].width
		-- RIGHT CAP
		self[4].x      = w
		-- CAPTION
		local char,char2,txt,cnt2
		local cnt = V.utf8len(Props.caption)
		-- CHECK FOR ALLOWED CHARS?
		if Props.allowedChars ~= nil and Props.allowedChars ~= "" then
			txt = ""
			cnt2= V.utf8len(Props.allowedChars)
			local allowed
			if cnt2 > 0 and V.utf8len(Props.caption) > 0 then
				for char in string.gfind(Props.caption, "([%z\1-\127\194-\244][\128-\191]*)") do
					if V.Keyboard ~= nil and char == V.Keyboard.Props.cursor then
						txt = txt..char
					else
						for char2 in string.gfind(Props.allowedChars, "([%z\1-\127\194-\244][\128-\191]*)") do
							if char == char2 then txt = txt..char end
						end
					end
				end
			end
			Props.caption = txt
		end
		-- SECURE?
		if Props.isSecure == true then
			txt = ""
			if V.utf8len(Props.caption) > 0 then
				for char in string.gfind(Props.caption, "([%z\1-\127\194-\244][\128-\191]*)") do
					if V.Keyboard ~= nil and char == V.Keyboard.Props.cursor then
						 txt = txt..V.Keyboard.Props.cursor
					else txt = txt.."*" end
				end
			end
			self[5].text = txt
		else 
			self[5].text = Props.caption 
		end
		
		self[5]:setFillColor(textColor[1],textColor[2],textColor[3],1)  
		V._WrapGadgetText(self[5], w-size-4, Theme.WidgetFont, Props.fontSize)
		self[5].xScale  = 1
		self[5].yScale  = 1
		self[5].anchorX = 0
		self[5].anchorY = .5
		self[5].xScale  = .5
		self[5].yScale  = .5
		self[5].y       = size*.5
		self[5].x       = Theme.InputMarginX
		
		-- IS CURRENTLY IN INPUT MODE? UPDATE NATIVE TEXT BOX THEN AS WELL
		if V.Input ~= nil and V.Input.MyObject == self then V.Input.Txt.text = Props.caption end
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased()
	end

	---------------------------------------------
	-- PUBLIC METHOD: GET / SET TEXT
	---------------------------------------------
	function Grp:getText()
		local char
		local Props = self.Props
		local txt   = ""
		local cnt   = V.utf8len(Props.caption)
		if cnt > 0 then
			for char in string.gfind(Props.caption, "([%z\1-\127\194-\244][\128-\191]*)") do
				if V.Keyboard == nil or (V.Keyboard ~= nil and char ~= V.Keyboard.Props.cursor) then
					 txt = txt..char
				end
			end
		end
		return txt
	end
	function Grp:setText(txt) self.Props.caption = txt; self:_update() end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewInput(): Created new input field '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: ADD AN IMAGE OBJECT
----------------------------------------------------------------
V.NewImage = function (ImgObj, Props)

	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewImage(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	-- APPLY DEFAULT THEME?
	if Props.theme == nil then
		local k,v
		for k,v in pairs(V.Themes) do Props.theme = k; break end
		if Props.theme == nil then V.error("!!! WIDGET ERROR: NewImage(): No themes loaded. Load at least one theme."); return end
	end
	
	Props.ImgObj = ImgObj

	local Grp, Tmp

	V.widgetCount = V.widgetCount + 1
	Grp           = display.newGroup()
	Grp.typ       = V.TYPE_IMAGE
	Grp.Props     = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW    = 16
	Props.minH    = 16
	Props.maxW    = 9999
	Props.maxH    = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)

		-- NO IMAGE?
		if Props.ImgObj == nil then 
			V.error("!!! WIDGET ERROR: NewImage(): Invalid image object specified (nil).")
		else
			-- REMOVE IMAGE FROM GROUP
			display.getCurrentStage():insert(Props.ImgObj)

			-- PLACE IMAGE IN GROUP
			self:insert(Props.ImgObj)
		end

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i
		local Props    = self.Props
		local Theme    = V.Themes [Props.theme]
		local size     = Theme.widgetFrameSize
		local w        = Props.Shape.w
		local h        = Props.Shape.h
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale    = Props.scale
		self.yScale    = Props.scale

		-- COLORIZE PARTS?
		if Props.color ~= nil and self[2] and self[2].setFillColor then self[2]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- IMAGE
		local Img = Props.ImgObj
		if Img then
			Img.anchorX = 0
			Img.anchorY = 0
			Img.x       = 0
			Img.y       = 0
			Img.xScale  = (Props.Shape.w / Img.width )
			Img.yScale  = (Props.Shape.h / Img.height)
			if Props.flipX == true then Img.xScale = -(Props.Shape.w / Img.width ); Img.x = Props.Shape.w end
			if Props.flipY == true then Img.yScale = -(Props.Shape.h / Img.height); Img.y = Props.Shape.h end
		end
	end

	---------------------------------------------
	-- METHODS: CHANGE IMAGE / GET IMAGE HANDLE
	---------------------------------------------
	function Grp:setImage(ImgObj, keepPrevious)
		if keepPrevious ~= true then 
			-- IS SNAPSHOT? REMOVE CHILDREN
			if self.Props.ImgObj.group and self.Props.ImgObj.group.numChildren then
				local i; for i = self.Props.ImgObj.group.numChildren,1,-1 do self.Props.ImgObj.group[i]:removeSelf() end
			end
			self.Props.ImgObj:removeSelf() 
			self.Props.ImgObj = nil
			collectgarbage("collect")
			collectgarbage("collect")
			collectgarbage("collect")
			collectgarbage("collect")
		else
			display.getCurrentStage():insert(self.Props.ImgObj)
		end
		self.Props.ImgObj = ImgObj
		self:_create()
	end
	
	function Grp:getImage() return self.Props.ImgObj end

	---------------------------------------------
	-- PRIVATE METHODS: PRESSED / DRAGGED / RELEASED
	---------------------------------------------
	function Grp:_drawPressed ( event ) end
	function Grp:_drawDragged ( event ) end
	function Grp:_drawReleased( event ) end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy(keepImage) 
		if keepImage ~= true then 
			-- IS SNAPSHOT? REMOVE CHILDREN
			if self.Props.ImgObj.group and self.Props.ImgObj.group.numChildren then
				local i; for i = self.Props.ImgObj.group.numChildren,1,-1 do self.Props.ImgObj.group[i]:removeSelf() end
			end
			self.Props.ImgObj:removeSelf() 
			self.Props.ImgObj = nil
			collectgarbage("collect")
			collectgarbage("collect")
			collectgarbage("collect")
			collectgarbage("collect")
		else
			display.getCurrentStage():insert(self.Props.ImgObj)
		end
		self.Props.ImgObj = nil
		V._RemoveWidget(self.Props.name) 
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewImage(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE AN ICON BAR
----------------------------------------------------------------
V.NewIconBar = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewIconBar(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewIconBar(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_ICONBAR
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize
	Props.minH = V.Themes[Props.theme].widgetFrameSize
	Props.maxW = 9999
	Props.maxH = 9999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.Props.selectedIcon = 1
	
	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp, Icon, i
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		self.numIcons = #Props.icons

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- [1] BACKGROUND & BORDER
		Tmp = display.newGroup(); self:insert(Tmp)
		-- [2] MARKER
		Tmp = display.newGroup(); self:insert(Tmp)
		-- [3] ICONS
		Tmp = display.newGroup(); self:insert(Tmp)
		-- [4] TEXTS
		Tmp = display.newGroup(); self:insert(Tmp)
		-- [5] SHINE
		Tmp = display.newGroup(); self:insert(Tmp)

		Props.lastIcons = nil
		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
		local i, Tmp, Tmp2, Icon, Text
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor or Theme.ButtonTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- ICON TABLE CHANGED?
		if Props.lastIcons ~= Props.icons then
			-- CREATE ICONS
			for i = self[3].numChildren,1,-1 do self[3][i]:removeSelf() end
			for i = 1, #Props.icons do
				Icon = Props.icons[i]
				if Icon.image ~= nil then
					Tmp = display.newImageRect(Icon.image, Icon.baseDir, Props.iconSize, Props.iconSize) 
				else
					Tmp = V.newSprite(Theme.SetIcons)
				end
				Tmp.anchorX = .5
				Tmp.anchorY = .5
				self[3]:insert(Tmp)
			end
			-- CREATE TEXTS
			for i = self[4].numChildren,1,-1 do self[4][i]:removeSelf() end
			for i = 1, #Props.icons do
				Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
				Tmp.xScale = .5
				Tmp.yScale = .5
				self[4]:insert(Tmp)
			end
		end
		Props.lastIcons = Props.icons

		if Props.iconSize == nil then Props.iconSize = w > h and h-4 or w-4 end

		-- COLORIZE PARTS?
		-- if Props.color ~= nil then self:getChildAt(2):setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- ARRANGE ICONS & TEXTS
		local spacing = w > h and (w-8) / #Props.icons or (h-8) / #Props.icons
		local size    = Props.iconSize
		local pos     = 0
		for i = 1, #Props.icons do
			Icon = self[3][i]
			Text = self[4][i]
			-- SIZE
			Icon.scaleX = size / Icon.width ; if Props.icons[i].flipX == true then Icon.scaleX = -Icon.scaleX end
			Icon.scaleY = size / Icon.height; if Props.icons[i].flipY == true then Icon.scaleY = -Icon.scaleY end
			Icon.xScale = Icon.scaleX
			Icon.yScale = Icon.scaleY
			-- ICON
			if (Props.icons[i].icon and Props.icons[i].icon > 0) or Props.icons[i].image ~= nil then
				if Props.icons[i].image == nil then Icon:setFrame  ( Props.icons[i].icon ) end
				Icon.isVisible = true
			else Icon.isVisible = false end
			-- TEXT
			Text.text = (Props.icons[i] ~= nil and Props.icons[i] ~= "" ) and Props.icons[i].text or ""
			V._WrapGadgetText(Text, spacing, Theme.WidgetFont, Props.fontSize)
			Text:setFillColor(textColor[1],textColor[2],textColor[3],1)
			Text.xScale  = 1
			Text.yScale  = 1
			Text.anchorX = .5
			Text.anchorY = .5
			Text.xScale  = .5
			Text.yScale  = .5
			-- DISABLED?
			if Props.icons[i].disabled == true then
				Icon:setFillColor(.39,.39,.39, .5)
				Text.alpha = .5
			else 
				Icon:setFillColor(1,1,1, 1) 
				Text.alpha = 1
			end
			-- HORIZONTAL BAR?
			if w > h then 
				Icon.x = pos
				Icon.y = 0
					if Props.iconAlign == "top"    then Icon.y = -h*.5 + size*.5 + 4 
				    elseif Props.iconAlign == "bottom" then Icon.y =  h*.5 - size*.5 - 4 end
				Text.rotation = 0
				Text.x = pos
				Text.y = 0
				if Props.textAlign == "top"    then Text.y = -h*.5 + Text.height*.25 + 4
			    elseif Props.textAlign == "bottom" then Text.y =  h*.5 - Text.height*.25 - 4 end
			-- VERTICAL BAR
			else 
				Icon.x = 0
				Icon.y = pos 
					if Props.iconAlign == "left"  then Icon.x = -w*.5 + size*.5 + 4
				    elseif Props.iconAlign == "right" then Icon.x =  w*.5 - size*.5 - 4 end
				Text.rotation = 270
				Text.x = 0
				Text.y = pos
				if Props.textAlign == "left"  then Text.x = -w*.5 + Text.height*.25 + 4
			    elseif Props.textAlign == "right" then Text.x =  w*.5 - Text.height*.25 - 4 end
			end

			pos = pos + spacing
		end

		-- HORIZONTAL BAR?
		if w > h then
			self[3].x = spacing*.5 + 4
			self[3].y = h * .5
			self[4].x = spacing*.5 + 4
			self[4].y = h * .5
		-- VERTICAL BAR?
		else
			self[3].x = w * .5
			self[3].y = spacing*.5 + 4
			self[4].x = w * .5
			self[4].y = spacing*.5 + 4
		end

		-- MARKER
		if Props.marker == nil then Props.marker = {8,1, 1,0,0,.19,  .72,.72,.72,.58} end
		self[2].x = self[3].x
		self[2].y = self[3].y
		if self[2][1] then self[2][1]:removeSelf() end
		if w > h then Tmp = display.newRoundedRect(4,4,spacing,h-8,Props.marker[1])
		         else Tmp = display.newRoundedRect(4,4,w-8,spacing,Props.marker[1]) end
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp:setFillColor  (Props.marker[3],Props.marker[4],Props.marker[5],Props.marker[6])
		Tmp:setStrokeColor(Props.marker[7],Props.marker[8],Props.marker[9],Props.marker[10])
		Tmp.strokeWidth  = Props.marker[2]
		Tmp.x = self[3][1].x
		Tmp.y = self[3][1].y
		self[2]:insert(Tmp)
		self[2].isVisible = false
		
		-- SET MARKER
		Grp:setMarker(Props.selectedIcon)
		
		-- TOP SHINE
		if self[5][1] then self[5][1]:removeSelf() end
		if #Props.border > 0 then
			if w > h then Tmp = display.newRoundedRect(4,4,w-8,16,4)
			         else Tmp = display.newRoundedRect(4,4,16,h-8,4) end
			Tmp.anchorX     = 0
			Tmp.anchorY     = 0
			Tmp.strokeWidth = 0
			Tmp:setFillColor (1,1,1,Props.glossy ~= nil and Props.glossy or .125)
			self[5]:insert(Tmp)
		end
		
		-- BUTTON CURRENTLY PRESSED OR NORMAL STATE?
		if self.isFocus and self.inside then self:_drawPressed({}) else self:_drawReleased({}) end

	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
	end
	
	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		if EventData.lx == nil or EventData.ly == nil then return end

		-- WHAT ICON PRESSED?
		Props.selectedIcon = 0
		local lx  = EventData.lx
		local ly  = EventData.ly
		local w   = Props.Shape.w
		local h   = Props.Shape.h
		local num = 0
		if w > h then num = V.Ceil( lx / (w / #Props.icons) )
		         else num = V.Ceil( ly / (h / #Props.icons) ) end
		-- ICON PRESS EFFECT
		if num > 0 and num <= #Props.icons and Props.icons[num].disabled ~= true then
			Props.selectedIcon   = num
			self[3][num].xScale = self[3][num].scaleX * 0.85
			self[3][num].yScale = self[3][num].scaleY * 0.85
			self:setMarker(num)
		end

		EventData.selectedIcon = Props.selectedIcon
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		-- UNDO ICON PRESS EFFECT
		for i = 1, self[3].numChildren do
			local Icon     = self[3][i]
			Icon.xScale    = Icon.scaleX
			Icon.yScale    = Icon.scaleY
		end		

		EventData.selectedIcon = Props.selectedIcon
	end

	---------------------------------------------
	-- PUBLIC METHOD: SET MARKER
	---------------------------------------------
	function Grp:setMarker(pos, animated)
		local Props      = self.Props; if Props == nil then return end
		local Theme      = V.Themes [Props.theme]
		local textColor1 = Props.textColor       or Theme.ButtonTextColor
		local textColor2 = Props.textColorActive or Theme.ButtonTextColor

		if pos == nil or (pos < 0 or pos > #Props.icons) then pos = 0 end

		-- RESTORE TEXT COLORS
		for i = 1,self[4].numChildren do
			if i == pos then self[4][i]:setFillColor( textColor2[1],textColor2[2],textColor2[3],1 )
			            else self[4][i]:setFillColor( textColor1[1],textColor1[2],textColor1[3],1 )
			end
		end

		-- NO SELECTION
		if pos == 0 then self[2].isVisible = false; return end

		self[2].isVisible  = true
		local x,y
		if Props.Shape.w > Props.Shape.h then
			x = self[3][pos].x
			y = 0
			if animated == true then transition.to(self[2][1], {time = 250, x = x, y = y, transition = easing.outBack})
			else self[2][1].x = x; self[2][1].y = y end
		else
			x = 0
			y = self[3][pos].y
			if animated == true then transition.to(self[2][1], {time = 250, x = x, y = y, transition = easing.outBack})
			else self[2][1].x = x; self[2][1].y = y end
		end

		Props.selectedIcon = pos
	end

	---------------------------------------------
	-- PUBLIC METHOD: UPDATE AN ICON
	---------------------------------------------
	function Grp:updateIcon(pos, Values)
		local Props = self.Props; if Props == nil then return end
		if pos < 1 or pos > #Props.icons then V.error("!!! WIDGET ERROR: updateIcon() - Invalid icon number specified."); return end
		-- UPDATE ICON
		Props.icons[pos].image        = Values.image
		Props.icons[pos].imageFilter  = Values.imageFilter
		Props.icons[pos].imageOptions = Values.imageOptions
		Props.icons[pos].baseDir      = Values.baseDir
		Props.icons[pos].icon         = Values.icon
		Props.icons[pos].disabled     = Values.disabled
		Props.icons[pos].flipX        = Values.flipX
		Props.icons[pos].flipY        = Values.flipY
		Props.icons[pos].text         = Values.text
		Props.lastIcons = nil
		self:_update()
		collectgarbage("collect")
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewIconBar(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SQUARE BUTTON
----------------------------------------------------------------
V.NewCalendar = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewCalendar(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewCalendar(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_CALENDAR
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 7
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 7.5
	Props.maxW = Props.minW
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	Grp.date     = os.date( "*t" )
	Grp.dayInfos = {}

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Grp, Tmp, i, c, r, lineStyleHi, lineStyleLo, fillStyle
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		self.cols  = 7
		self.rows  = 6
		self.gridW = self.cols * size
		self.gridH = self.rows * size + size*1.5 

		Props.highlightWeekend = Props.highlightWeekend or false
		Props.startMonday      = Props.startMonday or false;
		Props.monthNames       = Props.monthNames or {"JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"}
		Props.dayNames         = Props.dayNames   or {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- [1] BACKGROUND & BORDER
		Tmp   = display.newGroup(); self:insert(Tmp)
		-- [2] TITLE BAR LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.yScale  = (size*1.5 / Tmp.height)
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- [3] TITLE BAR MIDDLE
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.xScale  = (self.gridW-(size*2)) / Tmp.width
		Tmp.yScale  = size*1.5 / Tmp.height
		Tmp.x       = size
		Tmp.y       = 0
		self:insert(Tmp)
		-- [4] TITLE BAR RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		Tmp.yScale  = size*1.5 / Tmp.height
		Tmp.x       = self.gridW
		Tmp.y       = 0
		self:insert(Tmp)
		-- [5] CAPTION MONTH
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		self:insert(Tmp)
		-- [6] CAPTION YEAR
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		self:insert(Tmp)
		-- [7] BUTTON YEAR PREVIOUS
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_ButtonYear)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.x       = size*.5
		Tmp.y       = size*.5
		self:insert(Tmp)
		-- [8] BUTTON MONTH PREVIOUS
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_ButtonMonth)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.x       = size*1.5
		Tmp.y       = size*.5
		self:insert(Tmp)
		-- [9] BUTTON MONTH NEXT
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_ButtonMonth)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.x       = self.gridW-size*1.5
		Tmp.y       = size*.5
		Tmp.xScale  = -1
		self:insert(Tmp)
		-- [10] BUTTON YEAR NEXT
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_ButtonYear)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.x       = self.gridW-size*.5
		Tmp.y       = size*.5
		Tmp.xScale  = -1
		self:insert(Tmp)
		-- [11] GROUP TO HOLD DAY NAMES BAR
		Grp   = display.newGroup()
		Grp.y = size
		self:insert(Grp)
		for i = 1,7 do
			Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
			Grp:insert(Tmp)
		end
		-- [12] GROUP TO HOLD DAY BG TILES
		Grp = display.newGroup()
		Grp.y = size*1.5
		self:insert(Grp)
		-- [12][n] TILES
		for r = 0, self.rows-1 do
			for c = 0, self.cols-1 do
				Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_Item)
				Tmp.anchorX = .5
				Tmp.anchorY = .5
				Tmp.x       = size*.5 + c*size
				Tmp.y       = size*.5 + r*size
				Grp:insert(Tmp)
			end
		end
		-- [13] GROUP TO HOLD DAY NUMBERS
		Grp   = display.newGroup()
		Grp.y = size*1.5
		self:insert(Grp)
		-- [13][n] TILES
		for r = 0, self.rows-1 do
			for c = 0, self.cols-1 do
				Tmp = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
				Grp:insert(Tmp)
			end
		end
		-- [14] GROUP TO HOLD DAY INFOS
		Grp   = display.newGroup()
		Grp.y = size*1.5
		self:insert(Grp)
		-- [14][n] ICONS
		for r = 0, self.rows-1 do
			for c = 0, self.cols-1 do
				Tmp         = V.newSprite(Theme.SetIcons)
				Tmp.anchorX = 0
				Tmp.anchorY = 0
				Tmp.xScale  = (size*.5) / Tmp.width
				Tmp.yScale  = (size*.5) / Tmp.height
				Tmp.x       = size*.5 + c*size - 2
				Tmp.y       = size*.5 + r*size - 2
				Grp:insert(Tmp)
			end
		end
		-- [15] DAY MARKER
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_Calendar_Marker)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.xScale  = 1.25
		Tmp.yScale  = 1.25
		Tmp:setFillColor(0,1,0, 1)
		self:insert(Tmp)
		
		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i, j, c, r, Tmp
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor or Theme.CalendarTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		Props.Shape.w = self.gridW
		Props.Shape.h = self.gridH

		-- COLORIZE PARTS?
		--if Props.color ~= nil then self:getChildAt(2):setColorTransform(Props.color[1],Props.color[2],Props.color[3]) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- NOT DATE SET? USE TODAY!
		Props.day   = Props.day   or tonumber(self.date.day)
		Props.month = Props.month or self.date.month
		Props.year  = Props.year  or self.date.year

		-- GET FIRST WEEKDAY & NUMBER OF DAYS OF CURR. MONTH
		if Props.month < 1 then Props.month = 1 elseif Props.month > 12      then Props.month = 12 end
		local firstDay    = self:_getFirstDay(Props.month,Props.year)
		local numDays     = self:_getNumDays (Props.month,Props.year)
		if Props.day   < 1 then Props.day   = 1 elseif Props.day   > numDays then Props.day   = numDays end

		-- MONTH & YEAR TEXT
		Tmp = self[5]
		Tmp.text    = Props.monthNames[Props.month].." "..Props.year
		Tmp.xScale  = 1
		Tmp.yScale  = 1
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.xScale  = .5
		Tmp.yScale  = .5
		Tmp.x       = self.gridW*.5
		Tmp.y       = size*.5 + Theme.WidgetTextYOffset
		if Props.monthYearColor then
			Tmp:setFillColor(Props.monthYearColor[1],Props.monthYearColor[2],Props.monthYearColor[3],Props.monthYearColor[4] or 1)
		else    Tmp:setFillColor(textColor[1],textColor[2],textColor[3],textColor[4] or 1 ) end
		
		-- DAY NAMES
		Tmp = self[11]
		j   = Props.startMonday == true and 2 or 1
		for i = 1,Tmp.numChildren do
			Tmp[i].text    = Props.dayNames[j]
			j = j + 1; if j > #Props.dayNames then j = 1 end
			Tmp[i].xScale  = 1
			Tmp[i].yScale  = 1
			Tmp[i].anchorX = .5
			Tmp[i].anchorY = .5
			Tmp[i].xScale  = .4
			Tmp[i].yScale  = .4
			Tmp[i].x       = size*.5 + (i-1)*size
			Tmp[i].y       = Tmp[i].height*.4 - 4
			if Props.dayNamesColor ~= nil then
				Tmp[i]:setFillColor( Props.dayNamesColor[1],Props.dayNamesColor[2],Props.dayNamesColor[3],Props.dayNamesColor[4] or 1 )
			else    Tmp[i]:setFillColor( textColor[1],textColor[2],textColor[3],textColor[4] or 1 ) end
		end

		-- GET NUMBER OF DAYS OF PREVIOUS MONTH
		local numDaysPrev
		if Props.month == 1 then
			 numDaysPrev = self:_getNumDays(12,Props.year-1)
		else numDaysPrev = self:_getNumDays(Props.month-1,Props.year) end

		-- GENERATE DAYS -START WITH PREVIOUS MONTH
		local year  = Props.year
		local day   = (1-firstDay); if Props.startMonday == true then day = firstDay == 0 and day-6 or day+1 end
		local month = Props.month-1; if month == 0 then month = 12; year = year - 1 end
		local i     = 1
		local dayInfo
		for r = 1, self.rows do
			for c = 1, self.cols do
				if day == 1 then
					-- SWITCH TO CURRENT MONTH?
					if (Props.month == 1 and month == 12) or (Props.month > 1 and month == Props.month-1)  then 
						month = Props.month 
						year  = Props.year
					-- SWITCH TO NEXT MONTH?
					elseif month == Props.month then
						month = Props.month + 1
						if month > 12 then month = 1; year = year + 1 end
					end
				end
				-- GET DAY INFO
				dayInfo = self.dayInfos[ os.time{year=year, month=month, day=(day > 0 and day or numDaysPrev+day)} ]
				-- UPDATE BG
				Tmp = self[12][i]
				if month == Props.month then 
						if dayInfo and dayInfo.bgColor ~= nil then Tmp:setFillColor(dayInfo.bgColor[1],dayInfo.bgColor[2],dayInfo.bgColor[3],1) else Tmp:setFillColor(1,1,1,1) end
					else 
						if dayInfo and dayInfo.bgColor ~= nil then Tmp:setFillColor(dayInfo.bgColor[1]*.7,dayInfo.bgColor[2]*.7,dayInfo.bgColor[3]*.7,1) else Tmp:setFillColor(.7,.7,.7,1) end
				end
				Tmp.xScale = .1
				Tmp.yScale = .1
				transition.to (Tmp, {time = 150, xScale = 1, yScale = 1})
				-- UPDATE TEXT
				Tmp = self[13][i]
				Tmp.text = day > 0 and day or numDaysPrev+day
				Tmp.xScale  = 1
				Tmp.yScale  = 1
				Tmp.anchorX = .5
				Tmp.anchorY = .5
				Tmp.xScale  = .5
				Tmp.yScale  = .5
				Tmp.x       = ((c-1)*size + Tmp.width *.25 + 4)
				Tmp.y       = ((r-1)*size + Tmp.height*.25 + 4)
				if Props.highlightWeekend == true and ( (Props.startMonday == true and (c == 6 or c == 7)) or ( Props.startMonday == false and (c == 1 or c == 7)) ) then
					if dayInfo and dayInfo.textColor ~= nil then Tmp:setFillColor( 1,dayInfo.textColor[2],dayInfo.textColor[3],dayInfo.textColor[4] or 1 ) else Tmp:setFillColor( 1,textColor[2],textColor[3],textColor[4] or 1 ) end
				else 
					if dayInfo and dayInfo.textColor ~= nil then Tmp:setFillColor( dayInfo.textColor[1],dayInfo.textColor[2],dayInfo.textColor[3],dayInfo.textColor[4] or 1 ) else Tmp:setFillColor( textColor[1],textColor[2],textColor[3],textColor[4] or 1 )  end
				end
				Tmp.myMonth = month
				Tmp.alpha   = month == Props.month and 1 or .75
				Tmp.xScale  = .1
				Tmp.yScale  = .1
				transition.to (Tmp, {time = 150, xScale = .5, yScale = .5})
				-- UPDATE ICON
				Tmp = self[14][i]
				if dayInfo ~= nil and dayInfo.icon then 
					Tmp:setFrame( dayInfo.icon )
					Tmp.isVisible = true
					Tmp.alpha     = (month == Props.month and 1 or .5)
				else
					Tmp.isVisible = false
				end
				-- SET MARKER?
				if month == Props.month and day == Props.day then
					Tmp = self[15]
					Tmp.x = (size*.5 + (c-1)*size)
					Tmp.y = (size*.5 + (r-1)*size + size*1.5)
					if Props.markerColor then Tmp:setFillColor(Props.markerColor[1],Props.markerColor[2],Props.markerColor[3],Props.markerColor[4] or 1) end
				end

				day = day + 1; if day > numDays then day = 1 end
				i = i + 1
			end
		end

	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize
		local lx,ly = EventData.lx, EventData.ly

		Props.buttonPressed = ""

		-- TITLE BAR TAPPED?
		if ly <= size then
			if lx < size then 
				Props.buttonPressed = "Y-"
				self[7].xScale, self[7].yScale = .75, .75
			elseif lx > size and lx < size*2 then
				Props.buttonPressed = "M-"
				self[8].xScale, self[8].yScale = .75, .75
			elseif lx > self.gridW-size*2 and lx < self.gridW-size then
				Props.buttonPressed = "M+"
				self[9].xScale, self[9].yScale = -.75, .75
			elseif lx > self.gridW-size and lx < self.gridW then
				Props.buttonPressed = "Y+"
				self[10].xScale, self[10].yScale = -.75, .75
			end
		-- DAY TILE TAPPED
		elseif ly > size*1.5 then
			local col = V.Floor(lx/size)
			local row = V.Floor((ly-size*1.5)/size)
			local Tmp = self[13][row*self.cols+(col+1)]
			-- TILE IS OF CURRENT MONTH?
			if Tmp.myMonth == Props.month then
				Props.day  = tonumber(Tmp.text)
				self[15].x = size*.5 + col*size
				self[15].y = size*.5 + row*size + size*1.5
				Props.buttonPressed = "DAY"
			end
		end

		EventData.buttonPressed = Props.buttonPressed
		EventData.day           = Props.day
		EventData.month         = Props.month
		EventData.year          = Props.year
		EventData.dayInfo       = self.dayInfos[ os.time{year=Props.year, month=Props.month, day=Props.day} ]
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize
		local lx,ly = EventData.lx, EventData.ly
	
		self[7].xScale, self[7].yScale = 1,1
		self[8].xScale, self[8].yScale = 1,1
		self[9].xScale, self[9].yScale = -1,1
		self[10].xScale, self[10].yScale = -1,1

		-- TITLE BAR RELEASED?
		if ly > 0 and ly <= size then
			if Props.buttonPressed == "Y-" and lx > 0 and lx < size then 
				Props.year = Props.year - 5 
				self:_update()
			elseif Props.buttonPressed == "M-" and lx > size and lx < size*2 then
				if Props.month == 1 then
					Props.month = 12
					Props.year  = Props.year - 1
				else 
					Props.month  = Props.month - 1 
				end
				self:_update()
			elseif Props.buttonPressed == "M+" and lx > self.gridW-size*2 and lx < self.gridW-size then
				if Props.month == 12 then
					Props.month = 1
					Props.year  = Props.year + 1
				else 
					Props.month = Props.month + 1 
				end
				self:_update()
			elseif Props.buttonPressed == "Y+" and lx > self.gridW-size and lx < self.gridW then
				Props.year = Props.year + 1
				self:_update()
			end
		end

		EventData.buttonPressed = Props.buttonPressed
		EventData.day           = Props.day
		EventData.month         = Props.month
		EventData.year          = Props.year
		EventData.dayInfo       = self.dayInfos[ os.time{year=Props.year, month=Props.month, day=Props.day} ]
	end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy()
		local k,v; for k,v in pairs(self.dayInfos) do self.dayInfos[k] = nil end
		self.date = nil
		V._RemoveWidget(self.Props.name) 
	end

	---------------------------------------------
	-- PUBLIC METHODS: SET / GET DATE
	---------------------------------------------
	function Grp:setDate(day,month,year)
		local Props = self.Props; if Props == nil then return end
		-- NOT DATE SET? USE TODAY!
		Props.day   = day   or tonumber(self.date.day)
		Props.month = month or self.date.month
		Props.year  = year  or self.date.year
		self:_update()
	end

	function Grp:getDate()
		local Props = self.Props; if Props == nil then return end
		return {day = Props.day, month = Props.month, year = Props.year}
	end

	function Grp:setDayInfo(day,month,year,data)
		local timeStamp = os.time{year=year, month=month, day=day}
		self.dayInfos[timeStamp] = data 
	end

	---------------------------------------------
	-- PRIVATE METHODS: CALENDAR FUNCTIONS
	---------------------------------------------
	-- GET NUMBER OF DAYS FOR A MONTH
	function Grp:_getNumDays(month, year)
        local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        local d    = days[month]
		-- CHECK FOR LEAP YEAR
		if (month == 2) then
			if year%4==0 and (year%100~=0 or year%400==0) then d = 29 end
		end
		return tonumber(d)
    end

	-- GET FIRST DAY OF A MONTH
	function Grp:_getFirstDay( month, year )
		local  temp = os.time{year = year, month = month, day = 1}
		return tonumber(os.date("%w", temp))
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewCalendar(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE A SCROLL VIEW
----------------------------------------------------------------
V.NewScrollView = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewScrollView(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewScrollView(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_SCROLLVIEW
	Grp.Props             = Props

	Grp.Mask = graphics.newMask(V.Themes[Props.theme].folderPath..V.Themes[Props.theme].maskImage)
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 2
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 2
	Props.maxW = 99999
	Props.maxH = 99999

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Grp, Tmp, i
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize
		
		if self.numChildren == 0 then
			-- [1] BACKGROUND & BORDER
			Tmp = display.newGroup(); self:insert(Tmp)

			-- [2] GROUP TO HOLD MASKED CONTENT
			Tmp = display.newGroup(); self:insert(Tmp)

			-- [3] VERTICAL SCROLLBAR
			Tmp = display.newGroup(); self:insert (Tmp)

			-- [4] HORIZONTAL SCROLLBAR
			Tmp = display.newGroup(); self:insert (Tmp)
		end

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()

		local i, j, Tmp
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local w         = Props.Shape.w
		local h         = Props.Shape.h
		local textColor = Props.textColor or Theme.CalendarTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		-- COLORIZE PARTS?
		--if Props.color ~= nil then self:getChildAt(2):setColorTransform(Props.color[1],Props.color[2],Props.color[3]) end

		-- BACKGROUND & BORDER?
		V._AddBorder(self) -- self[1]

		-- CHANGED CONTENT?
		if self.oldContent ~= Props.content or (self.oldContent == nil and Props.content == nil) then
			-- REMOVE PREVIOUS?
			if self.oldContent then
				self.oldContent:removeSelf()
				self.oldContent = nil
				collectgarbage("collect") 
			end
			
			-- NO CONTENT? CREATE A DUMMY! 
			if Props.content == nil then
				Tmp         = display.newRect(0,0,w,h)
				Tmp.anchorX = 0
				Tmp.anchorY = 0
				Tmp:setFillColor (0,0,0,1)
				Tmp.strokeWidth = 0
				Props.content   = display.newGroup()
				Props.content:insert(Tmp)
			end
			-- INITIALIZE CONTENT
			self[2]:insert(Props.content)
			Props.content.anchorX = 0
			Props.content.anchorY = 0
			Props.content.x = Props.pagingMode == true and 0 or Props.margin
			Props.content.y = Props.pagingMode == true and 0 or Props.margin
			self.oldContent = Props.content
		end

		-- SET / ADJUST MASK
		self:_adjustMask()
		
		local xScale = Props.content.xScale == (1/0) and 1 or Props.content.xScale
		local yScale = Props.content.yScale == (1/0) and 1 or Props.content.yScale

		if Props.content.width * xScale < w then xScale = w / Props.content.width ; Props.content.xScale = xScale  end
		if Props.content.height* yScale < h then yScale = h / Props.content.height; Props.content.yScale = yScale end
		Props.content.w = Props.content.width * xScale
		Props.content.h = Props.content.height* yScale

		self.minContentX = -(Props.content.w - Props.Shape.w)-Props.margin
		self.minContentY = -(Props.content.h - Props.Shape.h)-Props.margin

		-- VERTICAL SCROLLBAR
		local barSize = 4
		local barAlpha, barH
		Tmp = self[3]
		for i = Tmp.numChildren,1,-1 do Tmp[i]:removeSelf() end
		if Props.scrollbarV ~= "never" then
			Tmp.x    = w-Props.margin-barSize
			Tmp.y    = Props.margin
			barAlpha = Props.scrollbarAlpha ~= nil and Props.scrollbarAlpha or 1
			-- SCROLLBAR BG
			Tmp1         = display.newRect(0,0,barSize,h-Props.margin*2)
			Tmp1.anchorX = 0
			Tmp1.anchorY = 0
			Tmp1:setFillColor (Props.scrollbarBGColor[1],Props.scrollbarBGColor[2],Props.scrollbarBGColor[3], barAlpha)
			Tmp1.strokeWidth = 0
			Tmp:insert(Tmp1)
			-- SCROLLBAR THUMB
			barH         = Tmp1.height / Props.content.h; if barH > 1 then barH = 1 elseif barH <= 0 then barH = 0.001 end
			Tmp2         = display.newRect(0,0,barSize,Tmp1.height*barH)
			Tmp2.anchorX = 0
			Tmp2.anchorY = 0
			Tmp2:setFillColor (Props.scrollbarColor[1],Props.scrollbarColor[2],Props.scrollbarColor[3], .75)
			Tmp2.strokeWidth = 0
			Tmp:insert(Tmp2)
			Tmp2.maxY = Tmp1.y+Tmp1.height-Tmp2.height
			Tmp:insert(Tmp2)
			self:_positionScrollbar(true)
			if Props.scrollbarV == "onScroll" then Tmp.alpha = 0 end
		end

		-- HORIZONTAL SCROLLBAR
		Tmp = self[4]
		for i = Tmp.numChildren,1,-1 do Tmp[i]:removeSelf() end
		if Props.scrollbarH ~= "never" then
			Tmp.x    = Props.margin
			Tmp.y    = h-Props.margin-barSize
			barAlpha = Props.scrollbarAlpha ~= nil and Props.scrollbarAlpha or 1
			-- SCROLLBAR BG
			Tmp1         = display.newRect(0,0,w-Props.margin*2,barSize)
			Tmp1.anchorX = 0
			Tmp1.anchorY = 0
			Tmp1:setFillColor (Props.scrollbarBGColor[1],Props.scrollbarBGColor[2],Props.scrollbarBGColor[3], barAlpha)
			Tmp1.strokeWidth = 0
			Tmp:insert(Tmp1)
			-- SCROLLBAR THUMB
			barW         = Tmp1.width / Props.content.w; if barW > 1 then barW = 1 elseif barW <= 0 then barW = 0.001 end
			Tmp2         = display.newRect(0,0,Tmp1.width*barW,barSize)
			Tmp2.anchorX = 0
			Tmp2.anchorY = 0
			Tmp2:setFillColor (Props.scrollbarColor[1],Props.scrollbarColor[2],Props.scrollbarColor[3], .75)
			Tmp2.strokeWidth = 0
			Tmp2.maxX = Tmp1.x+Tmp1.width-Tmp2.width
			Tmp:insert(Tmp2)
			self:_positionScrollbar(true)
			if Props.scrollbarH == "onScroll" then Tmp.alpha = 0 end
		end

		if Props.currPage    == nil then Props.currPage = 1 end
		if Props.pagingMode == true then self:_scrollToPage() end
		
		self:_positionScrollbar()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		-- INIT DRAG
		transition.cancel(Props.content)
		self:_removeSlideTimer()
		self.speedX    = 0
		self.speedY    = 0
		self.lastPage  = Props.currPage
		self.lastX     = EventData.lx
		self.lastY     = EventData.ly
		
		EventData.currPage = Props.currPage

		self.isSliding = true; self:_positionScrollbar()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData)
		local Props = self.Props; if Props == nil then return end
		
		if Props.dragX == true then 
			self.speedX = EventData.lx - self.lastX
			Props.content.x = Props.content.x + self.speedX 
			self.lastX  = EventData.lx
		end
		if Props.dragY == true then 
			self.speedY = EventData.ly - self.lastY
			Props.content.y = Props.content.y + self.speedY 
			self.lastY  = EventData.ly
		end

		self:_keepInside()

		self.isSliding = true; self:_positionScrollbar()
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData)
		local Props = self.Props; if Props == nil then return end
		local Theme = V.Themes [Props.theme]

		-- DRAG SLIDE-OUT
		self.Timer  = timer.performWithDelay(1000/display.fps,
			function(event)
				local Widget     = event.source.Widget
				local Props      = Widget.Props
				local w          = Props.Shape.w
				local h          = Props.Shape.h
				
				Props.content.x  = Props.content.x + self.speedX
				Props.content.y  = Props.content.y + self.speedY
				Widget.isSliding = true
				self.speedX      = self.speedX * (Props.slideOut or .95)
				self.speedY      = self.speedY * (Props.slideOut or .95)
				self:_keepInside()
				self:_positionScrollbar()

				-- STOP SLIDE
				if V.Abs(self.speedX) < 4 and V.Abs(self.speedY) < 4 then 
					event.source.Widget = nil
					timer.cancel(Widget.Timer) 
					Widget.Timer     = nil
					Widget.isSliding = nil

					-- HIDE SCROLLBARS?
					if Props.scrollbarV ~= "always" then transition.to(self[3], {time = 300, alpha = 0}) end
					if Props.scrollbarH ~= "always" then transition.to(self[4], {time = 300, alpha = 0}) end
					
					-- SCROLL TO PAGE?
					if Props.pagingMode == true then
						-- HORIZONTAL SCROLL?
						if Props.content.w >= Props.Shape.w*2 then
							Props.currPage = V.Abs(V.Floor( (Props.content.x+w*.5) / w)) + 1
							self:_scrollToPage()
						-- VERTICAL SCROLL?
						elseif Props.content.h >= Props.Shape.h*2 then
							Props.currPage = V.Abs(V.Floor( (Props.content.y+h*.5) / h)) + 1
							self:_scrollToPage()
						end
					end

					-- DID SCROLL EVENT
					if Props.onDidScroll ~= nil and Props.currPage ~= self.lastPage then 
					self.lastPage = Props.currPage
					local EventData = 
						{ 
						Widget      = self,
						Props       = Props,
						name        = Props.name,
						currPage    = Props.currPage,
						}
						Props.onDidScroll(EventData)
					end
					
				end
			end	,0)
		self.Timer.Widget = self
	end

	---------------------------------------------
	-- PRIVATE METHOD: ADJUST MASK
	---------------------------------------------
	function Grp:_adjustMask()
		local Props        = self.Props
		local Theme        = V.Themes[Props.theme]
		local size         = Theme.widgetFrameSize
		self[2]:setMask      (self.Mask)
		self[2].maskScaleX = (Props.Shape.w-Props.margin*2+4) / Theme.maskImageSize
		self[2].maskScaleY = (Props.Shape.h-Props.margin*2+4) / Theme.maskImageSize
		self[2].maskX      = Props.Shape.w*.5
		self[2].maskY      = Props.Shape.h*.5
	end

	---------------------------------------------
	-- PRIVATE METHOD: POSITION SCROLLBAR
	---------------------------------------------
	function Grp:_positionScrollbar(hide)
		local Props      = self.Props
		local scrollbarV = Props.scrollbarV
		local scrollbarH = Props.scrollbarH
		local Tmp
		-- VERTICAL BAR
		Tmp = self[3]
		if scrollbarV == nil or scrollbarV == "never" or Props.dragY ~= true or Tmp.numChildren < 2 then 
			Tmp.alpha = 0
		elseif scrollbarV == "always" or (scrollbarV == "onScroll" and self.isSliding == true) then
			transition.cancel(Tmp); Tmp.alpha = 1
			-- POSITION SCROLLBAR
			Tmp[2].y = (Props.content.y-Props.margin) / (self.minContentY-Props.margin) * Tmp[2].maxY  
		end
		
		-- HORIZONTAL BAR
		Tmp = self[4]
		if scrollbarH == nil or scrollbarH == "never" or Props.dragX ~= true or Tmp.numChildren < 2 then 
			Tmp.alpha = 0
		elseif scrollbarH == "always" or (scrollbarH == "onScroll" and self.isSliding == true) then
			transition.cancel(Tmp); Tmp.alpha = 1
			-- POSITION SCROLLBAR
			Tmp[2].x = (Props.content.x-Props.margin) / (self.minContentX-Props.margin) * Tmp[2].maxX  
		end
	end

	---------------------------------------------
	-- PRIVATE METHODS
	---------------------------------------------

	-- REMOVE TIMER ------------------------------
	function Grp:_removeSlideTimer()
		if self.Timer ~= nil then 
			timer.cancel(self.Timer)
			self.Timer.Widget = nil
			self.Timer        = nil 
		end
	end

	-- SCROLLING TO CURRENT PAGE ---------------------------
	function Grp:_scrollToPage(duration)
		local Props    = self.Props; if Props == nil then return end
		local Content  = Props.content
		local toX, toY = 0,0

		self:_removeSlideTimer()
		-- HORIZONTAL SCROLL?
		if Content.w >= Props.Shape.w*2 then
			 toX = -((Props.currPage-1)*Props.Shape.w)
		-- VERTICAL SCROLL?
		elseif Content.h >= Props.Shape.w*2 then
			toY = -((Props.currPage-1)*Props.Shape.h) 
		end
		
		transition.cancel(Content)
		transition.to    (Content, {time = duration or 350, x = toX, y = toY, transition = easing.outCubic })
	end

	---------------------------------------------
	-- PRIVATE METHOD: KEEP CONTENT INSIDE VIEW
	---------------------------------------------
	function Grp:_keepInside()
		local Props = self.Props
		local x     = Props.content.x
		local y     = Props.content.y
		if x >= Props.margin then x = Props.margin elseif x < self.minContentX then x = self.minContentX end
		if y >= Props.margin then y = Props.margin elseif y < self.minContentY then y = self.minContentY end
		Props.content.x = x
		Props.content.y = y
	end
	
	---------------------------------------------
	-- PUBLIC METHODS:
	---------------------------------------------
	function Grp:setContent(Obj)
		self.Props.content = Obj
		self:_update()
	end

	function Grp:setPage(pageNum, duration)
		if self.Props.pagingMode ~= true then return end
		self.Props.currPage = pageNum > 0 and pageNum or 1
		self:_scrollToPage(duration)
	end
	
	function Grp:getCurrPage() return self.Props.currPage end
	
	function Grp:updateContent()
		-- GIDEROS ONLY
	end
	
	function Grp:positionContent(x,y)
		if self.Props.pagingMode ~= true then
			self.Props.content.x = self.Props.margin + x
			self.Props.content.y = self.Props.margin + y
			self:_keepInside  ()
		end
	end

	function Grp:moveContent(x,y)
		if self.Props.pagingMode ~= true then
			local Content = self.Props.content
			self.Props.content.x = Content:getX()+x
			self.Props.content.y = Content:getY()+y
			self:_keepInside  ()
		end
	end

	function Grp:placeContent(xPerc,yPerc)
		if self.Props.pagingMode ~= true then
			local Props   = self.Props
			local Content = Props.content
			local w       = Content.w
			local h       = Content.h
			local sw      = Props.Shape.w - Props.margin*2
			local sh      = Props.Shape.h - Props.margin*2
			Content.x     = Props.margin + (self.minContentX-Props.margin) * xPerc
			Content.y     = Props.margin + (self.minContentY-Props.margin) * yPerc
			self:_keepInside  ()
		end
	end

	---------------------------------------------
	-- PUBLIC METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy(keepContent)
		local Props = self.Props
		local i
		-- REMOVE MASK
		self[2]:setMask(nil)
		self.Mask = nil
		-- KEEP CONTENT?
		if keepContent == true then 
			stage:insert(Props.content)
			Props.content.x = 0
			Props.content.y = 0
		end
		-- REMOVE CONTENT
		Props.content   = nil
		self.oldContent = nil
		-- DELETE SLIDE TIMER
		self:_removeSlideTimer()
		-- REMOVE SCROLL TRANSITION
		if self.TransScroll ~= nil then V.transition.cancel(self.TransScroll); self.TransScroll = nil end

		V._RemoveWidget(self.Props.name) 
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewScrollView(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: CREATE INFOBUBBLE
----------------------------------------------------------------
V.NewInfoBubble = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end
	if V.Themes [Props.theme] == nil then V.error("!!! WIDGET ERROR: NewInfoBubble(): Invalid theme specified."); return end
	if V.Widgets[Props.name ] ~= nil then V.error("!!! WIDGET ERROR: NewInfoBubble(): Widget name '"..Props.name.."' is already in use. Try a unique one."); return end

	local Grp, Tmp

	V.widgetCount         = V.widgetCount + 1
	Grp                   = display.newGroup()
	Grp.typ               = V.TYPE_INFOBUBBLE
	Grp.Props             = Props
	
	-- ADD & VERIFY PROPS, SET SHAPE AND PARENT
	Props.minW = V.Themes[Props.theme].widgetFrameSize * 3
	Props.minH = V.Themes[Props.theme].widgetFrameSize * 1
	Props.maxW = 9999
	Props.maxH = Props.minH

	V._CheckProps        (Grp)
	V._ApplyWidgetMethods(Grp)
	V.Widgets[Props.name] = Grp
	
	Grp.Mask       = graphics.newMask(V.Themes[Props.theme].folderPath..V.Themes[Props.theme].maskImage)
	Grp.oldCaption = ""

	-- WIDGET TOUCH LISTENER
	Grp:addEventListener("touch", V._OnWidgetTouch )

	---------------------------------------------
	-- PRIVATE METHOD: CREATE PARTS
	---------------------------------------------
	function Grp:_create()
		local Tmp, Tmp2, i
		local Props = self.Props
		local Theme = V.Themes [Props.theme]
		local size  = Theme.widgetFrameSize

		while self.numChildren > 0 do self[1]:removeSelf() end

		-- [1] LEFT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_InfoBubble_L)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = 0
		Tmp.y       = 0
		self:insert(Tmp)
		-- [2] MIDDLE
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_InfoBubble_M)
		Tmp.anchorX = 0
		Tmp.anchorY = 0
		Tmp.x       = size
		Tmp.y       = 0
		self:insert(Tmp)
		-- [3] RIGHT CAP
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_InfoBubble_R)
		Tmp.anchorX = 1
		Tmp.anchorY = 0
		self:insert(Tmp)
		-- [4] ARROW
		Tmp         = V.newSprite(Theme.Set, Theme.Frame_InfoBubble_Arrow)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		self:insert(Tmp)
		-- [5] CAPTION
		Tmp2       = display.newGroup()
		Tmp2.x     = 0
		Tmp2.y     = 0
		self:insert(Tmp2)
		Tmp        = display.newText(" ",0,0,Theme.WidgetFont,Props.fontSize*2)
		Tmp.xScale = .5
		Tmp.yScale = .5
		Tmp2:insert (Tmp)
		Tmp2:setMask(self.Mask)
		Tmp2.maskScaleY  = size / Theme.maskImageSize
		Tmp2.maskY       = size*.5
		Tmp2.isHitTestMasked = true
		-- [6] ICON 
		Tmp         = V.newSprite(Theme.SetIcons)
		Tmp.anchorX = .5
		Tmp.anchorY = .5
		Tmp.xScale  = (size-8) / Tmp.width
		Tmp.yScale  = (size-8) / Tmp.height
		self:insert(Tmp)

		self:_update()

		-- FADE IN AT CREATION TIME?
		if Props.fadeInTime ~= nil then self:show(false); self:show(true, Props.fadeInTime); Props.fadeInTime = nil end
	end

	---------------------------------------------
	-- PRIVATE METHOD: UPDATE SHAPE
	---------------------------------------------
	function Grp:_update()
	
		local i, Tmp, Tmp2
		local Props     = self.Props
		local Theme     = V.Themes [Props.theme]
		local size      = Theme.widgetFrameSize
		local textColor = Props.textColor or Theme.ButtonTextColor
		if self.isFading ~= true then self.alpha = Props.enabled == true and Props.alpha or Props.alpha * Theme.WidgetDisabledAlpha end
		self.xScale     = Props.scale
		self.yScale     = Props.scale

		Props.includeInLayout = false -- FORCE
		Props.position        = Props.position or "top"

		-- FIT WIDTH TO TEXT?
		if Props.width == "auto" then
			self[5][1].xScale  = 1
			self[5][1].yScale  = 1
			self[5][1].text    = Props.caption 
			Props.width     = (V.Round(self[5][1].width * .5) + size + 4) * Props.scale
			V._CheckProps(self)
			Props.width     = "auto"
		end
		local w = Props.Shape.w
		local h = Props.Shape.h

		-- COLORIZE PARTS?
		if Props.color ~= nil then 
			for i = 1, 4 do self[i]:setFillColor(Props.color[1],Props.color[2],Props.color[3],1) end
		end

		-- LEFT CAP
		self[1].alpha = (Props.bubbleAlpha or 1)
		
		-- MIDDLE
		self[2].xScale= (w - size*2) / self[2].width
		self[2].alpha = (Props.bubbleAlpha or 1)
		
		-- RIGHT CAP
		self[3].x     = w
		self[3].alpha = (Props.bubbleAlpha or 1)
		
		-- ARROW
		Tmp = self[4]
		Tmp.alpha = (Props.bubbleAlpha or 1)
		if self.ArrowTrans ~= nil then transition.cancel(self.ArrowTrans ); self.ArrowTrans = nil end 
		if Props.showArrow ~= nil and Props.showArrow == true then
			Tmp.isVisible = true
			    if Props.position == "left"   then Tmp.rotation = 270; Tmp.x = w-1.25; Tmp.y = size*.5 
			elseif Props.position == "right"  then Tmp.rotation = 90; Tmp.x = 1.25; Tmp.y = size*.5 
			elseif Props.position == "bottom" then Tmp.rotation = 180; Tmp.x = w*.5; Tmp.y = 1.25 
			elseif Props.position == "top"    then Tmp.rotation = 0; Tmp.x = w*.5; Tmp.y = size-1.25 end 
			-- ANIMATION:
			if Props.animation then 
				Tmp.ox, Tmp.oy = Tmp.x, Tmp.y
				Tmp.sx, Tmp.sy = Tmp.xScale, Tmp.yScale
				Tmp.animDir    = 1
				self:_applyAnimation() 
			end
		else Tmp.isVisible = false end
		
		-- CAPTION
		Tmp = self[5][1]
		Tmp:setFillColor(textColor[1],textColor[2],textColor[3],1)
		Tmp.text    = Props.caption
		local textW     = Props.icon ~= 0 and w-size-4 or w-4
		if textW > Tmp.width*.5 then textW = Tmp.width*.5 end
		Tmp.xScale  = 1
		Tmp.yScale  = 1
		Tmp.anchorX = 0
		Tmp.anchorY = .5
		Tmp.xScale  = .5
		Tmp.yScale  = .5
		Tmp.y       = size*.5 + Theme.WidgetTextYOffset

		self:_removeTimer()
		-- TEXT BIGGER THAN MAX.WIDTH
		if Tmp.width*.5 > textW then 
			Tmp.x  = Theme.MarginX; if Props.textAlign == "right" then Tmp.x = Props.Shape.w - Theme.MarginX - textW elseif Props.textAlign == "center" then Tmp.x = Props.Shape.w*.5 -  textW*.5 end
		-- TEXT FITS INTO BUBBLE
		else 	Tmp.x = Theme.MarginX; if Props.textAlign == "right" then Tmp.x = Props.Shape.w - Theme.MarginX - Tmp.width*.5 elseif Props.textAlign == "center" then Tmp.x = Props.Shape.w*.5 -  Tmp.width*.25 end end
		
		-- ICON
		local halfW = (self[6].width*V.Abs(self[6].xScale))*.5
		self[6]:setFrame( Props.icon > 0 and Props.icon or 1 )
		self[6].isVisible    = Props.icon > 0 and true or false
		self[6].x = halfW + Theme.MarginX; if Props.textAlign == "right" then self[6].x = Props.Shape.w - halfW-Theme.MarginX elseif Props.textAlign == "center" then self[6].x = Props.Shape.w*.5 end
		self[6].y = size*.5
		if Props.icon > 0 and Props.caption ~= "" then 
			    if Props.textAlign == "left"   then Tmp.x = self[6].x + halfW + 4 
			elseif Props.textAlign == "center" then Tmp.x = Tmp.x + halfW + 2; self[6].x = Tmp.x - halfW - 4 
			elseif Props.textAlign == "right"  then self[6].x = Props.Shape.w - halfW - Theme.MarginX; Tmp.x = Tmp.x - halfW*2 - 4 end
		end

		-- ADJUST TEXT'S MASK TO FIT TEXT
		self[5].maskScaleX = textW / Theme.maskImageSize
		self[5].maskX      = Tmp.x + textW*.5
		-- INIT TEXT SCROLL?
		if Tmp.width*.5 > textW then 
			Tmp.leftX  = Tmp.x
			Tmp.rightX = Tmp.leftX + textW
			Tmp.x      = Tmp.rightX
			self:_startTimer ()
		end

		self:position(self.myTarget)
	end

	---------------------------------------------
	-- PRIVATE METHODS: SCROLL TEXT
	---------------------------------------------
	function Grp:_removeTimer()
		if self.Timer ~= nil then 
			timer.cancel(self.Timer)
			self.Timer.Widget = nil
			self.Timer        = nil 
		end
	end
	
	function Grp:_startTimer()
		self.Timer  = timer.performWithDelay(1000/display.fps,
			function(event) 
				local Tmp = event.source.Widget[5][1]
				if Tmp.x < Tmp.leftX - Tmp.width*.5 then Tmp.x = Tmp.rightX else Tmp.x = Tmp.x - 2 end
			end, 0)
		self.Timer.Widget = self
	end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW DRAGGED
	---------------------------------------------
	function Grp:_drawDragged(EventData) end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW PRESSED
	---------------------------------------------
	function Grp:_drawPressed() end

	---------------------------------------------
	-- PRIVATE METHOD: DRAW RELEASED
	---------------------------------------------
	function Grp:_drawReleased(EventData) end

	---------------------------------------------
	-- PRIVATE METHOD: DESTROY
	---------------------------------------------
	function Grp:destroy() 
		self:_removeTimer ()
		self[5]:setMask(nil)
		self.Mask     = nil
		if self.ArrowTrans ~= nil then transition.cancel(self.ArrowTrans ); self.ArrowTrans = nil end
		V._RemoveWidget(self.Props.name) 
	end

	---------------------------------------------
	-- PRIVATE METHOD: ARROW ANIMATION
	---------------------------------------------
	function Grp:_applyAnimation()
		local Tmp    = self[4]; if Tmp == nil then return end
		local Props  = self.Props
		Tmp.animDir  = Tmp.animDir * -1
		local ease   = (Tmp.animDir == 1 and easing.outCubic or easing.inCubic)
		if Props.position == "top" or Props.position == "bottom" then
			if Props.position == "top" then ease = (Tmp.animDir == 1 and easing.inCubic or easing.outCubic) end
			self.ArrowTrans = transition.to(Tmp, {time = 250, y = Tmp.oy + (5*Tmp.animDir), onComplete = function() self:_applyAnimation() end, transition = ease })
		else
			if Props.position == "left" then ease = (Tmp.animDir == 1 and easing.inCubic or easing.outCubic) end
			self.ArrowTrans = transition.to(Tmp, {time = 250, x = Tmp.ox + (5*Tmp.animDir), onComplete = function() self:_applyAnimation() end, transition = ease })
		end
	end

	---------------------------------------------
	-- PUBLIC METHOD: POSITION TOOLTIP
	---------------------------------------------
	function Grp:position(xPos,yPos)
		local Props  = self.Props
		local size   = V.Themes [Props.theme].widgetFrameSize
		local offset = Props.arrowOffset ~= nil and Props.arrowOffset or 0
		local w      = Props.Shape.w * Props.scale
		local h      = Props.Shape.h * Props.scale
		local pos    = Props.position

		self.myTarget = nil

		offset = offset + size*.5 + (Props.targetDistance ~= nil and Props.targetDistance or 10)

		-- DEFAULT POSITION
		local x = Props.Shape.x
		local y = Props.Shape.y
		-- COORDS SPECIFIED?
		if xPos ~= nil and yPos ~= nil then
			x = xPos
			y = yPos
		-- WIDGET SPECIFIED?
		elseif xPos ~= nil and type(xPos) == "string" then
			local Tmp = V.Widgets[xPos]
			if Tmp == nil then print("!!! WIDGET CANDY: InfoBubble:position(): INVALID WIDGET NAME SPECIFIED."); return end
			self.myTarget = xPos
			    if pos == "left"  then  x = Tmp.Props.Shape.x + size*.5
			elseif pos == "right" then  x = Tmp.Props.Shape.x + (Tmp.Props.Shape.w * Tmp.Props.scale) - size*.5
			else                        x = Tmp.Props.Shape.x + (Tmp.Props.Shape.w * Tmp.Props.scale)*.5 end
			    if pos == "top"    then y = Tmp.Props.Shape.y + size*.5
			elseif pos == "bottom" then y = Tmp.Props.Shape.y + (Tmp.Props.Shape.h * Tmp.Props.scale) - size*.5
			else                        y = Tmp.Props.Shape.y + (Tmp.Props.Shape.h * Tmp.Props.scale)*.5 end
			x,y = Tmp.parent:localToContent(x,y)
			x,y = self.parent:contentToLocal(x,y)
		end
		
		-- POSITION WIDGET
		    if pos == "top"    then self.x = x - w*.5; self.y = y - h - offset 
		elseif pos == "bottom" then self.x = x - w*.5; self.y = y + offset 
		elseif pos == "right"  then self.x = x + offset; self.y = y - h*.5 
		elseif pos == "left"   then self.x = x - w - offset; self.y = y - h*.5 end
		
		Props.x = x
		Props.y = y
	end

	-- CREATE & UPDATE PARTS
	Grp:_create ()

	V.print("--> Widgets.NewInfoBubble(): Created new widget '"..Props.name.."'.")

	return Grp
end


----------------------------------------------------------------
-- PUBLIC: ALERT WINDOW
----------------------------------------------------------------
V.Confirm = function (Props)

	if Props.theme == nil then Props.theme = V.defaultTheme end

	local i, Win, Tmp
	local Theme     = V.Themes[Props.theme]; if Theme == nil then V.error("!!! Widgets.Alert(): Specified theme does not exist."); return end

	V._RemoveInput()

	local winName = Props.name ~= nil and Props.name or "AlertWin"..V.widgetCount
	
	V.widgetCount = V.widgetCount + 1

	Win = V.NewWindow(
		{
		name            = winName,
		x               = "center",
		y               = Props.y ~= nil and Props.y or "center",
		scale           = Props.scale       ~= nil and Props.scale or 1.0,
		parentGroup     = nil,
		width           = Props.width       ~= nil and Props.width or "35%",
		minHeight       = 40,
		height          = Props.height      ~= nil and Props.height or "auto",
		theme           = Props.theme,
		caption         = Props.title       ~= nil and Props.title or "ALERT",
		noTitle         = Props.noTitle     ~= nil and Props.noTitle or false,
		textAlign       = "center",
		fadeInTime      = Props.fadeInTime  ~= nil and Props.fadeInTime or nil,
		alpha           = Props.alpha       ~= nil and Props.alpha or 1.0,
		icon            = Props.icon        ~= nil and Props.icon or 0,
		margin          = Props.margin      ~= nil and Props.margin or 8,
		shadow          = Props.shadow      == nil and true or Props.shadow,
		dragX           = Props.dragX       ~= nil and Props.dragX or false,
		dragY           = Props.dragY       ~= nil and Props.dragY or false,
		closeButton     = Props.closeButton ~= nil and Props.closeButton or false,
		onClose         = Props.onClose,
		modal           = true,
		} )

	Tmp = V.NewText( 
		{
		x                 = "center",
		y                 = "auto",
		width             = "100%",
		height            = "auto",
		parentGroup       = winName,
		theme             = Props.theme,
		caption           = Props.caption,
		textAlign         = "center",
		} )

	local spacing     = 8
	local winW        = Win.Props.Shape.w - Win.Props.margin*2
	local butW        = (100 / #Props.buttons)
	local pressFunc   = Props.onPress   ~= nil and Props.onPress   or function() end
	local releaseFunc = Props.onRelease ~= nil and Props.onRelease or function() end
	local buttonY     = Win.Props.height  == "auto" and "auto" or (Win.Props.Shape.h - Theme.widgetFrameSize*2 - Win.Props.margin)
	                 if Win.Props.noTitle == true then buttonY = buttonY + Theme.widgetFrameSize end

	for i = 1, #Props.buttons do
		local topMargin = i == 1 and 10 or 0
		local newLine   = (i == 1) or (Props.buttons[i].newLine == true) and true or false
		Tmp = V.NewButton(
			{
			customData      = Props.customData,
			x               = "auto",
			y               = buttonY,
			width           = Props.buttons[i].width ~= nil and Props.buttons[i].width or butW.."%",
			textAlign       = "center",
			theme           = Props.theme,
			parentGroup     = winName,
			caption         = Props.buttons[i].caption,
			icon            = Props.buttons[i].icon,
			topMargin       = topMargin,
			myNumber        = i,
			newLayoutLine   = newLine,
			includeInLayout = true,
			onPress         = function(event) event.button = event.Props.myNumber; event.customData = event.Props.customData; pressFunc  (event) end,
			onRelease       = function(event) event.button = event.Props.myNumber; event.customData = event.Props.customData; releaseFunc(event); V.Widgets[event.Props.myWindow]:destroy() end, 
			} )
	end
	Win:layout(true)
	
	-- SOUND
	if Theme.ConfirmSound ~= nil and V.muted ~= true then audio.play(Theme.Sounds[Theme.ConfirmSound], {channel = V.channel}) end

	V.print("--> Widgets.Confirm(): Created dialog window with "..#Props.buttons.." buttons.")
	
	return Win
end

return V
