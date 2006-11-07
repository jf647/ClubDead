--
-- $Id: Core.lua 426 2006-11-07 00:06:57Z james $
--

-- get global library instances
local L  = AceLibrary("AceLocale-2.2"):new("ClubDead")

-- setup addon
ClubDead = AceLibrary("AceAddon-2.0"):new(
    "AceEvent-2.0",
    "AceDebug-2.0",
    "AceConsole-2.0",
    "AceDB-2.0",
)

-- setup profile
ClubDead.defaults = {
    channel = nil,
    autojoin = true,
    autoleave = true,
}
oRA:RegisterDB("ClubDeadDB", "ClubDeadDBPC")
oRA:RegisterDefaults("profile", ClubDead.defaults)

-- setup slash commands
ClubDead.consoleOptions = {
    type = "group",
    handler = ClubDead,
    args = {
    },
}
ClubDead:RegisterChatCommand(L["AceConsole-Commands"], ClubDead.consoleOptions )

-- EOF

