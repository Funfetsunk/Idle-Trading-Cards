# Florin Cards

A mobile idle/clicker game where you earn florins to open trading card packs and build your collection. Built in Godot 4.5 for Android (iOS planned).

---

## Overview

The core loop:

**Tap to earn florins → hire chores for passive income → save up → open card packs → collect cards → sell duplicates → buy luck upgrades → repeat**

The game has a warm, pocket-money tone — think childhood economics meets trading card collecting.

---

## Gameplay

- **Manual tapping** earns 0.1 fl per tap
- **Chores** provide passive fl/sec income — hire more copies to scale up
- **4 pack tiers**: Basic, Silver, Gold, and Legendary — each with better pull rates
- **76 collectible cards** across 6 rarities: Common, Uncommon, Rare, Holo Rare, Ultra Rare, and Secret Rare
- **Card variations**: every pull has a chance to be Normal, Shiny, or Full Art depending on rarity
- **Floridex**: browse and view your full card collection
- **Dupe selling**: sell sets of 50 duplicate cards for 100 fl each
- **Luck upgrades**: one-time purchases that permanently improve rare pull rates
- **Offline earnings**: passive income accumulates while the game is closed (capped at 8 hours)

### Rarity Pull Rates (rare slot)

| Rarity | Base chance |
|--------|-------------|
| Rare | 72% |
| Holo Rare | 20% |
| Ultra Rare | 7% |
| Secret Rare | 1% |

### Card Variations

| Variation | Eligible Rarities | Approximate Chance |
|-----------|------------------|--------------------|
| Normal | All | Most likely |
| Shiny | Common → Secret Rare | Uncommon |
| Full Art | Ultra Rare, Secret Rare | Rare |

---

## Tech Stack

- **Engine**: Godot 4.5
- **Language**: GDScript
- **Target platform**: Android (portrait, ETC2/ASTC texture compression), iOS planned
- **Target resolution**: 390×844 (iPhone 14 base), scales for Android via `canvas_items` stretch
- **UI**: fully programmatic — all UI built in GDScript, no complex `.tscn` authoring
- **Save system**: JSON saved to `user://save.json`, auto-saves every 30 seconds

---

## Project Structure

```
res://
├── scenes/
│   └── Main.tscn              # Entry point — minimal scene that loads Main.gd
├── scripts/
│   ├── GameState.gd           # Autoload — all game state, signals, core methods
│   ├── CardDatabase.gd        # Autoload — all 76 cards, chores, packs, upgrades
│   ├── PackLogic.gd           # Autoload — pack opening and rarity weight rolling
│   ├── SaveManager.gd         # Autoload — JSON save/load, offline earnings
│   ├── NumberFormatter.gd     # Autoload — number/rate/time formatting utilities
│   ├── Main.gd                # Main scene script — builds entire UI programmatically
│   ├── Floridex.gd            # Full-screen card collection browser overlay
│   ├── CardViewer.gd          # Full-screen individual card viewer overlay
│   └── CardWidgets.gd         # Static class — reusable card UI builders
└── project.godot
```

---

## Running the Project

1. Clone the repository
2. Open Godot 4.5 or later
3. Click **Import** and select the project folder
4. Press **F5** or click **Run** to launch

> **Note:** All card art is currently placeholder — the card name's first letter is displayed in place of artwork. Custom illustrated assets will replace these in a future update.

---

## Development Status

Fully functional prototype — the complete idle loop is implemented and the game is playable end-to-end. Android export is configured. The following are planned for future updates:

- Custom illustrated card art
- Visual polish and animations
- iOS build
- Game balance tuning
