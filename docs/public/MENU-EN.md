# Menu guide

Open `/hansecast` outside combat. The subtitle shows the manually selected category and visual. A dot marks the selected button. Buttons ending in `>` cycle through their available choices.

## Main settings

| Control | What it does |
| --- | --- |
| Element Stream / Shards & Sparks / Silk Flow / Pulse / Mist Light | Selects the visual category. This changes artwork, not spell behavior or duration. |
| Material | Cycles through the nine class-inspired groups and Factions. It does not restrict your character's class. |
| Frost / Fire / Arcane, or the corresponding group choices | Selects a visual within the chosen group. The Factions group offers Alliance and Horde. |
| Automatic / Manual spell appearance | Automatic uses matching visuals for supported accessible spell IDs. Manual keeps your chosen visual. Unknown spells and previews retain the manual selection. |
| Fixed faction style | Faction artwork stays fixed during casts. The saved automatic setting resumes when a class-inspired visual is selected. |
| Neutral / Class accents | Class adds a subtle character-class tint to secondary accents. The main artwork colors remain unchanged. |
| Faction emblem: Neutral / Alliance / Horde | Chooses the optional native emblem beside the player bar. Neutral hides it; it does not change your character's faction. |
| Start preview / move position | Shows an artificial bar. Hold the left mouse button to drag it into position. |
| End preview / lock position | Ends the preview and locks dragging. Use real spells to check the live display. |
| Width / Height / Scale | Adjusts bar dimensions. Actual screen size also depends on WoW UI scaling, and very small combinations are constrained. |
| Global cooldown | Toggles the separate GCD line. Instant abilities do not need a fabricated cast bar. |
| Finish light | Toggles the additional brief completion light effect. |
| Replace Blizzard cast bar | Allows hiding the default player cast bar during an active Hanse cast when safe. The standard display remains available as fallback. Blizzard target/focus frames are not replaced. |
| Reset position | Resets only the player bar's position, not all appearance settings or profiles. |
| Advanced / Profiles | Opens Comfort, Profiles and Target / Focus settings. |

## Comfort

Choose automatic/German/English language, font and font size, time display, opacity and icon position. Time can show remaining time, elapsed time, both or neither.

The optional latency marker uses reported world latency, not an exact input or queue window. Channel guide lines and their segment count are manual visual aids, not detected damage/healing ticks.

## Profiles

Select a profile with the top button; `*` marks the active profile. Switch activates the selected profile.

- **New profile:** creates and activates a named profile with default values.
- **Create copy:** creates and activates a named copy of your current settings.
- **Delete:** removes the selected profile after a second confirmation click. The last profile cannot be deleted.
- **Reset:** resets the selected profile after confirmation. This affects more than Reset position in the main panel.
- **Export:** writes the active profile's settings into the text box for copying.
- **Check import:** validates pasted text without applying it.
- **Apply import:** applies the previously checked settings. Make a profile copy first if you want to retain your current layout. Editing the text requires another validation.

Up to twelve profiles are supported. Persistence of the tested profiles, position and appearance after reload and full restart has been confirmed.

## Target / Focus

Select Target or Focus first. The following controls apply to that unit's bar: enable, visibility, icon, material, appearance, width, height, scale and X/Y position. Inherit uses the corresponding player-bar selection.

Always permits matching casts outside combat; it does not force an empty bar to stay visible. Target/focus preview shows artificial bars for positioning, not proof that live enemy cast data is accessible.

## Quick setup

Choose a category, material group and visual. Set spell appearance to Manual for a fixed look. Start preview, move/size the bar, end preview and cast a real spell. Add other options one at a time.

`/hansecast demo` shows artificial timing and interruption examples. `/hansecast status` shows diagnostics. Demo output is not a live-game test.
