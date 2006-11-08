--
-- $Id: Core.lua 426 2006-11-07 00:06:57Z james $
--

-- get global library instances
local L  = AceLibrary("AceLocale-2.2"):new("ClubDead")
local WITJOIN = AceLibrary("AceLocale-2.2"):new("ClubDead-WitJoin")
local WITLEAVE = AceLibrary("AceLocale-2.2"):new("ClubDead-WitLeave")
local C  = AceLibrary("Crayon-2.0")

-- setup addon
ClubDead = AceLibrary("AceAddon-2.0"):new(
    "AceEvent-2.0",
    "AceDebug-2.0",
    "AceConsole-2.0",
    "AceDB-2.0"
)

-- setup profile
ClubDead.defaults = {
    channel = nil,
    autojoin = true,
    autoleave = true,
    wit = true,
    guildraidonly = true,
    autochannel = nil,
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
        ["check"] = {
            name = "check", type = "execute",
            desc = "check status",
            func = function()
                ClubDead:ClubDead_CheckAlive()
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
            end,
        },
        [L["guildraidonly"]] = {
            name = L["Guild raids only"], type = "toggle",
            desc = L["Only enable when the raid leader is in your guild"],
            get = function() return ClubDead.db.profile.guildraidonly end,
            set = function(v)
                ClubDead.db.profile.guildraidonly = v
            end,
        },
    },
}
ClubDead:RegisterChatCommand(L["AceConsole-Commands"], ClubDead.consoleOptions )

function ClubDead:OnEnable()

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
        self:UnRegisterEvent("PLAYER_DEAD")
    end
    if( self:IsEventRegistered("PLAYER_ALIVE") ) then
        self:UnRegisterEvent("PLAYER_ALIVE")
    end
    if( self:IsEventRegistered("PLAYER_UNGHOST") ) then
        self:UnRegisterEvent("PLAYER_UNGHOST")
    end
    
end

function ClubDead:OnDisable()

    self:TriggerEvent("ClubDead_LeftRaid")

end

function ClubDead:AceEvent_FullyInitialized()

    self.active = false
    self.inraid = false
    self.guildraid = false

    if self:GetProfile() == "Default" then
        self:SetProfile("char")
    end

    if( GetNumRaidMembers() > 0 ) then
		self:TriggerEvent("ClubDead_JoinedRaid")
	else
		self:TriggerEvent("ClubDead_LeftRaid")
	end

end

function ClubDead:OnProfileEnable()

    self:SetDebugging(1)

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
        elseif( GetGuildInfo("player") == GetGuildInfo(GetPartyMember(GetPartyleaderIndex())) ) then
            self.guildraid = true
        end
    end
    self:TriggerEvent("ClubDead_CheckAlive")

end

function ClubDead:ClubDead_LeftRaid()

    self.inraid = false
    self.guildraid = false
    self:TriggerEvent("ClubDead_CheckAlive")

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

end

function ClubDead:ClubDead_CheckChannel()

    if( not ClubDead.db.profile.channel ) then
        self:Debug("nochannel")
        return
    end
    local inchannel = GetChannelName(ClubDead.db.profile.channel) > 0
    
    if( inchannel ) then
        if( self.active ) then
            if( self.isalive ) then
                if( ClubDead.db.profile.wit ) then
                    self:Debug("emit witty remark about seeing a bright light to channel " .. ClubDead.db.profile.channel)
                    self:ScheduleEvent("ClubDead_SendMessage", 5, "it is not yet my time...", ClubDead.db.profile.channel)
                end
                if( ClubDead.db.profile.autoleave ) then
                    self:Debug("inchannel,alive,autoleave - leaving")
                    self:ScheduleEvent("ClubDead_LeaveChannel", 10, ClubDead.db.profile.channel)
                else
                    self:Debug("inchannel,alive,noautoleave- not leaving")
                end
            end
        else
            if( ClubDead.db.profile.autoleave ) then
                self:Debug("inchannel,notactive,autoleave - leaving")
                self:ScheduleEvent("ClubDead_LeaveChannel", 5, ClubDead.db.profile.channel)
            else
                self:Debug("inchannel,notactive,noautoleave - not leaving")
            end
        end
    else
        if( self.active ) then
            if( not self.isalive ) then
                if( ClubDead.db.profile.autojoin ) then
                    self:Debug("notinchannel,dead,autojoin - joining")
                    self:ScheduleEvent("ClubDead_JoinChannel", 5, ClubDead.db.profile.channel);
                    if( ClubDead.db.profile.wit ) then
                        self:Debug("emit witty remark about a parrot to channel " .. ClubDead.db.profile.channel)
                        self:ScheduleEvent("ClubDead_SendMessage", 10, "I'm not dead, I'm just questing in spirit form", ClubDead.db.profile.channel);
                    end
                else
                    self:Debug("notinchannel,dead,noautojoin - not joining")
                end
            end
        end
    end

end

function ClubDead:ClubDead_SendMessage(msg, channel)

    local channelid = GetChannelName(channel)
    if( channelid > 0 ) then
        SendChatMessage(msg, "CHANNEL", nil, channelid);
    end

end

function ClubDead:ClubDead_JoinChannel(channel)

    JoinChannelByName(channel)

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

-- EOF

