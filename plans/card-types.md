# Plan: Card Type System

## Overview

Add a `type` field to every card (Fire, Water, Wind, Earth, Light, Dark). Each type has its own colour palette that drives the big card background, art panel background, and footer text contrast. The type name replaces the `"—"` placeholder in the card header.

---

## Type Colour Palette

| Type  | Card Background | Art Panel BG   | Footer Text | Type Label (on white) |
|-------|----------------|----------------|-------------|----------------------|
| Fire  | `#C0392B`      | `#F0A28A`      | White       | `#C0392B`            |
| Water | `#2471A3`      | `#85C1E9`      | White       | `#2471A3`            |
| Wind  | `#85C1E9`      | `#D5EAF5`      | **Dark**    | `#5D8AA8`            |
| Earth | `#7D5A3C`      | `#C4A882`      | White       | `#7D5A3C`            |
| Light | `#D4AC0D`      | `#FAE89A`      | **Dark**    | `#B7860B`            |
| Dark  | `#1C2833`      | `#4A4E69`      | White       | `#4A4E69`            |

> Wind and Light have light backgrounds — footer text must be dark (`#1A1A1A`) to remain readable. All other types use white footer text.

The section panels (card name/art box, stats/moves box) remain **white** on all types — they always contrast against the coloured card background.

---

## Card → Type Assignments

76 cards split across 6 types (13 / 12 / 13 / 13 / 13 / 12).

### Fire — 13 cards
| Rarity | Cards |
|--------|-------|
| Common | Grumplet, Sparktail, Flampling, Fizzwick |
| Uncommon | Emberpaw, Thundertail, Ashwhisker, Boulderpaw, Cinderkit |
| Rare | Blazethorn, Pyrespine, Crimsontail |
| Secret Rare | Solarispine |

### Water — 12 cards
| Rarity | Cards |
|--------|-------|
| Common | Snorkel, Wobblefin, Frogling, Shellsworth, Gloopfish, Blubbersnap, Squelchmore |
| Uncommon | Glacierpup, Tidesnout |
| Rare | Aquashade, Tidecrest |
| Ultra Rare | Spectralfin |

### Wind — 13 cards
| Rarity | Cards |
|--------|-------|
| Common | Fluffalo, Twiglet, Driftpuff, Whiskerbean, Noodlewing, Snuffleton |
| Uncommon | Vortexkit, Stormtail, Mistfang |
| Rare | Galewing, Stormveil |
| Ultra Rare | Eclipsewing |
| Secret Rare | Aethermaw |

### Earth — 13 cards
| Rarity | Cards |
|--------|-------|
| Common | Munchkin, Rootsnap, Pebblesnout, Puddingfoot, Pamplemoose, Grumbleleaf |
| Uncommon | Mossmaw, Stoneback, Brambleclaw, Thornback |
| Rare | Terraveil, Stonecrown, Ironmaw |

### Light — 13 cards
| Rarity | Cards |
|--------|-------|
| Common | Gleamoth, Crinklenose, Wobblebug, Bingleberry |
| Uncommon | Crystalfin, Frostveil |
| Rare | Dawnpetal |
| Ultra Rare | Auroraling, Prismback, Celestipaw, Luminescenthorn |
| Secret Rare | Infinipaw |
| Legendary | The Shimmering One |

### Dark — 12 cards
| Rarity | Cards |
|--------|-------|
| Common | Boulderbutt, Dozelington, Clodsworth |
| Uncommon | Duskwing, Cragfang, Cavewing, Dungeonpup |
| Rare | Shadowfang |
| Ultra Rare | Voidwhisker, Nebulaclaw |
| Secret Rare | Chronofang |
| Legendary | Omegaling |

---

## Files to Change

### 1. `scripts/CardDatabase.gd`

