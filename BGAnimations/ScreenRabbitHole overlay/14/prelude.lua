local s = "You should come online more often.\n-Zoe"
local bgm_volume = 10

return Def.ActorFrame{

	Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/typing.ogg"),
		InitCommand=function(self) typing = self end,
		PlayCommand=function(self) self:stop():play() end,
		HideCommand=function(self) self:stop() end,
		FadeOutAudioCommand=function(self)
			if bgm_volume >= 0 then
				local ragesound = self:get()
				bgm_volume = bgm_volume-1
				ragesound:volume(bgm_volume*0.1)
				self:sleep(0.1):queuecommand("FadeOutAudio")
			end
		end,
		SwitchSceneCommand=function(self) self:stop() end
	},

	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/typo slab serif/typo slab serif 16x16.ini"),
		InitCommand=function(self)
			local max_width = 380

			self:zoom(0.33)
				:align(0,0)
				:xy(_screen.cx-max_width/2, _screen.cy - 100)
				:wrapwidthpixels(max_width/0.33)
		end,
		OnCommand=function(self)
			self:sleep(1):queuecommand("Type")
			typing:sleep(1):queuecommand("Play")
		end,
		TypeCommand=function(self)
			if s:len() > self:GetText():len() then
				self:settext( s:sub(0,self:GetText():len()+1) ):sleep( 0.1 ):queuecommand("Type")
			end
		end,
	}
}