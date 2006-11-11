--
-- $Id$
--

-- get global library instances
local C = AceLibrary("Crayon-2.0")
local T = AceLibrary("Tablet-2.0")
local L = AceLibrary("AceLocale-2.2"):new("ClubDead")
local WITJOIN = AceLibrary("AceLocale-2.2"):new("ClubDead-WitJoin")
local WITLEAVE = AceLibrary("AceLocale-2.2"):new("ClubDead-WitLeave")

-- setup addon
ClubDead = AceLibrary("AceAddon-2.0"):new(
    "AceEvent-2.0",
    "AceDebug-2.0",
    "AceConsole-2.0",
    "AceDB-2.0",
    "FuBarPlugin-2.0"
)

-- setup profile
ClubDead.defaults = {
    channel = nil,
    autojoin = true,
    autoleave = true,
    wit = true,
    guildraidonly = false,
    autochannel = nil,
    chatframe = "ChatFrame1",
}
ClubDead:RegisterDB("ClubDeadDB", "ClubDeadDBPC")
ClubDead:RegisterDefaults("profile", ClubDead.defaults)

-- setup slash commands
ClubDead.consoleOptions = {
    type = "group",
    handler = ClubDead,
    args = {
        [L["report"]] = {
            name = L["Report status"], type = "execute",
            desc = L["Display a status report"],
            func = function()
                ClubDead:Report()
            end,
        },
        [L["channel"]] = {
            name = L["Set channel"], type = "text",
            desc = L["Set channel to join on death (turns autochannel off)"],
            usage = "channel",
            get = function() return ClubDead.db.profile.channel end,
            set = function(v)
                if( ClubDead.db.profile.autochannel ) then
                    ClubDead.db.profile.autochannel = false
                end
                ClubDead.db.profile.channel = v
                ClubDead:Update()
            end,
        },
        [L["chatframe"]] = {
            name = L["Set chatframe name"], type = "text",
            desc = L["Set chatframe in which the channel will be made visible when it is joined"],
            usage = "framename",
            get = function() return ClubDead.db.profile.chatframe end,
            set = function(v)
                ClubDead.db.profile.chatframe = v
            end,
        },
        [L["autojoin"]] = {
            name = L["Auto-join"], type = "toggle",
            desc = L["Auto-join channel on death"],
            get = function() return ClubDead.db.profile.autojoin end,
            set = function(v)
                ClubDead.db.profile.autojoin = v
            end,
        },
        [L["autoleave"]] = {
            name = L["Auto-leave"], type = "toggle",
            desc = L["Auto-leave channel on rez"],
            get = function() return ClubDead.db.profile.autoleave end,
            set = function(v)
                ClubDead.db.profile.autoleave = v
            end,
        },
        [L["wit"]] = {
            name = L["Wit"], type = "toggle",
            desc = L["Emit witty rejoinders on channel join/leave"],
            get = function() return ClubDead.db.profile.wit end,
            set = function(v)
                ClubDead.db.profile.wit = v
            end,
        },
        [L["autochannel"]] = {
            name = L["Auto-channel"], type = "toggle",
            desc = L["Set channel to your Guild Name suffixed by 'Dead'"],
            get = function() return ClubDead.db.profile.autochannel end,
            set = function(v)
                if( v ) then
                    if( IsInGuild() ) then
                        ClubDead.db.profile.autochannel = true
                        ClubDead:Debug("GetGuildInfo = " .. GetGuildInfo("player"))
                        ClubDead.db.profile.channel = string.gsub(GetGuildInfo("player"), "%s", "") .. "Dead"
                        ClubDead:TriggerEvent("ClubDead_CheckAlive")
                    else
                        ClubDead:Print(C:Red(L["you are not in a guild, auto-channel cannot be used"]))
                    end
                else
                    ClubDead.db.profile.autochannel = false
                end
                ClubDead:Update()
            end,
        },
        [L["guildraidonly"]] = {
            name = L["Guild raids only"], type = "toggle",
            desc = L["Addon takes no action unless the raid leader is in your guild"],
            get = function() return ClubDead.db.profile.guildraidonly end,
            set = function(v)
                ClubDead.db.profile.guildraidonly = v
            end,
        },
    },
}
ClubDead:RegisterChatCommand(L["AceConsole-Commands"], ClubDead.consoleOptions )

