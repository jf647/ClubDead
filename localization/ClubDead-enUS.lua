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
    ["Set channel to join on death"] = true,
    ["Report status"] = true,
    ["Display a status report"] = true,
    ["set it using:"] = true,
    ["/clubdead channel channelname"] = true,
    ["or enable auto-channel mode using:"] = true,
    ["/clubdead autochannel"] = true,
    ["guildraidonly enabled and you are not guilded - not activating"] = true,
    ["guildraidonly enabled and leader is not in your guild - not activating"] = true,
} end)

-- EOF
