Welcome to Club Dead
====================

When you die early in a long pull, it's not uncommon to get a bit chatty in
/raid, especially during late night raids. Our guild now shunts people over
to a custom chat channel that we call "Club Dead" if they want to make
derisive comments about the efficiency of the healers, the similarities
between that felguard and a Mack truck, or just to quiz us on organic
chemistry.

This addon automates the process of joining the channel on death, leaving it
when you are resurrected, and spitting out a witty rejoinder when you join
or leave.

The name of the channel defaults to your guild name (with spaces removed)
suffixed by "Dead". By default, you automatically join on death and leave on
rez, say a witty remark on join/leave.

ClubDead is an Ace2 addon benefiting from the AceDB, AceConsole, and
AceLocale libraries. The default profile is per-char, but can be set to
class/realm, or an arbitrary value.

Slash commands
--------------

Tab completion for slash commands is available. Default values are in square
brackets at the end of the description.

    * /clubdead: usage help

    * /clubdead autochannel: turns on auto-channel mode, which sets the
    channel to your guild name suffixed by "Dead". If you are not guilded,
    autochannel mode cannot be turned on

    * /clubdead autojoin: toggles auto-join to channel on death [on]

    * /clubdead autoleave: toggle channel leave on rez [on]

    * /clubdead channel: sets the channel name to join

    * /clubdead chatframe: sets the chat frame that the channel will be made
    visible in when you join. If you have multiple chat windows and
    selectively enable channels in each, then newly joined channels are
    normally set to invisible. The default should suffice; if you need to
    change this it will typically be to something like "ChatFrame2" or
    "ChatFrame3" [ChatFrame1]

    * /clubdead guildraidonly: sets the addon to only activate when the
    leader of the raid is in your guild (or you are the leader). [I][off]

    * /clubdead report: a simple dump of some internal state. If you have
    problems, try running this at various points (when you're alive, after
    you die, after you release, when you're rezzed, etc) to assist in
    tracking down a bug

    * /clubdead wit: toggle witty rejoinders on join/leave [on]

    * /clubdead profile: set the Ace2 profile to store settings in [char]

    * /clubdead standby: toggle Ace2 standby/active mode

    * /clubdead debug: toggle debugging. Only enable to collect information
    for a bug report if you have problems

    * /clubdead about: information about the addon

There is also a FuBar2 plugin that lets you see the internal status (similar
to /clubdead report) and set the same options as the slash commands

TODO
----

    * continue to expand the list of witty sayings.  Now up to 14 and 7

    * improve "guild raid" detection. Sometimes asking for the raid leader's
    guild name returns nil for some reason

    * get localizations (ClubDead is an Ace2 addon using AceLocale, so if
    you are familiar with the process for localizing such addons, just send
    me a lua file for your locale)