-- setup FuBar
ClubDead.cannotDetachTooltip = true
ClubDead.OnMenuRequest = ClubDead.consoleOptions
ClubDead.hasIcon = "Interface\\Icons\\INV_Misc_Idol_03"

function ClubDead:OnInitialize()

    local count = 0
    for _, _ in WITJOIN:GetIterator() do
        count = count + 1
    end
    self.maxjoinwit = count
    count = 0
    for _, _ in WITLEAVE:GetIterator() do
        count = count + 1
    end
    self.maxleavewit = count
    self:Debug("maxjoinwit = %d, maxleavewit = %d", self.maxjoinwit, self.maxleavewit)

end

function ClubDead:OnEnable()

    self:UnregisterAllEvents()
    self:RegisterEvent("CHAT_MSG_SYSTEM")
    self:RegisterEvent("ClubDead_CheckChannel")
    self:RegisterEvent("ClubDead_CheckActive")
    self:RegisterEvent("ClubDead_CheckAlive")
    self:RegisterEvent("ClubDead_JoinedRaid")
    self:RegisterEvent("ClubDead_LeftRaid")
    self:RegisterEvent("ClubDead_RegisterEvents")
    self:RegisterEvent("ClubDead_UnRegisterEvents")
    self:RegisterEvent("ClubDead_SendMessage")
    self:RegisterEvent("ClubDead_JoinChannel")
    self:RegisterEvent("ClubDead_LeaveChannel")

	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	else
		self:RegisterEvent("AceEvent_FullyInitialized")
	end
    
end

function ClubDead:ClubDead_RegisterEvents()

    if( not self:IsEventRegistered("PLAYER_DEAD") ) then
        self:RegisterEvent("PLAYER_DEAD", "ClubDead_CheckAlive")
    end
    if( not self:IsEventRegistered("PLAYER_ALIVE") ) then
        self:RegisterEvent("PLAYER_ALIVE", "ClubDead_CheckAlive")
    end
    if( not self:IsEventRegistered("PLAYER_UNGHOST") ) then
        self:RegisterEvent("PLAYER_UNGHOST", "ClubDead_CheckAlive")
    end

end

function ClubDead:ClubDead_UnRegisterEvents()

    if( self:IsEventRegistered("PLAYER_DEAD") ) then
        self:UnregisterEvent("PLAYER_DEAD")
    end
    if( self:IsEventRegistered("PLAYER_ALIVE") ) then
        self:UnregisterEvent("PLAYER_ALIVE")
    end
    if( self:IsEventRegistered("PLAYER_UNGHOST") ) then
        self:UnregisterEvent("PLAYER_UNGHOST")
    end
    
end

function ClubDead:OnDisable()

    self:TriggerEvent("ClubDead_LeftRaid")

end

function ClubDead:AceEvent_FullyInitialized()

    self.active = false
    self.inraid = false
    self.guildraid = false
    self.lastjoinwitidx = nil
    self.lastleavewitidx = nil

    if self:GetProfile() == "Default" then
        self:SetProfile("char")
    end

    if( GetNumRaidMembers() > 0 ) then
		self:TriggerEvent("ClubDead_JoinedRaid")
	else
		self:TriggerEvent("ClubDead_LeftRaid")
	end

    self:Update()

end

function ClubDead:OnProfileEnable()

    if( ClubDead.db.profile.autochannel == nil ) then
        self:Debug("channel is nil - setting up")
        if( IsInGuild() ) then
            self:Debug("is in guild - turning on autochannel")
            ClubDead.db.profile.autochannel = true
        else
            self:Debug("is not in guild - turning off autochannel")
            ClubDead.db.profile.autochannel = false
        end
    end
    
    if( ClubDead.db.profile.autochannel ) then
        self:Debug("autochannel enabled")
        if( IsInGuild() ) then
            self:Debug("GetGuildInfo = " .. GetGuildInfo("player"))
            ClubDead.db.profile.channel = string.gsub(GetGuildInfo("player"), "%s", "") .. "Dead"
            self:Debug("set channel to " .. ClubDead.db.profile.channel)
        end
    end
    
    self:Update()

