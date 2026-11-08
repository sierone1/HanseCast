# Hanse Cast 1.0.0 — Menu guide

Open Escape → Options/Settings → AddOns → Hanse Cast, or type `/hansecast`. The standalone fallback uses the same settings when the native Settings API is unavailable.

## Four tabs

- **Player:** category, theme group, manual appearance, automatic spell appearance, width, height, scale, GCD, completion pulse and optional Blizzard player bar replacement. **More settings** reveals accents, emblem, coordinates, text, opacity, icons, latency and manual channel guides.
- **Target & focus:** choose a bar first; its appearance, position and visibility are independent. Blizzard unit frames are preserved.
- **Profiles:** select, activate, create, copy, export, import, delete and reset.
- **Help:** language, quick start, display limitations, event demo and diagnostic chat output.

Hover over a setting or control for an explanation. Changes apply immediately to the active profile. Numeric fields: Enter applies, Escape discards the current edit. Dimensions use UI units. Editing is locked in combat.

## Original preview and positioning

The embedded preview uses the addon's original textures and shared effect renderer in an independent instance. It shows the manually chosen style with a simulated three-second cast and scales down to fit. It is an artwork preview, not an exact preview of every text, icon or extra indicator. It does not move the live player bar or replace its active cast. Animation stops when the menu is hidden, another tab is selected or combat begins.

**Position** hides the settings window and shows the existing in-game preview. Drag with the left mouse button. **Done — return to settings** locks the bar and reopens the menu. Escape or combat stops positioning. Target/focus preview only shows the selected bar and does not permanently enable disabled bars.

## Appearance

Category selects the effect structure. Theme group and manual appearance are independent of your character class. Automatic appearance applies only to recognized, accessible spells. Faction artwork stays fixed and preserves the automatic preference; faction selection initially selects its matching emblem. Unknown spells use the manual choice. Class colour changes secondary accents.

## Profiles and preservation

The top-right selector immediately activates a profile. On the Profiles tab, selecting a name alone does not activate it; use Activate. Up to twelve account-wide profiles are supported. New profile creates defaults; Copy duplicates the active profile. Export always exports the active profile.

Import: paste text, Check, then import as a new named profile or explicitly confirm replacing the active profile. Validation alone makes no changes. Editing the import text invalidates the check. Invalid or duplicate names and full profile storage do not create partial profiles. Delete/reset confirmations name their target. Reset activates that profile with default settings. Reset player position affects only the player position.

Existing 0.9.1/0.10.0 profiles, SavedVariables schema and HANSECAST:1 exports remain compatible. Do not delete SavedVariables for this update.

## Limits

Unavailable or restricted spell data may prevent custom display; empower spells are unsupported. Channel guides are manual divisions, not detected damage/healing ticks. Latency is guidance, not an exact input queue window. The custom settings canvas has no full-text search. Automated mock-API tests supplement, but do not replace, real-client verification.
