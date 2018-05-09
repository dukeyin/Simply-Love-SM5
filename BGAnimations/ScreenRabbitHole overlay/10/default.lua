-- 13 Ghosts II

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end
af.InitCommand=function(self) self:diffuse( Color.Black ) end
af.OnCommand=function(self)
	self:sleep(2):smooth(1):diffuse( Color.White )
		:sleep(2*60 + 50):linear(6):diffuse( Color.Black )
end

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/10/13 Ghosts II.ogg"),
	OnCommand=function(self) self:sleep(0.25):queuecommand("Play") end,
	PlayCommand=function(self) self:play() end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/10/13 Ghosts II.mp4"),
	InitCommand=function(self)
		self:Center():loop(false)
		if IsUsingWideScreen() then self:FullScreen() end
	end
}

return af