end

function ClubDead:CHAT_MSG_SYSTEM(msg)

    if( string.find(msg, "^"..ERR_RAID_YOU_LEFT) ) then
        self:Debug("caught left raid from chat")
        self:TriggerEvent("ClubDead_LeftRaid")
	elseif( string.find(msg, ERR_RAID_YOU_JOINED) ) then
		self:Debug("caught joined raid from chat")
        self:TriggerEvent("ClubDead_JoinedRaid")
	end
end

function ClubDead:ClubDead_JoinedRaid()

    self.inraid = true
    self.guildraid = false
    if( IsInGuild() ) then
        if( IsPartyLeader() ) then
            self.guildraid = true
        else
            for i = 1, 40 do
                local _, rank = GetRaidRosterInfo(i)
                self:Debug("raid member " .. i .. " has rank " .. rank)
                if( rank == 2 ) then
                    local leaderguild = GetGuildInfo("raid"..i)
                    self:Debug("raid leader guild is %s", leaderguild)
                    if( GetGuildInfo("player") == leaderguild ) then
                        self.guildraid = true
                        break
                    end
                end
            end
        end
    end
    self:TriggerEvent("ClubDead_CheckAlive")
    
    self:Update()

end

function ClubDead:ClubDead_LeftRaid()

    self.inraid = false
    self.guildraid = false
    self:TriggerEvent("ClubDead_CheckAlive")
    
    self:Update()

end

function ClubDead:ClubDead_CheckAlive()

    if( UnitIsDeadOrGhost("player") ) then
        self:Debug("is dead")
        self.isalive = false
    else
        self:Debug("is alive")
        self.isalive = true
    end
    self:TriggerEvent("ClubDead_CheckActive")
    
end

function ClubDead:ClubDead_CheckActive()

    self.active = false
    if( not ClubDead.db.profile.channel ) then
        self:Print(C:Red(L["channel is not set - not activating"]))
        self:Print(C:Red(L["set it using:"]), " ", C:White(L["/clubdead channel channelname"]))
        self:Print(C:Red(L["or enable auto-channel mode using:"]), " ", C:White(L["/clubdead autochannel"]))
    else
        if( self.inraid ) then
            if( ClubDead.db.profile.guildraidonly ) then
                if( not IsInGuild() ) then
                    self:Print(C:Red(L["guildraidonly enabled and you are not guilded - not activating"]))
                elseif( not self.guildraid ) then
                    self:Print(C:Red(L["guildraidonly enabled and leader is not in your guild - not activating"]))
                else
                    self.active = true
                end
            else
                self.active = true
            end
        else
            self:Debug("self.inraid is false")
        end
    end

    if( self.active ) then
        self:TriggerEvent("ClubDead_RegisterEvents")
    else
        self:TriggerEvent("ClubDead_UnRegisterEvents")
    end
    
    self:TriggerEvent("ClubDead_CheckChannel")
    
    self:Update()

end

function ClubDead:ClubDead_CheckChannel()

    if( not ClubDead.db.profile.channel ) then
        self:Debug("nochannel")
        return
    end
    local inchannel = GetChannelName(ClubDead.db.profile.channel) > 0
    
    if( inchannel ) then
        self:Debug("inchannel")
        if( self.active ) then
            if( self.isalive ) then
                if( ClubDead.db.profile.wit ) then
                    self:ScheduleEvent("leavemsg", "ClubDead_SendMessage", 5, WITLEAVE, self.maxleavewit, ClubDead.db.profile.channel, ClubDead.db.profile.autoleave)
                end
            end
        else
            if( ClubDead.db.profile.autoleave ) then
                self:Debug("inchannel,notactive,autoleave - leaving")
                self:ScheduleEvent("leave", "ClubDead_LeaveChannel", 10, ClubDead.db.profile.channel)
            else
                self:Debug("inchannel,notactive,noautoleave - not leaving")
            end
        end
    else
        self:Debug("not inchannel")
        if( self.active ) then
            if( not self.isalive ) then
                if( ClubDead.db.profile.autojoin ) then
                    self:Debug("notinchannel,dead,autojoin - joining")
                    self:ScheduleEvent("join", "ClubDead_JoinChannel", 5, ClubDead.db.profile.channel);
                    if( ClubDead.db.profile.wit ) then
                        self:ScheduleEvent("joinmsg", "ClubDead_SendMessage", 10, WITJOIN, self.maxjoinwit, ClubDead.db.profile.channel);
                    end
                else
                    self:Debug("notinchannel,dead,noautojoin - not joining")
                end
            end
        end
    end
    
    self:Update()

