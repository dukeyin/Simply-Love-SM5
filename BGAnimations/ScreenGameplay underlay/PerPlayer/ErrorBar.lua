local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
--Visual display of deviance values. 

-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" or not mods.ErrorBar then
	return
end

local jcT = {}

-- Table of judgments for the judgecounter
local jdgT = {
	TapNoteScore_W1 = SL.JudgmentColors[SL.Global.GameMode][1],
	TapNoteScore_W2 = SL.JudgmentColors[SL.Global.GameMode][2],
	TapNoteScore_W3 = SL.JudgmentColors[SL.Global.GameMode][3],
	TapNoteScore_W4 = SL.JudgmentColors[SL.Global.GameMode][4],
	TapNoteScore_W5 = SL.JudgmentColors[SL.Global.GameMode][5],
	TapNoteScore_Miss = SL.JudgmentColors[SL.Global.GameMode][6],
}

local dvCur
local jdgCur
-- Note: only for judgments with OFFSETS, might reorganize a bit later

-- User Parameters
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
local barcount = 30 									-- Number of bars. Older bars will refresh if judgments/barDuration exceeds this value. You don't need more than 40.
local frameX = GetNotefieldX(player)					-- X Positon (Center of the bar)
local frameY = _screen.cy					        -- Y Positon (Center of the bar)
local frameHeight = 10 									-- Height of the bar
local frameWidth = 240                               	-- Width of the bar
local barWidth = 2										-- Width of the ticks.
local barDuration = 0.75 								-- Time duration in seconds before the ticks fade out. Doesn't need to be higher than 1. Maybe if you have 300 bars I guess.

if SL[pn].ActiveModifiers.JudgmentGraphic == "None" then
	-- Display the error bar instead of the judgments if they are disabled.
	frameY = _screen.cy - 30
	frameHeight = 30
elseif mods.MeasureCounter ~= "None" and not mods.MeasureCounterUp then
	-- Move the error bar up if it would overlap with the measure counter.
	frameY = frameY - 55
end
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--



local wscale = 500 							-- so we aren't calculating it over and over again
local currentbar = 1 									-- so we know which error bar we need to update
local ingots = {}										-- references to the error bars

-- Makes the error bars. They position themselves relative to the center of the screen based on your dv and diffuse to your judgement value before disappating or refreshing
-- Should eventually be handled by the game itself to optimize performance
local function smeltErrorBar(index)
	return Def.Quad{
		Name = index,
        InitCommand=function(self)
            self:xy(frameX,frameY):zoomto(barWidth,frameHeight):diffusealpha(0)
        end,
		UpdateErrorBarCommand=function(self)						-- probably a more efficient way to achieve this effect, should test stuff later
			self:finishtweening()									-- note: it really looks like shit without the fade out 
            self:diffusealpha(1)
            :diffuse(jdgT[jdgCur])
            :x(frameX+dvCur*wscale)
            :linear(barDuration)
			:diffusealpha(0)
		end
	}
end

local e = Def.ActorFrame{
    InitCommand = function(self)
        -- basically the equivalent of using GetChildren() if it returned unnamed children numerically indexed
		for i=1,barcount do
			ingots[#ingots+1] = self:GetChild(i)
		end
    end,
    JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end
        if params.TapNoteScore == "TapNoteScore_Miss" then return end

        if params.TapNoteOffset then
            jdgCur = params.TapNoteScore
            dvCur = params.TapNoteOffset
            currentbar = ((currentbar)%barcount) + 1
            -- Update the next bar in the queue
            ingots[currentbar]:playcommand("UpdateErrorBar")
		end
	end,

	DootCommand=function(self)
		self:RemoveChild("DestroyMe")
		self:RemoveChild("DestroyMe2")
	end,

	-- Centerpiece
	Def.Quad{
        InitCommand=function(self)
            self:diffuse(color(.5,.5,.5,1))
            :xy(frameX,frameY)
            :zoomto(2,frameHeight)
        end
    },

	-- Indicates which side is which (early/late) These should be destroyed after the song starts.
	LoadFont("Common Normal") .. {
		Name = "DestroyMe",
        InitCommand=function(self)
            self:xy(frameX+frameWidth/4,frameY)
        end,
        BeginCommand=function(self)
            self:settext("Late")
            :diffusealpha(0):smooth(.5):diffusealpha(1):sleep(2):smooth(.5):diffusealpha(0)
        end
	},
	LoadFont("Common Normal") .. {
		Name = "DestroyMe2",
        InitCommand=function(self)
            self:xy(frameX-frameWidth/4,frameY)
        end,
        BeginCommand=function(self)
            self:settext("Early")
            :diffusealpha(0):smooth(.5):diffusealpha(1):sleep(2):smooth(.5):diffusealpha(0)
            :queuecommand("Doot")
        end,
		DootCommand=function(self)
			self:GetParent():queuecommand("Doot")
		end
	}
}

-- Initialize bars
for i=1,barcount do
	e[#e+1] = smeltErrorBar(i)
end

return e
