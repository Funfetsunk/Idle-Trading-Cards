# Florin Cards — Godot 4 Project Brief
*For use with Claude Code. Read this before writing any code.*

---

## 1. Project Overview

**Florin Cards** is a mobile-first idle/clicker game for Android (iOS later) built in Godot 4. The player earns a fictional currency called **florins** by tapping and hiring passive income sources ("chores"). Florins are spent on **card packs** that reveal collectible trading cards. The core loop is: earn → spend → collect → repeat.

The game has a warm, charming tone — think pocket-money economics meets Pokémon card collecting. Art will be custom-illustrated; placeholder emoji art from the prototype should be replaced with `TextureRect` nodes pointing to asset paths.

---

## 2. Core Game Loop

```
Tap button → earn 0.1 fl
             ↓
     Passive income from hired chores (fl/sec)
             ↓
      Save up → buy card packs
             ↓
   Cards revealed → added to collection (Floridex)
             ↓
  Duplicates accumulate → sell 50 dupes for 100 fl
             ↓
        Buy luck upgrades → better pull rates
```

---

## 3. Currency & Numbers

- Currency name: **florins** (abbreviated `fl`)
- Starting florins: `0`
- Manual tap earns: `0.1 fl` per tap
- All numbers should be formatted:
  - `≥ 1,000,000,000` → `X.XXB`
  - `≥ 1,000,000` → `X.XXM`
  - `≥ 1,000` → `X.XK`
  - `≥ 10` → integer
  - `< 10` → one decimal place
- Track two balances separately:
  - `florins` — spendable, goes up and down
  - `total_earned` — lifetime total, never decreases (used for unlock gates)

---

## 4. Passive Income — Chores

Each chore provides `fl/sec` passively. Multiple copies of the same chore can be bought; each adds to the rate. Cost scales exponentially per purchase.

| ID | Name | Icon | Base cost | fl/sec each | Cost multiplier | Unlock (total earned) |
|----|------|------|-----------|-------------|-----------------|----------------------|
| sibling | Little sibling helper | custom art | 5 | 0.3 | ×1.15 | 0 |
| bins | Take out the bins | custom art | 30 | 1.1 | ×1.20 | 10 |
| dog | Walk the neighbour's dog | custom art | 180 | 5.0 | ×1.24 | 80 |
| lawn | Mow the lawn | custom art | 1,200 | 18 | ×1.27 | 500 |
| lemonade | Run a lemonade stand | custom art | 8,000 | 60 | ×1.30 | 3,000 |
| babysit | Babysitting round | custom art | 60,000 | 220 | ×1.32 | 20,000 |
| carwash | Neighbourhood car wash | custom art | 500,000 | 800 | ×1.35 | 150,000 |
| carboot | Car boot sale empire | custom art | 4,000,000 | 3,200 | ×1.38 | 1,500,000 |

**Cost formula:** `floor(base_cost × mult ^ count_owned)`

Chores are locked (shown as `???`) until `total_earned ≥ unlock_at`. Once unlocked, they become purchasable when `florins ≥ cost`.

---

## 5. Card Packs

Four pack tiers. Each pack contains 5 card slots. All florins earned (from taps, passive income, dupe sales) are simultaneously added to a **savings pool per pack type** — the player doesn't manually allocate; savings fill automatically and the pack becomes openable when savings ≥ cost.

### Pack Definitions

| ID | Label | Base cost | Scale factor | Scale every N packs | Unlock (total earned) |
|----|-------|-----------|--------------|---------------------|-----------------------|
| basic | Basic Pack | 300 | ×1.8 | 20 | 0 |
| silver | Silver Pack | 2,500 | ×2.0 | 15 | 5,000 |
| gold | Gold Pack | 15,000 | ×2.2 | 10 | 40,000 |
| legendary | Legendary Pack | 150,000 | ×2.5 | 5 | 400,000 |

**Cost formula:** `floor(base_cost × scale_factor ^ floor(packs_purchased / scale_every))`

### Pack Slot Composition

| Pack | Slot breakdown |
|------|---------------|
| Basic | 4 × common/uncommon pool + 1 × rare-or-better |
| Silver | 3 × uncommon guaranteed + 2 × rare-or-better |
| Gold | 3 × uncommon + 2 × rare-or-better (no commons ever) |
| Legendary | 5 × rare-or-better |

For common/uncommon slots: 28% chance of uncommon, 72% chance of common.