end

function ClubDead:ClubDead_SendMessage(tbl, size, channel, autoleave)

    local channelid = GetChannelName(channel)
    if( channelid > 0 ) then
        local tempnum = random(1, size);
        self:Debug("tempnum = " .. tempnum)
        while tempnum == self.lastwitjoinidx and size >= 2 do
            tempnum = random(1, size);
            self:Debug("tempnum = " .. tempnum)       
        end
        self.lastwitjoinid = tempnum;
        local msg = tbl[tempnum]
        self:Debug("message: " .. msg)
        SendChatMessage(msg, "CHANNEL", nil, channelid);
        if( autoleave ~= nil ) then
            if( autoleave ) then
                self:Debug("scheduling autoleave")
                self:ScheduleEvent("leave", "ClubDead_LeaveChannel", 5, channel)
            else
                self:Debug("not scheduling autoleave")
            end
        end
    else
        self:Debug("cannot send message - not in channel")
    end

end

function ClubDead:ClubDead_JoinChannel(channel)

    JoinChannelByName(channel)
    local f = getglobal(ClubDead.db.profile.chatframe)
    if( f ~= nil ) then
        ChatFrame_AddChannel(f, channel)
    else
        self:Debug("can't get object for " .. ClubDead.db.profile.chatframe)
    end

end

function ClubDead:ClubDead_LeaveChannel(channel)

    LeaveChannelByName(channel)

end

function ClubDead:Report()

    local s
    if( self.isalive ) then
        s = "alive "
    else
        s = "notalive "
    end
    if( self.active ) then
        s = s .. "active "
    else
        s = s .. "notactive "
    end
    if( self.inraid ) then
        s = s .. "inraid "
    else
        s = s .. "notinraid "
    end
    if( self.guildraid ) then
        s = s .. "guildraid "
    else
        s = s .. "notguildraid "
    end
    s = s .. "channel:" .. ClubDead.db.profile.channel
    self:Debug(s)

end

function ClubDead:OnTextUpdate()

    if( self.active ) then
        self:SetText(C:Green(L["active"]))
    else
        self:SetText(C:Red(L["inactive"]))
    end

end

function ClubDead:OnTooltipUpdate()

    local cat = T:AddCategory(
        'columns', 2,
        'child_textR', 0,
        'child_textG', 1,
        'child_textB', 0,
        'child_text2R', 1,
        'child_text2G', 1,
        'child_text2B', 1
    )
    local val
    if( self.isalive ) then
        val = L["yes"]
    else
        val = L["no"]
    end
    cat:AddLine( 'text', L["alive"], 'text2', val )
    if( self.active ) then
        val = L["yes"]
    else
        val = L["no"]
    end
    cat:AddLine( 'text', L["active"], 'text2', val )
    if( self.inraid ) then
        val = L["yes"]
    else
        val = L["no"]
    end
    cat:AddLine( 'text', L["inraid"], 'text2', val )
    if( self.guildraid ) then
        val = L["yes"]
    else
        val = L["no"]
    end
    cat:AddLine( 'text', L["guildraid"], 'text2', val )
    if( ClubDead.db.profile.channel ~= nil ) then
        val = ClubDead.db.profile.channel
    else
        val = L["N/A"]
    end
    cat:AddLine( 'text', L["channel"], 'text2', val )
    if( ClubDead.db.profile.channel ~= nil ) then
        if( GetChannelName(ClubDead.db.profile.channel) > 0 ) then
            val = L["yes"] 
        else
            val = L["no"]
        end
        cat:AddLine( 'text', L["inchannel"], 'text2', val )
    end

end

-- EOF

