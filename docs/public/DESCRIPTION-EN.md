# Hanse Cast

**Your casts. Your style.** Hanse Cast brings animated cast bars and class-inspired artwork to **WoW Forever 1.60.1**. Follow your own casts and channels, track the global cooldown, and place each display where it fits your interface. Target and focus are currently disabled and marked as in development.

## Appearance

Choose from **145 visual variants**: 27 class-inspired styles and two faction-inspired styles, each available in five visual categories. All styles can be selected regardless of your character's class or faction. Artwork is revealed as a cast progresses without stretching the painted shapes.

## Features

- Player casts and channels with spell names, progress and configurable time display.
- Separate global cooldown indicator, including supported instant-cast abilities.
- Cast interruption and failure feedback when the required data is accessible.
- Configurable size, position, opacity, font and spell-icon placement.
- Up to twelve named profiles, with validated text import and export.
- German and English interface.
- Optional spell-based visual selection; unknown spells keep your manual selection.
- Appearance browser with filters and up to 20 favourites per profile.
- Simple, Readable and Quiet comfort presets that preserve position and artwork.
- Reduced motion mode without decorative motion or extra light pulses.
- Optional world-latency marker, cast-start delay estimate and separate queue setting indicator.
- Manual channel guide lines; no automatic tick detection.
- No additional addon or runtime library required.

## Getting started

Install the addon and fully restart WoW. Open **Settings → AddOns → Hanse Cast**, or type `/hansecast`.

The compact menu has four tabs: **Player**, **Target & focus**, **Profiles**, and **Help**. Frequently used settings are visible immediately; expand **More settings** for text, icons and fine adjustments. Hover over a setting for an explanation. The animated menu sample uses the addon's original textures and renderer; it reflects the manual artwork selection, font, time format and icon position, scaled down as needed. It does not invent live start-delay or queue measurements.

Use **Position** to place a bar in the game world, then **Done – back to settings** to lock it and return. Target and focus are disabled in both the menu and runtime; separate compact bars are planned. Changes apply immediately to the active profile. Settings changes are locked during combat.

- `/hansecast` - Open settings.
- `/hansecast test` - Toggle the player-bar preview.
- `/hansecast units` - Show the development status; previews are disabled.
- `/hansecast diagnose` - Compact diagnostics including optional comfort indicators.
- `/hansecast status` - Show version and diagnostic information.

Fully restart WoW after updating from 1.0.4 or earlier, because a Lua module has been added. Preserve SavedVariables.

For manual installation, extract the `HanseCast` folder into `Interface/AddOns`. The resulting path must be `Interface/AddOns/HanseCast/HanseCast.toc`.

## Compatibility and limits

**Version 1.0.5 targets WoW Forever 1.60.1, interface 16001.** Other WoW editions are not currently supported by this package.

36 local simulated-client suites check the release. The alpha.3 candidate also passed 5,000 simulated controller cycles, and the user reported the bundled in-game checks successful on 8 November 2026. Version 1.0.5 preserves that behaviour. These checks do not cover every class, spell, display scale or addon combination and do not establish a native FPS improvement.

The player bar requires readable timing. Target and focus are fully disabled; previous settings are retained. Empower casts are unsupported. Channel guides are manual markers. The latency marker is guidance based on reported world latency. The separate start estimate uses safely matched local events, not exact server latency. A cyan queue guide below the bar reflects a read-only client setting. Missing or inaccessible data leaves these indicators unavailable.

The optional replacement of the default player cast bar is disabled initially. Blizzard target and focus frames are left in place. When testing alongside another cast-bar addon, temporarily disable the other cast-bar addon to avoid overlapping displays.

Settings and profiles are saved account-wide. Updating the addon does not require deleting saved settings. Back up your SavedVariables before deliberately removing or resetting saved profiles.

## Feedback

Please use the project comments to report issues. Include your Hanse Cast version, WoW version, steps to reproduce the issue, other active cast-bar/interface addons, and the full Lua error text if present. Screenshots or a short video help with visual issues. Remove private chat or account information before sharing.

## Credits and license

Created by **Hanse**. Custom artwork and the logo were developed with AI assistance and prepared for this project. Any preview composed outside WoW is labelled as a software composition rather than an in-game screenshot.

Free to use. **All Rights Reserved**; see the included license. World of Warcraft and Blizzard resources belong to their respective owners. Hanse Cast is an independent community project.
