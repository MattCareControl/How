
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local func = require("functions")
local http = require("httpwork")
local widget = require( "widget" )
local url = require("socket.url")
local socket = require("socket")
local group
local MainGroup
local scView
local ExtraGrp
local UList, SList
local UserList = {}
local SelectList = {}
local LoadData2
local PlayGameStarted
local ConBut
local ScaleLine
local xPos
local QUnit
local Suffix = ""
local Prefix = ""
local Answer
local AnsPos
local AnswerSet
local TimerCount
local tmID
local tmGrp
local LoadQuestion
local UserAnswer
local LoadTime
local FinishTime
local ConfirmAnswer
local NumVal
local QGroup


function round(n)

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

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

local DrawScaleLine = function()

	local vl
	if ScaleLine ~= nil then
		ScaleLine:removeSelf()
		ScaleLine = nil
	end

	ScaleLine = func.DrawLine(xPos,800,xPos,1000,6,1,0,0)
	MainGroup:insert(ScaleLine)

	if NumVal ~= nil then
		NumVal:removeSelf()
		NumVal = nil
	end

	vl = AnsPos - xPos

	if _G.GameStructure[1].Questions[_G.CurrentQuestion].UseCommas == "1" then
		UserAnswer = comma_value(round(Answer - (vl * QUnit)) )
	else
		UserAnswer = round(Answer - (vl * QUnit)) 
	end
	
	NumVal = func.StandardLabelBold(Prefix .. UserAnswer ..  Suffix,display.contentWidth/2,700,60,255/255,255/255,0/255,nil,nil,1)
	MainGroup:insert(NumVal)
end

local ScaleMove = function(event)

	if event.phase == "moved" and AnswerSet == 0 then
		xPos = event.x
		DrawScaleLine()
	end



end

local DisplayTimer = function()

	if tmGrp ~= nil then
		tmGrp:removeSelf()
		tmGrp = nil
	end

	if TimerCount == 0 then
		AnswerSet = 1
		if ConBut ~= nil then
			ConBut:removeSelf()
			ConBut = nil
		end
		timer.cancel( tmID )
		if FinishTime == 0 then
			FinishTime = socket.gettime()*1000
		end
		_G.GameStructure[1].Questions[_G.CurrentQuestion].UserAnswer = UserAnswer
		_G.GameStructure[1].Questions[_G.CurrentQuestion].AnswerTime = FinishTime - LoadTime

		_G.CurrentQuestion = _G.CurrentQuestion + 1
		if _G.CurrentQuestion > tonumber(_G.GameStructure[1].NoQuestions) then
			func.LoadScreen("FinishGame","crossFade",1000)
		else
			LoadQuestion()
		end
		return
	end	



	tmGrp = display.newGroup()
	tmGrp.alpha = 0
	tmGrp.xScale = 1
	tmGrp.yScale = 1
	tmGrp:insert(func.StandardImage("Circle.png",550,60))
	tmGrp:insert(func.StandardLabelBold(TimerCount,550,60,40,255/255,255/255,0/255,nil,nil,1))
	transition.to( tmGrp, { time=500, alpha=1,x=-260, y=-40,xScale=1.5,yScale=1.5,transition=easing.outQuart } )
	TimerCount = TimerCount - 1

	if ConBut == nil and AnswerSet == 0 then
		ConBut = func.StandardImage("Confirm.png",display.contentWidth/2,1100,ConfirmAnswer,nil,nil,1.4)
		QGroup:insert(ConBut)
	end
end

local StartTimer = function()

	
	tmID = timer.performWithDelay( 1000, DisplayTimer, 0 )

end

ConfirmAnswer = function(event)


	if event.phase == "ended" then
		AnswerSet = 1
		if ConBut ~= nil then
			ConBut:removeSelf()
			ConBut = nil
		end
		FinishTime = socket.gettime()*1000
		QGroup:insert(func.StandardLabelBold("Answer Set",display.contentWidth/2,1100,40,91/255,155/255,213/255,nil,nil,1))
	end

end

LoadQuestion = function()

	if QGroup ~= nil then
		QGroup:removeSelf()
		QGroup = nil
	end

	local qText = ""
	local qImage

	AnswerSet = 0
	Answer = _G.GameStructure[1].Questions[_G.CurrentQuestion].ActualAnswer
	QUnit = _G.GameStructure[1].Questions[_G.CurrentQuestion].QUnit
	TimerCount = _G.GameStructure[1].TimeLimit
	Prefix = _G.GameStructure[1].Questions[_G.CurrentQuestion].Prefix
	Suffix = _G.GameStructure[1].Questions[_G.CurrentQuestion].Suffix
	qText = _G.CurrentQuestion .. ". " .. _G.GameStructure[1].Questions[_G.CurrentQuestion].QuestionText

	QGroup = display.newGroup()
	QGroup:insert(func.StandardLabelBoldW(qText .. "?",20,250,600,40,91/255,155/255,213/255))

	if _G.GameStructure[1].Questions[_G.CurrentQuestion].HasImage == "Yes" then
		qImage = func.StandardImage("img" .. _G.GameStructure[1].Questions[_G.CurrentQuestion].QuestionID .. ".jpg",-100,500,nil,nil,nil,nil,nil,nil,1,nil,"Temporary",550,250)
	else
		qImage = func.StandardImage("QMark.png",-100,500)
	end
	QGroup:insert(qImage)
	transition.to( qImage, { time=500, x=400, transition=easing.outQuart } )

	xPos = display.contentWidth/2

	AnsPos = math.random(15,600)

	DrawScaleLine()
	MainGroup:insert(QGroup)

	StartTimer()
	LoadTime = socket.gettime()*1000
	FinishTime = 0
	_G.HaltNav = nil
end

function scene:enterScene(event)


	_G.HaltNav = 1
	_G.CurrentQuestion = 1
	transition.to( MainGroup, { time=700, alpha=1, transition=easing.outQuart,onComplete=LoadQuestion } )

end

function scene:createScene( event )
	
	group = self.view

	local prior_scene = storyboard.getPrevious()
	storyboard.removeScenePurgeAll( prior_scene )



	MainGroup = display.newGroup()
	MainGroup.alpha = 0
	
	MainGroup:insert( func.StandardImage("GameOn.png",display.contentWidth/2,60,nil,nil,nil,0.7))
	MainGroup:insert( func.StandardImage("Scale.png",display.contentWidth/2,900,ScaleMove,nil,nil,1.8))

	group:insert(MainGroup)


end

function scene:destroyScene( event )
	
	if ConBut ~= nil then
		ConBut:removeSelf()
		ConBut = nil
	end
	if NumVal ~= nil then
		NumVal:removeSelf()
		NumVal = nil
	end
	if QGroup ~= nil then
		QGroup:removeSelf()
		QGroup = nil
	end
	timer.cancel( tmID )
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