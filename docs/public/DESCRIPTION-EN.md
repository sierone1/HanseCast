# Hanse Cast – English

Animated player cast bars and compact target/focus cast bars for **WoW Forever 1.60.1**.

## Player cast bar

145 visual variants across five families: Element Stream, Splinters & Sparks, Silk Flow, Pulse and Mistlight. Class-inspired and Alliance/Horde artwork can be selected independently of your character's class. Holy and Discipline artwork has been revised for 1.0.6.

Customize position, size, fonts, time display and icon placement. Includes a separate GCD indicator, favorites, up to twelve named profiles with copy/rename and validated text import/export, comfort presets and reduced motion. Optional latency, cast-start estimate and spell queue indicators remain separate; the queue display does not change client settings.

## Target and focus

Three compact designs: **Classic**, **Silk core**, **Split label**. Black borders, menu previews and separate target/focus positioning. Choose a shared main color using the native WoW picker or ten named swatches. Optional remaining time inside right or outside right. Blizzard target/focus cast bars can be hidden separately while Hanse can reliably provide its own display.

Only target and focus, including selected pets. No extra pet or target-of-target bars. Designs and shared color are identical across classes; these preferences are independent of player profiles.

## Installation and controls

Extract the `HanseCast` folder into `Interface/AddOns`, with `HanseCast.toc` directly inside it. Fully restart WoW after an update. Saved preferences are preserved. A separate Hanse Cast Compact Lab is unnecessary; disable it if installed.

`/hansecast` opens Player, Target & focus, Profiles and Help. Preview and positioning are available in the menu. Changes apply immediately; the color picker supports confirm/cancel. Settings changes are locked during combat.

- `/hansecast test`: player preview.
- `/hccompact`: target/focus settings.
- `/hansecast diagnose`: brief diagnostics.
- `/hansecast report`: copyable diagnostic report.

## Compatibility and limitations

Version **1.0.6**, Forever **1.60.1**, interface **16001**. Compact unit bars currently require build **70862**. Other WoW editions and empowered spells are not supported. No additional library required. German and English UI.

Unavailable permitted time data is shown as a dash. Player bars require accessible timestamps; supported native duration objects drive unit/GCD timers. Automatic channel ticks are not enabled; channel guides are manual aids. Other cast-bar addons may produce overlapping displays.

The user accepted the recent alpha features overall; 54 automated suites exercise simulated interfaces. This does not guarantee every class, spell or addon combination.

[Source and issue reports](https://github.com/sierone1/HanseCast) · All Rights Reserved. Not affiliated with or endorsed by Blizzard.
