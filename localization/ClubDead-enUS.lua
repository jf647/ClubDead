--
-- $Id$
--

local L = AceLibrary("AceLocale-2.2"):new("ClubDead")
L:RegisterTranslations("enUS", function() return {
    ["AceConsole-Commands"] = {"/clubdead"},
    ["Club Dead"] = true,
    ["report"] = true,
    ["channel"] = true,
    ["Set channel"] = true,
    ["Report status"] = true,
    ["Display a status report"] = true,
    ["channel is not set - not activating"] = true,
    ["set it using:"] = true,
    ["/clubdead channel channelname"] = true,
    ["or enable auto-channel mode using:"] = true,
    ["/clubdead autochannel"] = true,
    ["guildraidonly enabled and you are not guilded - not activating"] = true,
    ["guildraidonly enabled and leader is not in your guild - not activating"] = true,
    ["Set channel to join on death (turns autochannel off)"] = true,
    ["autojoin"] = true,
    ["Auto-join"] = true,
    ["Auto-join channel on death"] = true,
    ["autoleave"] = true,
    ["Auto-leave"] = true,
    ["Auto-leave channel on rez"] = true,
    ["wit"] = true,
    ["Wit"] = true,
    ["Emit witty rejoinders on channel join/leave"] = true,
    ["autochannel"] = true,
    ["Auto-channel"] = true,
    ["Set channel to your Guild Name suffixed by 'Dead'"] = true,
    ["you are not in a guild, auto-channel cannot be used"] = true,
    ["guildraidonly"] = true,
    ["Guild raids only"] = true,
    ["Addon takes no action unless the raid leader is in your guild"] = true,
    ["chatframe"] = true,
    ["Set chatframe name"] = true,
    ["Set chatframe in which the channel will be made visible when it is joined"] = true,
} end)

local WITJOIN = AceLibrary("AceLocale-2.2"):new("ClubDead-WitJoin")
WITJOIN:RegisterTranslations("enUS", function() return {
    [1] = "I'm not dead, I'm just questing in spirit form",
    [2] = "I'm feigning death for real",
    [3] = "My regret is not that I have but one life to give for my raid... but that I'm giving it now",
    [4] = "Well, it is more mana-efficient to rez me than heal me",
} end)

local WITLEAVE = AceLibrary("AceLocale-2.2"):new("ClubDead-WitLeave")
WITLEAVE:RegisterTranslations("enUS", function() return {
    [1] = "It is not yet my time...",
    [2] = "I see a light!",
    [3] = "I'll be back",
} end)

-- EOF