### Special Pack Events (rolled once per pack open)

| Event | Probability | Effect |
|-------|-------------|--------|
| God Pack | 0.1% | All 5 slots are rare-or-better |
| Double Rare | 4.5% | 2 slots rare-or-better, 3 slots common/uncommon |
| Normal | ~95.4% | Standard slot composition |

### Rare Slot Resolution — Rarity Weights

When a slot draws from the rare pool, roll against these weights (before upgrades):

| Rarity | Base weight |
|--------|-------------|
| Rare | 72% |
| Holo rare | 20% |
| Ultra rare | 7% |
| Secret rare | 1% |

**Per-pack boosts** are added to base weights:

| Pack | Holo boost | Ultra boost | Secret boost |
|------|-----------|-------------|--------------|
| Basic | 0 | 0 | 0 |
| Silver | +8% | 0 | 0 |
| Gold | +12% | +6% | 0 |
| Legendary | +15% | +12% | +4% |

After applying boosts, normalise all weights so they sum to 1.0 before rolling.

---

## 6. Card Collection (Floridex)

Total card pool: **76 unique cards** across 6 rarity tiers.

| Rarity | Count | Border colour | Art background |
|--------|-------|--------------|----------------|
| Common | 30 | Neutral | Neutral |
| Uncommon | 20 | Neutral | Neutral |
| Rare | 12 | `#EF9F27` (gold) | `#FAEEDA` |
| Holo Rare | 8 | `#7F77DD` (purple) | `#EEEDFE` |
| Ultra Rare | 4 | `#D85A30` (orange-red) | `#FAECE7` |
| Secret Rare | 2 | `#D4537E` (pink) | `#FBEAF0` |

### Card Data Structure

Each card has:
- `name` (string, unique)
- `rarity` (enum)
- `art` (Texture2D — custom artwork, placeholder during dev)
- `stats`: `health`, `attack`, `defence`, `luck` (integers, 0–100 range)
- `move_name` (string)
- `move_desc` (string)

**Stat generation** is deterministic/seeded per card (same card always has same stats). Use a seeded LCG: `s = (s × 1664525 + 1013904223) & 0xFFFFFFFF`. Seed from card index and rarity key. Stats are based on a rarity-specific base + range:

| Rarity | Stat base | Stat range |
|--------|-----------|-----------|
| Common | 20 | 25 |
| Uncommon | 30 | 30 |
| Rare | 45 | 35 |
| Holo | 55 | 35 |
| Ultra | 65 | 30 |
| Secret | 75 | 25 |

### Card Names (by rarity)

**Common (30):** Munchkin, Fluffalo, Snorkel, Wobblefin, Grumplet, Twiglet, Boulderbutt, Sparktail, Frogling, Driftpuff, Rootsnap, Gleamoth, Crinklenose, Shellsworth, Pebblesnout, Whiskerbean, Flampling, Gloopfish, Noodlewing, Blubbersnap, Puddingfoot, Squelchmore, Dozelington, Fizzwick, Pamplemoose, Grumbleleaf, Snuffleton, Wobblebug, Clodsworth, Bingleberry

**Uncommon (20):** Emberpaw, Crystalfin, Mossmaw, Thundertail, Glacierpup, Stoneback, Vortexkit, Duskwing, Brambleclaw, Tidesnout, Cragfang, Ashwhisker, Boulderpaw, Stormtail, Cinderkit, Mistfang, Thornback, Frostveil, Cavewing, Dungeonpup

**Rare (12):** Blazethorn, Aquashade, Terraveil, Galewing, Pyrespine, Tidecrest, Stonecrown, Stormveil, Shadowfang, Dawnpetal, Ironmaw, Crimsontail

**Holo (8):** Auroraling, Prismback, Celestipaw, Voidwhisker, Luminescenthorn, Spectralfin, Nebulaclaw, Eclipsewing

**Ultra (4):** Chronofang, Aethermaw, Infinipaw, Solarispine

**Secret (2):** Omegaling, The Shimmering One

### Moves

Each card has one signature move, assigned by position in the full card list (index maps to move list). 76 moves are defined — see the HTML source `MOVES` and `MOVE_DESCS` arrays for the full list. These should be stored in a `CardDatabase` resource.

### Collection Tracking

- `collected: Dictionary` — card name → count owned
- `duplicates: Dictionary` — rarity key → dupe count
- A card is a **duplicate** if the player already owns ≥1 copy when it is pulled
- Dupes are tracked per-rarity for display, but sold in aggregate

