local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- exit if disabled
--if mods.EarlyLate == "Disabled" then return end

-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" or not mods.ErrorBar then
	return
end

local useitg = true

local elcolors = {{0,0.5,1,1},{1,0.5,1,1}} -- blue/pink

local threshold = -1
local faplusmod = 0
--local thresholdmod = mods.EarlyLateThreshold
--local faplusmod = mods.FAPlus
--if thresholdmod == "FA+" then
--    threshold = (faplusmod > 0) and faplusmod or 0
--elseif thresholdmod == "None" then
--    threshold = -1
--end

--if (useitg) and threshold == 0 then
--    threshold = WF.ITGTimingWindows[WF.ITGJudgments.Fantastic]
--elseif (not useitg) and threshold == 0.015 then
--    -- this condition should not happen but might as well cover it here too
--    threshold = 0
--end

-- 🛹
-- one way of drawing these quads would be to just draw them centered, back to front, with the full width of the
-- corresponding window. this would look bad if we want to alpha blend them though, so i'm drawing the segments
-- individually so that there is no overlap.
local af = Def.ActorFrame{
    InitCommand = function(self)
        local reverse = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):UsingReverse()
        self:xy(GetNotefieldX(player), _screen.cy - 12)
        self:zoom(0)
    end
}

local mwidth = 80 -- technically half width
local mheight = 6
local tickwidth = 2
local windowstouse = (SL.Global.GameMode == "FA+") and 3 or 2 -- decided that we don't care to show outside the first few windows
windowstouse = 5

af[#af+1] = Def.Quad{
    InitCommand = function(self)
        self:diffuse(color("#000000"))
        self:zoomto(mwidth * 2 + 4, mheight + 4)
    end
}

local function getWindow(n)
    -- just gonna make this a function because the logic for timing windows per env is so disjointed (TWA lol fuck you)
    if n == 0 then return faplusmod end
    local prefs = SL.Preferences[SL.Global.GameMode]
    return prefs["TimingWindowSecondsW"..n] + prefs["TimingWindowAdd"]
end

local wedge = math.min(
    math.max(PREFSMAN:GetPreference("TimingWindowSecondsW4"), PREFSMAN:GetPreference("TimingWindowSecondsW5")),
    getWindow(windowstouse)
)

local lastx1 = 0

for i = 1, windowstouse + 1 do
    -- create two quads for each window.
    if (not SL.Global.ActiveModifiers.TimingWindows[5]) and ((useitg and (i == 5 or i == 6)) or ((not useitg) and i == 6)) then
        break
    end

    if not (i == 2 and faplusmod == 0) then
        local ii = i
        if i > 1 then ii = i - 1 end
        local x1 = (getWindow((i == 1 and faplusmod > 0) and 0 or ii) / wedge) * mwidth
        local w = x1 - lastx1
        local c = (not (i == 2 and faplusmod > 0)) and SL.JudgmentColors[SL.Global.GameMode][ii] or Color.White
        af[#af+1] = Def.Quad{
            InitCommand = function(self)
                self:x(x1):horizalign("right"):zoomx(w):diffuse(c)
                :zoomy(mheight)
            end
        }
        af[#af+1] = Def.Quad{
            InitCommand = function(self)
                self:x(-x1):horizalign("left"):zoomx(w):diffuse(c)
                :zoomy(mheight)
            end
        }

        lastx1 = x1
    end
end

local ticks = {}
local currentTick = 1

for i = 1, 10 do
    af[#af+1] = Def.Quad{
        Name = "TonyHawkTick" .. i,
        InitCommand = function(self)
            ticks[#ticks+1] = self
            local clr = (SL.Global.GameMode == "ITG") and {0.7,0,0,1} or {0,0.5,0.8,1}
            self:zoomx(tickwidth):diffuse(clr):diffusealpha(0):zoomy(mheight+4)
        end
    }
end

af.JudgmentMessageCommand = function(self, params)
    if params.Player ~= player then return end
    if params.TapNoteScore and (not params.HoldNoteScore) and params.TapNoteScore ~= "TapNoteScore_AvoidMine" and
    params.TapNoteScore ~= "TapNoteScore_HitMine" and params.TapNoteScore ~= "TapNoteScore_Miss" then
        if (threshold == -1) or (threshold == 0 and params.TapNoteScore ~= "TapNoteScore_W1") or 
        (threshold > 0 and math.abs(params.TapNoteOffset) > threshold) then
            --self:finishtweening()

            local tick = self:GetChild("TonyHawkTick" .. currentTick)
            tick:finishtweening():diffusealpha(1)
            tick:x(math.max(math.min((params.TapNoteOffset / wedge) * mwidth, mwidth + 4), -mwidth - 4))
            tick:linear(2):diffusealpha(0)

            currentTick = currentTick + 1
            if currentTick > #ticks then
                currentTick = 1
            end

            self:zoom(1)
            --self:sleep(0.5 * 4) -- XXX
            --self:zoom(0)
        else
            --self:finishtweening()
            --self:zoom(0)
        end
    end
end

return af