**Add** type constants after the rarity constants:
```gdscript
const TYPE_FIRE  = "fire"
const TYPE_WATER = "water"
const TYPE_WIND  = "wind"
const TYPE_EARTH = "earth"
const TYPE_LIGHT = "light"
const TYPE_DARK  = "dark"

const TYPE_LABELS = { ... }        # display name per type
const TYPE_COLORS = { ... }        # card background colour per type
const TYPE_ART_BG_COLORS = { ... } # art panel background (lighter shade)
const TYPE_LABEL_COLORS = { ... }  # type label colour (on white section panel)
const TYPE_FOOTER_TEXT_COLORS = { ... } # footer text colour (on card bg)
```

**Add** a flat `CARD_TYPES` dictionary mapping every card name string → type string (all 76 entries from the table above).

**Update** `_build_cards()` to add `"type": CARD_TYPES.get(card_name, TYPE_EARTH)` to each card dict.

---

### 2. `scripts/CardWidgets.gd` — `make_big_card()`

Replace the block that reads rarity colours with type colours for the card background and art panel:

| Current | New |
|---------|-----|
| `bc = border_color(rarity)` used as card bg | `CardDatabase.TYPE_COLORS[type]` as card bg |
| `bgc = bg_color(rarity)` used as art panel bg | `CardDatabase.TYPE_ART_BG_COLORS[type]` as art panel bg |

Update the type label in the header:
```gdscript
lbl_type.text = CardDatabase.TYPE_LABELS.get(type, "—")
lbl_type.add_theme_color_override("font_color",
    CardDatabase.TYPE_LABEL_COLORS.get(type, Color("#6B6B6B")))
```

Update all footer labels (`lbl_set`, `lbl_rarity`, `lbl_designer`, `lbl_illustrator`, `lbl_num`) to use `CardDatabase.TYPE_FOOTER_TEXT_COLORS[type]` instead of the current hardcoded white / semi-white.

---

### 3. `scripts/CardWidgets.gd` — `make_small_card()`

Currently uses `bc` (rarity border), `bgc` (rarity art bg), `tc` (rarity text). Replace all three with type equivalents:

| Role | Current | New |
|------|---------|-----|
| Card border | `border_color(rarity)` | `TYPE_COLORS[type]` |
| Art panel bg | `bg_color(rarity)` | `TYPE_ART_BG_COLORS[type]` |
| Art letter colour | `bc` | `TYPE_COLORS[type]` |
| Rarity label colour | `text_color(rarity)` | `TYPE_LABEL_COLORS[type]` |

The card root keeps its white background; the type colour appears as the border and art panel, consistent with the BigCard style. The rarity label text still shows the rarity name — only its colour changes.

---

### 4. `scripts/CardWidgets.gd` — `make_dex_card()`

Same substitution as SmallCard for **owned** cards. Unowned cards remain grey (type is not revealed for undiscovered cards, consistent with the `???` name treatment).

| Role | Current (owned) | New (owned) |
|------|----------------|-------------|
| Card border | `border_color(rarity)` | `TYPE_COLORS[type]` |
| Art panel bg | `bg_color(rarity)` | `TYPE_ART_BG_COLORS[type]` |
| Art letter colour | `bc` | `TYPE_COLORS[type]` |
| Name label colour | `text_color(rarity)` | `TYPE_LABEL_COLORS[type]` |

Unowned state: no change — grey border `#D0D0C8`, grey art bg `#F0F0EC`, grey text `#A0A0A0`.

---

## What Does NOT Change

- `PackLogic.gd`, `GameState.gd`, `SaveManager.gd` — no changes needed. Type is a display-only property derived from card data at runtime; it does not need to be saved.
- Floridex filters — type filtering is out of scope for this implementation.

---

## Verification

1. Open Godot, run the game, open a pack to pull cards.
2. Tap the Floridex button → tap an owned card → card viewer opens.
3. Confirm the card background matches the expected type colour (e.g. Frogling = Water = blue `#2471A3`).
4. Confirm the type name appears in the top-right of the name row (replacing `—`).
5. Check Wind and Light cards — footer text should be dark and readable.
6. Check Dark cards — section panels (white) should stand out clearly against the dark background.
7. Confirm rarity label still appears in the footer.
