-- recalling
local haiku = "as my cursor blinks\nidle, my mind is active\nrecalling your voice"

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end


af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/3/recalling.ogg"),
	OnCommand=function(self) self:play() end
}

af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=haiku,
	InitCommand=function(self) self:halign(0):xy(_screen.cx - self:GetWidth()/2, _screen.cy):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(2.5):linear(1):diffusealpha(1) end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/3/mask.png"),
	InitCommand=function(self) self:zoom(0.25):Center() end,
	OnCommand=function(self) self:sleep(2):pulse():effectmagnitude(11,1,1):effectperiod(6) end
}

-- cursor
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:halign(0):xy(_screen.cx,_screen.cy-100):zoomto(2,20):diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(1,1,1,1) end
}


return af