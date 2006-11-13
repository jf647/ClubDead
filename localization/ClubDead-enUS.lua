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
    ["active"] = true,
    ["inactive"] = true,
    ["yes"] = true,
    ["no"] = true,
    ["N/A"] = true,
    ["alive"] = true,
    ["inraid"] = true,
    ["guildraid"] = true,
    ["inchannel"] = true,
} end)

local WITJOIN = AceLibrary("AceLocale-2.2"):new("ClubDead-WitJoin")
WITJOIN:RegisterTranslations("enUS", function() return {
    [1] = "I'm not dead, I'm just questing in spirit form",
    [2] = "I'm feigning death for real",
    [3] = "My regret is not that I have but one life to give for my raid... but that I'm giving it now",
    [4] = "Well, it is more mana-efficient to rez me than heal me",
    [5] = "Granddaddy always said laughter was the best medicine. I guess it wasn't strong enough to keep me alive",
    [6] = "It's just a flesh wound",
    [7] = "So, brave knights, if you do doubt your courage or your strength, come no further, for death awaits you all with nasty, big, pointy teeth",
    [8] = "Bring out yer dead",
    [9] = "Look, that rabbit's got a vicious streak a mile wide! It's a killer!",
    [10] = "And as the Black Beast lurched forward, escape for Arthur and his knights seemed hopeless, when suddenly, the animator suffered a fatal heart attack!",
    [11] = "Well, we'll not risk another frontal assault. That rabbit's dynamite.",
    [12] = "...death defying feats are clearly not my strong point",
    [13] = "Help! I've fallen and I can't get up!",
    [14] = "WTH?  Where's my FD button?  Oh right, not on my hunter...",
} end)

local WITLEAVE = AceLibrary("AceLocale-2.2"):new("ClubDead-WitLeave")
WITLEAVE:RegisterTranslations("enUS", function() return {
    [1] = "It is not yet my time...",
    [2] = "I see a light!",
    [3] = "I'll be back",
    [4] = "It just so happens that I'm only MOSTLY dead. There's a big difference between mostly dead and all dead. Mostly dead is slightly alive",
    [5] = "Oh! Had enough, eh? Come back and take what's coming to you, you yellow bastards! Come back here and take what's coming to you! I'll bite your legs off!",
    [6] = "Woot! Another chance to noob it up",
    [7] = "Nooooo... I was about to hook up a date with the spirit healer",
} end)

-- EOF