---

## 7. Dupe Selling

- Threshold: **50 dupes** (total, across all rarities) to sell
- Sell in sets of 50: `floor(total_dupes / 50)` sets
- Each set of 50 → `100 fl` earned
- Earnings from dupe sales are added to `florins`, `total_earned`, and all pack savings pools
- Partial remainder dupes are kept

---

## 8. Luck Upgrades

One-time purchases that permanently boost rare pull odds. Shown only when `total_earned ≥ unlock_at`.

| ID | Name | Description | Cost | Effect type | Effect value | Unlock at |
|----|------|-------------|------|-------------|--------------|-----------|
| u1 | Lucky bag | +5% holo chance | 600 | holo | +0.05 | 200 |
| u2 | Foil sleeve | +8% rare→uncommon weight reduction (rare becomes less common) | 3,000 | rare | +0.08 | 1,000 |
| u3 | Magnifying glass | +10% holo chance | 15,000 | holo | +0.10 | 6,000 |
| u4 | Price guide book | +12% rare weight reduction | 100,000 | rare | +0.12 | 40,000 |
| u5 | Special order | +6% ultra chance | 700,000 | ultra | +0.06 | 250,000 |
| u6 | Golden wrapper | +10% ultra chance | 5,000,000 | ultra | +0.10 | 1,800,000 |
| u7 | Secret card map | +3% secret chance | 40,000,000 | secret | +0.03 | 12,000,000 |

Upgrade bonuses stack additively. Applied during rare-slot weight calculation (see section 5).

---

## 9. Save System

- Auto-save every **30 seconds**
- Save on pack open, dupe sell, upgrade purchase
- Use Godot's `FileAccess` to write JSON to `user://save.json`
- Save state includes:
  - `florins`, `total_earned`, `tap_count`
  - `chore_counts[]` — array of integers, one per chore
  - `upgrades_bought[]` — array of booleans
  - `pack_state[]` — array of `{purchased, savings}` per pack type
  - `collected` — dictionary of card name → count
  - `duplicates` — dictionary of rarity key → dupe count
  - `log_lines[]` — last 5 field note strings
  - `saved_at` — Unix timestamp
- On load, calculate offline earnings: `elapsed_seconds × fl_per_sec` (cap at e.g. 8 hours)
- Reset option wipes all data (with confirmation dialog)

---

## 10. UI Screens & Scenes

### Main Screen (always visible)
- **Top bar:** Game title left, florin balance + rate + total earned right
- **Save bar:** Last save time left, Reset button right
- **Floridex button:** Full-width tap target showing collection progress `X / 76 cards`
- **"Do a chore" tap area:** Manual tap button with tap count
- **Hire help section:** Scrollable list of chores
- **Pack shop section:** Cards for each pack tier
- **Latest pull area:** Shows cards from most recent pack open (animated)
- **Luck upgrades grid:** 2–3 columns
- **Collection summary table:** Rarity rows with unique/total/dupe counts + sell button
- **Field notes log:** Last 5 event messages

### Floridex Overlay (full-screen overlay on main)
- Filter buttons by rarity at top
- Progress label `X / 76 cards collected`
- Grid of card thumbnails (4 columns) grouped by rarity section
- Unowned cards shown as greyed-out `???`
- Tap owned card → opens Card Viewer

### Card Viewer Overlay
- Full-width "big card" display
- Previous / Next navigation (only navigates to owned cards)
- Back button returns to Floridex

### Big Card Layout (used in viewer and pack reveal)
- Rarity label + HP stat in header
- Large art area (custom texture, full card width, ~130dp tall)
- Card name row with owned count
- Stats panel: Health, Attack, Defence, Luck — each with a coloured bar
  - Highest stat highlighted green, lowest highlighted red
- Move box: move name + description
- Footer: "Florin Cards" left, card number `#001 / 76` right
- Border colour matches rarity

### Pack Reveal (inline in main screen)
- 5 small card thumbnails animate in sequentially (pop-in with slight rotation)
- Each shows: art, name, rarity label, "dupe" label if duplicate
- Pack type badge shown above: Normal / Double Rare / God Pack

---

## 11. Animations & Feedback

