# Hanse Cast 1.0.5 – Menu guide

Open **Escape → Options/Settings → AddOns → Hanse Cast**, or type `/hansecast`. The standalone fallback provides the same controls when the native Settings API is unavailable. The active profile is shown at the top; normal edits apply immediately. Editing is locked in combat.

## Four tabs

- **Player:** appearance browser, filters, favourites, category/theme group, size and common display options. **More settings** reveals comfort presets, font, time format, icons, reduced motion, optional indicators and exact position.
- **Target & focus (in development):** disabled and greyed out. Separate compact bars are planned.
- **Profiles:** select, activate, create, copy, export, import, delete and reset.
- **Help:** language, quick start, limits, event demo and diagnostic output.

Hover for help. Numeric fields: Enter applies, Escape discards the current edit. Dimensions use UI units rather than necessarily physical pixels.

## Appearances and favourites

Browse all **145 category/appearance combinations**. Filter by all appearances, current theme group or favourites. Filtering never changes the active selection. A selection outside the filter is labelled accordingly; an empty favourite list leaves the selector unavailable.

Use **Save favourite** or **Remove favourite** to keep up to 20 combinations per profile. Favourites survive profile switches and export/import. The separate category, group and manual appearance selectors remain available.

Automatic appearance applies only to known, accessible spells. Unknown spells and previews use the manual selection. Faction artwork stays fixed and preserves the automatic preference; selecting it initially sets the matching emblem, which can then be changed separately. Class colour changes secondary accents, not the main colour.

## Comfort presets and indicators

Presets require confirmation and change only the listed comfort values. Position, size, scale, artwork, favourites and Blizzard replacement are preserved:

- **Simple:** standard font 12, remaining time, icon hidden, reduced motion off, completion pulse on; optional guides off.
- **Readable:** modern font 16, both times, left icon, reduced motion off and completion pulse on. Other guides keep their existing values.
- **Quiet:** reduced motion on, completion pulse off, remaining time, icon and optional guides off. Font choice is preserved.

**Reduced motion** stops decorative movement and extra light pulses. Cast progress remains live and cancellation/failure text remains readable.

**Latency marker:** reported world latency as guidance above the bar. **Cast start delay estimate:** “Start ~… ms” from safely matched local send/start events, not exact server latency. **Spell queue window:** cyan line below the bar showing the read-only client setting. Hanse never changes that setting. Start/queue indicators default to off; missing or inaccessible values are not guessed. `/hansecast diagnose` reports their status.

**Channel guides** are manually chosen equal divisions, not observed damage/healing ticks. Automatic tick markers are not enabled.

## Preview and positioning

The embedded preview uses original artwork and a synthetic three-second cast. It reflects font, font size, time format, icon position and reduced motion, scaling down to fit. The icon is a sample icon. It does not invent real start-delay or queue measurements and never moves the live bar. Animation stops when the menu is hidden, another tab is selected or combat starts.

**Position** hides the menu and opens the movable player preview. Drag with the left mouse button; **Done – back to settings** locks the position and returns. Escape or combat ends preview. **Centre horizontally** changes only the horizontal coordinate, preserving vertical position and artwork. Target/focus previews are disabled.

## Profiles

Up to twelve account-wide profiles. The top-right selector activates immediately. On the Profiles tab, select a name and use **Activate**. New profile starts with defaults; Copy duplicates the active profile. Export uses the active profile.

Import: paste → Check → import under a new name or confirm replacing the active profile. Checking alone changes nothing. Editing invalidates the check. Invalid/duplicate names and full storage do not create partial profiles. Delete/reset confirmations name their target. **Reset player position** affects only position.

Existing settings and HANSECAST:1 exports remain supported. Do not delete SavedVariables. Fully restart WoW after updating from 1.0.4 or earlier.

## Limits

Missing or restricted timing data can prevent custom player display. No empower support or automatic tick detection. The browser has filters but no full-text search. Target/focus remain disabled; `/hansecast units` only reports the development status.
