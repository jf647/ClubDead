--
-- $Id: Core.lua 426 2006-11-07 00:06:57Z james $
--

-- get global library instances
local L  = AceLibrary("AceLocale-2.2"):new("ClubDead")
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
    witty = true,
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
                        ClubDead.db.profile.channel = GetGuildInfo("player") .. "Dead"
                        self:TriggerEvent("ClubDead_CheckActive")
                    else
                        self:Print(C:Red(L["you are not in a guild, auto-channel cannot be used"))
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

function ClubDead:OnInitialize()
end

function ClubDead:OnEnable()

    self:RegisterEvent("CHAT_MSG_SYSTEM")
    self:RegisterEvent("ClubDead_CheckChannel")
    self:RegisterEvent("ClubDead_CheckActive")
    self:RegisterEvent("ClubDead_JoinedRaid")
    self:RegisterEvent("ClubDead_LeftRaid")

    self.active = false
    self.inraid = false
    self.guildraid = false

    self:SetAliveDead()

    if( ClubDead.db.profile.autochannel == nil ) then
        if( IsInGuild() ) then
            ClubDead.db.profile.autochannel = true
        else
            ClubDead.db.profile.autochannel = false
        end
    end
    
    if( ClubDead.db.profile.autochannel ) then
        if( IsInGuild() ) then
            ClubDead.db.profile.channel = GetGuildInfo("player") .. "Dead"
        end
    end

	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
		self:AceEvent_FullyInitialized()
	else
		self:RegisterEvent("AceEvent_FullyInitialized")
	end
    
end

function ClubDead:ClubDead_RegisterEvents()

    self:RegisterEvent("PLAYER_DEAD", "SetAliveGhost")
    self:RegisterEvent("PLAYER_ALIVE", "SetAliveGhost")
    self:RegisterEvent("PLAYER_UNGHOST", "SetAliveGhost")

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

    if( GetNumRaidMembers() > 0 ) then
		self:TriggerEvent("ClubDead_JoinedRaid")
	else
		self:TriggerEvent("ClubDead_LeftRaid")
	end

end

function ClubDead:CHAT_MSG_SYSTEM(msg)

    if( string.find(msg, "^"..ERR_RAID_YOU_LEFT) ) then
		self:TriggerEvent("ClubDead_LeftRaid")
	elseif( string.find(msg, ERR_RAID_YOU_JOINED) ) then
		self:TriggerEvent("ClubDead_JoinedRaid")
	end
end

function ClubDead:ClubDead_JoinedRaid()

    self.inraid = true
    self.guildraid = GetGuildInfo("player") == GetGuildInfo(GetPartyMember(GetPartyleaderIndex()))
    self:TriggerEvent("ClubDead_CheckActive")

end

function ClubDead:ClubDead_LeftRaid()

    self.inraid = false
    self.guildraid = false
    self:TriggerEvent("ClubDead_CheckActive")

end

function ClubDead:ClubDead_CheckActive()

    if( not ClubDead.db.profile.channel ) then
        self:Print(C:Red(L["channel is not set - not activating"]))
        self:Print(C:Red(L["set it using:"]), " ", C:White(L["/clubdead channel channelname"]))
        self:Print(C:Red(L["or enable auto-channel mode using:"]), " ", C:White(L["/clubdead autochannel"]))
        self:
        return
    end
    
    if( ClubDead.db.profile.guildraidonly ) then
        if( not IsInGuild() ) then
            self:Print(C:Red(L["guildraidonly enabled and you are not guilded - not activating"]))
            return
        end
        if( not self.guildraid ) then
            self:Print(C:Red(L["guildraidonly enabled and leader is not in your guild - not activating"]))
            return
        end
    end

    self:TriggerEvent("ClubDead_RegisterEvents")

end

function ClubDead:Report()

    self:Debug("isalive " .. self.isalive)
    self:Debug("isghost " .. self.isghost)
    self:Debug("channel " .. ClubDead.db.profile.channel)

end

function ClubDead:ClubDead_CheckChannel()

    --are we in the channel?
    --yes
        --are we alive?
        --yes
            --leave
                --wit?
                --yes
                    --emit
    --no
        --are we dead?
        --yes
            --join
                --wit?
                --yes
                    --emit

end

function SetAliveGhost()

    local dead = UnitIsDead("player")
    local deadorghost = UnitIsDeadOrGhost("player")
    if( dead or deadorghost ) then
        self.isalive = 0
    else
        self.isalive = 1
    end
    if( deadorghost and not dead ) then
        self.isghost = 1
    else
        self.isghost = 0
    end
    self:Debug("isalive/isghost = %d/%d", self.isalive, self.isghost)
    self:TriggerEvent("ClubDead_CheckChannel")

end

-- EOF

