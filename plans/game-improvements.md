# Plan: Research-Driven Game Improvements

*Based on `research/idle_game_progression.md`*

## Context

The research synthesises idle game design literature to identify seven concrete gaps in Florin Cards. Priority reflects D1 → D7 → D30 retention impact.

---

## Improvements (Priority Order)

### 1. Welcome Bonus — First Pack Timing (D1, High Impact)
Grant a one-time 50 fl welcome bonus on first launch. Gets the first Basic Pack within ~10 minutes.
- **SaveManager.gd** — In `load_save()` when no save file exists: `add_florins(50)` + welcome log message.

### 2. Soft Pity System (D7, High Impact)
Track `pity_counter`. After 8 packs without an ultra/secret/legendary, boost ultra+secret weights by +10% per additional pack (ultra 70%, secret 30% split). Reset on any ultra+ pull. Floored so rare weight never drops below 22%.
- **GameState.gd** — Add `pity_counter: int = 0`, reset in `initialize()`.
- **SaveManager.gd** — Save/load `pity_counter`.
- **PackLogic.gd** — Pass counter into `_roll_rare_rarity()`. Update counter in `open_pack()` after resolving all cards.

### 3. Tiered Dupe Selling (All Stages, Medium Impact)
Add 10 dupes → 20 fl option alongside the existing 50 → 100 fl. Maintains 2 fl per dupe rate.
- **GameState.gd** — `sell_dupes(batch_size: int = 50)` accepts parameter. Rate: `batch_size * 2.0 fl` per set.
- **Main.gd** — Add `_btn_sell_small` button. Both buttons update in `_update_collection_summary()`.

### 4. Offline Earnings Banner (Re-engagement, Medium Impact)
Replace the quiet Field Note with a prominent banner that auto-fades after 4 seconds.
- **SaveManager.gd** — Store `pending_offline = {amount, seconds}` on GameState instead of logging immediately.
- **Main.gd** — After `_full_refresh()` in `_ready()`, check `pending_offline` and show a blue banner in `_float_layer`.

### 5. Locked Chore Teasers (Mid-game, Medium Impact)
Show the next 2 locked chores as greyed-out rows with unlock requirements, instead of hiding them entirely.
- **Main.gd** — In `_update_chores()`, show next 2 locked chores with lbl_rate = "🔒 Unlocks at X fl earned", disabled button, greyed modulate.

### 6. God Pack & Double Rare Presentation (Emotional, High Value)
Flash a coloured banner before the card reveal animation. God Pack: gold, slower card stagger. Double Rare: purple, shorter flash.
- **Main.gd** — In `_show_pack_reveal()`, create a timed banner in `_float_layer` for special events before cards animate in.

### 7. Pack Tier Unlock Celebration (Milestone Moments, Medium Impact)
Announce Silver/Gold/Legendary Pack unlocks with a banner + Field Note on first unlock.
- **GameState.gd** — Add `packs_announced: Array = []`.
- **SaveManager.gd** — Save/load `packs_announced`.
- **Main.gd** — In `_update_packs()`, detect first unlock and show green banner + log entry.

### 8. Set Completion Bonuses (Future Feature — Out of Scope)
Completing all cards in a rarity tier unlocks a fl/sec bonus. Requires balance design before coding.

---

## Files Modified
| File | Changes |
|------|---------|
| `scripts/GameState.gd` | `pity_counter`, `packs_announced`, `pending_offline` vars; `sell_dupes(batch_size)` |
| `scripts/SaveManager.gd` | Welcome bonus; pity/packs_announced save/load; pending_offline storage |
| `scripts/PackLogic.gd` | Pity boost in `_roll_rare_rarity()`; counter update in `open_pack()` |
| `scripts/Main.gd` | Two-tier dupe buttons; offline banner; chore teasers; event banners; tier unlock banner |