- **Tap feedback:** Floating `+0.1 fl` label rises and fades at tap position
- **Card pop-in:** Scale from 0.5 + slight rotation to 1.0 over ~350ms, staggered 100ms per card
- **Pack progress bars:** Smooth transition on width change (~400ms)
- **Chore unlock:** Chore rows animate in when they unlock
- **God Pack / Double Rare:** Banner or flash effect on pack open
- **Card hover (Floridex):** Scale to 1.06 on hover/focus

---

## 12. Colour Palette

The game uses a clean, light-themed palette based on CSS variable names from the prototype. Map these to Godot theme colours:

| Role | Hex (approximate) |
|------|------------------|
| Primary text | `#1A1A1A` |
| Secondary text | `#6B6B6B` |
| Tertiary text | `#A0A0A0` |
| Background primary | `#FFFFFF` |
| Background secondary | `#F5F5F0` |
| Border tertiary | `#E5E5E0` |
| Border secondary | `#D0D0C8` |
| Florin blue | `#185FA5` |
| Success green | `#0F6E56` |
| Danger red | `#A32D2D` |
| Rare gold | `#854F0B` |
| Holo purple | `#534AB7` |
| Ultra orange | `#993C1D` |
| Secret pink | `#993556` |

---

## 13. Project Structure (Recommended)

```
res://
├── scenes/
│   ├── main/
│   │   ├── Main.tscn
│   │   ├── ChoreList.tscn
│   │   ├── PackShop.tscn
│   │   ├── UpgradesGrid.tscn
│   │   └── CollectionSummary.tscn
│   ├── overlays/
│   │   ├── Floridex.tscn
│   │   └── CardViewer.tscn
│   ├── cards/
│   │   ├── BigCard.tscn
│   │   ├── SmallCard.tscn      ← pack reveal thumbnail
│   │   └── DexCard.tscn        ← floridex grid thumbnail
│   └── ui/
│       └── ConfirmDialog.tscn
├── scripts/
│   ├── GameState.gd            ← singleton / autoload
│   ├── CardDatabase.gd         ← all card data, seeded stat generation
│   ├── PackLogic.gd            ← pack opening, weight rolling
│   ├── SaveManager.gd          ← save/load JSON
│   └── NumberFormatter.gd      ← fmt() utility
├── resources/
│   ├── cards/                  ← CardData resources (.tres)
│   └── theme/
│       └── FlorinTheme.tres
├── assets/
│   ├── cards/                  ← custom card artwork (PNG)
│   ├── chores/                 ← chore icons
│   └── ui/                     ← UI elements
└── autoloads/
    └── GameState.gd
```

**Autoloads:** `GameState` should be a singleton autoload. `SaveManager` and `CardDatabase` can be static or also autoloaded.

---

## 14. Godot-Specific Implementation Notes

- Target: **Godot 4.x**, GDScript
- Target resolution: **390×844** (iPhone 14 base), scale for Android with `stretch_mode = canvas_items` and `aspect = expand`
- Use `ScrollContainer` for chore list and upgrade grid — these get long
- Use `GridContainer` for the Floridex grid (4 columns)
- `AnimationPlayer` or `Tween` for card pop-in; prefer `Tween` for code-driven animations
- The game loop (`tick`) runs on `_process(delta)` in `GameState`; accumulate `delta` for passive income
- All monetary values stored as `float`; display with `NumberFormatter`
- Card stats are deterministic — generate once at startup from `CardDatabase`, not on every pull
- Pack savings pools are stored in save data; they persist between sessions
- Use `Control` nodes throughout (not `Node2D`) — this is a pure UI game

---

## 15. Out of Scope (for v1)

- Multiplayer or leaderboards
- Card trading
- Card battles (move/stats data is present for future use)
- IAP / monetisation hooks
- Push notifications
- Dark mode
- Achievements

---

## 16. Art Requirements (for your artist)

Provide assets as **PNG with transparency** unless specified. Suggested sizes:

| Asset type | Dimensions | Notes |
|-----------|-----------|-------|
| Card art (full) | 400×300px | Main illustration area on big card |
| Card art (thumbnail) | 144×104px | Used in small/dex cards |
| Chore icons | 60×60px | Circular crop applied in-engine |
| UI icons | 48×48px | Pack icons, button icons |
| Background | 390×844px | Optional subtle texture |

Cards should have a consistent frame/template. The art sits inside the frame. Rarity is communicated by the border colour (applied in-engine) — the art itself doesn't need rarity markings.

---

*End of brief. Start by setting up the project structure and `GameState` autoload with the core data definitions before building any UI scenes.*