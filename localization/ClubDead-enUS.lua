--
-- $Id: IH-enUS.lua 425 2006-11-05 18:59:40Z james $
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
    ["Only enable when the raid leader is in your guild"] = true,
    
    
} end)

-- EOF
