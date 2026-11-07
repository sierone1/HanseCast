# Hanse Cast

**Your casts. Your style.** Hanse Cast brings animated cast bars and class-inspired artwork to **WoW Forever 1.60.1**. Follow your own casts and channels, track the global cooldown, and place each display where it fits your interface. Optional target and focus bars extend the same look to other units.

## Appearance

Choose from **145 visual variants**: 27 class-inspired styles and two faction-inspired styles, each available in five visual categories. All styles can be selected regardless of your character's class or faction. Artwork is revealed as a cast progresses without stretching the painted shapes.

## Features

- Player casts and channels with spell names, progress and configurable time display.
- Separate global cooldown indicator, including supported instant-cast abilities.
- Optional target and focus cast bars with independent positions and sizes.
- Cast interruption and failure feedback when the required data is accessible.
- Configurable size, position, opacity, font and spell-icon placement.
- Up to twelve named profiles, with validated text import and export.
- German and English interface.
- Optional spell-based visual selection; unknown spells keep your manual selection.
- Optional latency marker and manually configured channel guide lines.
- No additional addon or runtime library required.

## Getting started

Install the addon and fully restart WoW. Type `/hansecast` to open its settings. Enable the preview, drag the bar into place and lock it again. Target and focus bars are disabled initially and can be enabled in the advanced settings.

- `/hansecast` - Open settings.
- `/hansecast test` - Toggle the player-bar preview.
- `/hansecast units` - Toggle target and focus previews.
- `/hansecast status` - Show version and diagnostic information.

For manual installation, extract the `HanseCast` folder into `Interface/AddOns`. The resulting path must be `Interface/AddOns/HanseCast/HanseCast.toc`.

## Compatibility and limits

**Version 0.9.1 is a beta build for WoW Forever 1.60.1, interface 16001.** Other WoW editions are not currently supported by this package.

The player bar has been used in real gameplay. Initial performance comparisons on the author's test PC and persistence of the tested settings after reload and restart have been checked. Broader class, style and target/focus coverage remains part of beta testing. Performance on every system is not guaranteed.

Hanse Cast uses accessible game data. If required cast information is restricted or unavailable, the affected custom display is hidden. Fully restricted duration objects are not displayed directly. Channel guide lines are manual markers, not detected damage or healing ticks. Empower casts are not supported in this build. The latency marker indicates reported network latency, not an exact input or spell-queue window.

The optional replacement of the default player cast bar is disabled initially. Blizzard target and focus frames are left in place. When testing alongside another cast-bar addon, temporarily disable the other cast-bar addon to avoid overlapping displays.

Settings and profiles are saved account-wide. Updating the addon does not require deleting saved settings. Back up your SavedVariables before deliberately removing or resetting saved profiles.

## Feedback

Please use the project comments to report issues. Include your Hanse Cast version, WoW version, steps to reproduce the issue, other active cast-bar/interface addons, and the full Lua error text if present. Screenshots or a short video help with visual issues. Remove private chat or account information before sharing.

## Credits and license

Created by **Hanse**. Custom artwork and the logo were developed with AI assistance and prepared for this project. Any preview composed outside WoW is labelled as a software composition rather than an in-game screenshot.

Free to use. **All Rights Reserved**; see the included license. World of Warcraft and Blizzard resources belong to their respective owners. Hanse Cast is an independent community project.
