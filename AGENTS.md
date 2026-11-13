# AGENTS.md

Live macOS [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) config. This directory *is* `~/.hammerspoon`, so edits affect the running desktop after reload. Lua, no build system, no tests, no lint/CI.

## Layout

- `init.lua` — only entrypoint. Each feature is `require`d and immediately `start()`ed here.
- `modules/<name>.lua` — each returns a table `M` with idempotent `start()` (stops any existing watcher first) and `stop()`.
- `Spoons/` — empty placeholder for Hammerspoon Spoons; nothing loads it today.

Adding a feature: create `modules/<name>.lua`, then add `require` + `start()` to `init.lua`. Nothing auto-discovers modules.

## Verify changes

- Reload: `hs -c 'hs.reload()'` (equivalents: menu bar → Reload Config). Requires Hammerspoon running with IPC; if it fails with "can't access Hammerspoon message port", ask the user to reload manually.
- Lua errors only surface in the Hammerspoon Console after reload; `hs -c 'hs.openConsole()'` opens it.
- Eventtap behavior (keypresses, input source switching) cannot be tested headlessly — it needs real keystrokes plus Accessibility/Input Monitoring permission. After editing, tell the user what to press and what to expect. Do not claim it works without that.
- No `lua`/`luac` on PATH, so there is no offline syntax check; a reload is the syntax check.

## Gotchas

- Handlers return `false` to pass the event through. `modules/keyreplace.lua` is the exception: it returns `true` for a matched rule and re-injects the replacement with `hs.eventtap.keyStrokes`. A new watcher must not swallow keys it doesn't own.
- `keyreplace.lua` rules use raw macOS virtual keycodes (`50` = backtick, `41` = semicolon) and `event:getFlags()`. The `… -> :` rule's keycode is a placeholder tied to the user's layout; don't treat it as authoritative. The `·` → backtick mapping requires no modifiers.
- `shiftswitch.lua` hardcodes input source IDs (`com.apple.inputmethod.SCIM.Shuangpin` is machine-specific). Check with `hs.keycodes.currentSourceID()`. A quick Shift press (< `TAP_SECONDS`, 0.25 s) toggles sources; Shift used as a modifier or during another keypress must stay inert.
- Comments and user-facing `hs.alert` messages are Chinese. Keep that style.
- `LICENCE` (British spelling) is AGPL-3.0; the README links `LICENSE`.

## Commits

Conventional commits with scope: `feat(shiftswitch): switch input source on Shift tap`, `refactor(keyreplace): extract key replacement into module`. English subject, Chinese comments are fine.
