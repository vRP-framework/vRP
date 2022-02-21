ifdef::env-github[]
:tip-caption: :bulb:
:note-caption: :information_source:
:important-caption: :heavy_exclamation_mark:
:caution-caption: :fire:
:warning-caption: :warning:
endif::[]

= vRP

[.left]
image::misc/logo_alpha.png[vRP,300]

_FiveM RP addon/framework_ +
The project aims to create a generic and simple RP framework to prevent everyone from reinventing the wheel. +
Contributions are welcomed.


http://discord.gg/xzGZBAb[Discord]

https://forum.fivem.net/t/release-vrp-framework/22894[FiveM forum thread]

NOTE: This is vRP 2, the second major version of vRP. It aims to have less overhead and a more straightforward and structured approach using OOP. This will probably be the last major version, vRP based resources can be updated for vRP 2 using the extension system.

.Features
* basic admin tools (kick,ban,whitelist), groups/permissions, languages, identification system (persistent user id for database storage), user/character/server/global custom data key/value
* player state (survival vitals, weapons, player appearance, position)
* player identity/phone/aptitudes (education/exp), emotes, business system / money (wallet/bank), homes
* cloakrooms (uniform for jobs), basic police (PC, check, I.D., handcuff, jails, seize weapons/items), basic emergency (coma, reanimate)
* inventory (with custom item definition, parametric items), chests (vehicle trunks), transformer (harvest, process, produce) (illegal informer)
* basic implementations: ATM, market, shops, skinshop, garage
* GUI (dynamic menu, progress bars, prompt), map entities (blip, markers), areas (enter/leave callbacks)
* database MySQL "driver" system to interface to any MySQL resources
* OOP design, more structured code and less overhead
* proxy for easy inter-resource development, tunnel for easy server/clients communication
* Lua profiler
* ...

== Documentation

Online: https://vrp-framework.github.io/vRP

.Offline:
- `git worktree add gh-pages gh-pages`
- open the `gh-pages` directory from a browser

.See also (and use it as a basis to understand how to develop extensions for vRP):
* https://github.com/vRP-framework/vRP-db-drivers (some maintained DB drivers)
* https://github.com/vRP-framework/vRP-basic-mission (repair/delivery missions extension)
* https://github.com/ImagicTheCat/vRP-TCG (Trading Card Game extension)

=== Issues / Features / Help

WARNING: Read the documentation before asking for help, creating a bug report or a feature request.

When submitting an issue, add any information you can find, with all details. Saying that something doesn't work will probably not be enough to solve the issue.
If you have errors in your console _before_ the issue happens, things could be corrupted, so the issue may be irrelevant. You should solve all unrelated errors before submitting issues.

When submitting a feature request, make sure the feature is relevant about the core of the framework or already existing vRP features. vRP is a framework, thus it doesn't aim to implement everything, but to give the tools to do so.

WARNING: The issue section is only for bug reports and feature requests. Issues not related to the core of vRP, about old versions (no backwards update) or vRP modifications will be closed without warning.

TIP: Before submitting an issue or a feature request, do a search in open and closed ones to know if it has been reported/requested before.

NOTE: For questions, help, discussions around the project, please go instead on the vRP thread of the FiveM forum or the discord.

== Credits

.Sounds
[horizontal]
radio:: https://freesound.org/people/JustinBW/sounds/70107/
phone sms:: https://freesound.org/people/SpiceProgram/sounds/399191/
phone ringing:: https://freesound.org/people/Framing_Noise/sounds/223183/
phone dialing:: https://freesound.org/people/Felfa/sounds/178823/
drinking:: https://freesound.org/people/freakinbehemoth/sounds/243635/
eating:: https://freesound.org/people/ryanharding95/sounds/272440/
