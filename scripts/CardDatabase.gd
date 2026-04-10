extends Node

const RARITY_COMMON   = "common"
const RARITY_UNCOMMON = "uncommon"
const RARITY_RARE     = "rare"
const RARITY_HOLO     = "holo"
const RARITY_ULTRA    = "ultra"
const RARITY_SECRET   = "secret"

const RARITY_ORDER = [RARITY_COMMON, RARITY_UNCOMMON, RARITY_RARE, RARITY_HOLO, RARITY_ULTRA, RARITY_SECRET]

const RARITY_LABELS = {
	RARITY_COMMON:   "Common",
	RARITY_UNCOMMON: "Uncommon",
	RARITY_RARE:     "Rare",
	RARITY_HOLO:     "Holo Rare",
	RARITY_ULTRA:    "Ultra Rare",
	RARITY_SECRET:   "Secret Rare",
}

const RARITY_BORDER_COLORS = {
	RARITY_COMMON:   Color("#AAAAAA"),
	RARITY_UNCOMMON: Color("#0F6E56"),
	RARITY_RARE:     Color("#EF9F27"),
	RARITY_HOLO:     Color("#7F77DD"),
	RARITY_ULTRA:    Color("#D85A30"),
	RARITY_SECRET:   Color("#D4537E"),
}

const RARITY_BG_COLORS = {
	RARITY_COMMON:   Color("#F5F5F0"),
	RARITY_UNCOMMON: Color("#EAF5F0"),
	RARITY_RARE:     Color("#FAEEDA"),
	RARITY_HOLO:     Color("#EEEDFE"),
	RARITY_ULTRA:    Color("#FAECE7"),
	RARITY_SECRET:   Color("#FBEAF0"),
}

const RARITY_TEXT_COLORS = {
	RARITY_COMMON:   Color("#6B6B6B"),
	RARITY_UNCOMMON: Color("#0F6E56"),
	RARITY_RARE:     Color("#854F0B"),
	RARITY_HOLO:     Color("#534AB7"),
	RARITY_ULTRA:    Color("#993C1D"),
	RARITY_SECRET:   Color("#993556"),
}

const STAT_BASE = {
	RARITY_COMMON:   20,
	RARITY_UNCOMMON: 30,
	RARITY_RARE:     45,
	RARITY_HOLO:     55,
	RARITY_ULTRA:    65,
	RARITY_SECRET:   75,
}

const STAT_RANGE = {
	RARITY_COMMON:   25,
	RARITY_UNCOMMON: 30,
	RARITY_RARE:     35,
	RARITY_HOLO:     35,
	RARITY_ULTRA:    30,
	RARITY_SECRET:   25,
}

const CARD_NAMES = {
	RARITY_COMMON: [
		"Munchkin", "Fluffalo", "Snorkel", "Wobblefin", "Grumplet",
		"Twiglet", "Boulderbutt", "Sparktail", "Frogling", "Driftpuff",
		"Rootsnap", "Gleamoth", "Crinklenose", "Shellsworth", "Pebblesnout",
		"Whiskerbean", "Flampling", "Gloopfish", "Noodlewing", "Blubbersnap",
		"Puddingfoot", "Squelchmore", "Dozelington", "Fizzwick", "Pamplemoose",
		"Grumbleleaf", "Snuffleton", "Wobblebug", "Clodsworth", "Bingleberry"
	],
	RARITY_UNCOMMON: [
		"Emberpaw", "Crystalfin", "Mossmaw", "Thundertail", "Glacierpup",
		"Stoneback", "Vortexkit", "Duskwing", "Brambleclaw", "Tidesnout",
		"Cragfang", "Ashwhisker", "Boulderpaw", "Stormtail", "Cinderkit",
		"Mistfang", "Thornback", "Frostveil", "Cavewing", "Dungeonpup"
	],
	RARITY_RARE: [
		"Blazethorn", "Aquashade", "Terraveil", "Galewing", "Pyrespine",
		"Tidecrest", "Stonecrown", "Stormveil", "Shadowfang", "Dawnpetal",
		"Ironmaw", "Crimsontail"
	],
	RARITY_HOLO: [
		"Auroraling", "Prismback", "Celestipaw", "Voidwhisker",
		"Luminescenthorn", "Spectralfin", "Nebulaclaw", "Eclipsewing"
	],
	RARITY_ULTRA: [
		"Chronofang", "Aethermaw", "Infinipaw", "Solarispine"
	],
	RARITY_SECRET: [
		"Omegaling", "The Shimmering One"
	]
}

const MOVE_NAMES = [
	# Common (30)
	"Nibble Attack", "Fluffy Tackle", "Snorkel Splash", "Fin Slap", "Grumpy Glare",
	"Twig Poke", "Boulder Bash", "Spark Zap", "Frog Leap", "Drift Dive",
	"Root Snap", "Gleam Flash", "Nose Boop", "Shell Shield", "Pebble Toss",
	"Whisker Twitch", "Flame Spit", "Gloop Hurl", "Noodle Whip", "Blubber Bump",
	"Pudding Stomp", "Squelch Slam", "Doze Yawn", "Fizz Pop", "Pomelo Toss",
	"Leaf Rustle", "Snuffle Sneeze", "Wobble Bump", "Clod Toss", "Berry Barrage",
	# Uncommon (20)
	"Ember Strike", "Crystal Beam", "Moss Crush", "Thunder Stomp", "Glacier Bite",
	"Stone Wall", "Vortex Spin", "Dusk Shroud", "Bramble Swipe", "Tide Pull",
	"Crag Smash", "Ash Cloud", "Boulder Charge", "Storm Rush", "Cinder Burst",
	"Mist Veil", "Thorn Barrage", "Frost Bite", "Cave Screech", "Dungeon Roar",
	# Rare (12)
	"Blaze Surge", "Aqua Blast", "Terra Quake", "Gale Force", "Pyre Eruption",
	"Tide Wave", "Stone Fortress", "Storm Fury", "Shadow Strike", "Dawn Ray",
	"Iron Crush", "Crimson Blade",
	# Holo (8)
	"Aurora Beam", "Prism Ray", "Celestial Strike", "Void Pulse",
	"Luminescent Wave", "Spectral Slash", "Nebula Burst", "Eclipse Beam",
	# Ultra (4)
	"Chrono Blast", "Aether Storm", "Infinity Pulse", "Solar Flare",
	# Secret (2)
	"Omega Destroy", "Shimmer Annihilate"
]

const MOVE_DESCS = [
	# Common (30)
	"A small but determined bite.", "A fluffy charge that bounces harmlessly.",
	"Splash! Gets everyone a bit wet.", "Slap with a wobbly fin.",
	"A glare so grumpy it actually stings.", "Poke with a very sharp twig.",
	"Smash with a surprisingly large boulder.", "A sharp little electric zap.",
	"Leap at the foe with big webbed feet.", "Drift up silently from below.",
	"Snap roots up from the ground.", "A blinding flash of pure gleam.",
	"Boop them right on the nose.", "Retreat into the shell for protection.",
	"Toss a handful of pebbles at high speed.", "Twitch whiskers for a hypnotic effect.",
	"Spit a tiny but fierce flame.", "Hurl a glob of sticky gloop.",
	"Whip with a long noodle-like appendage.", "Bump them with a blubbery belly.",
	"Stomp with an incredibly pudding-like foot.", "A wet squelching full-body slam.",
	"Yawn so wide it causes mass drowsiness.", "Pop a fizzy bubble in their face.",
	"Hurl a ripe pomelo with precision.", "Rustle leaves to create total confusion.",
	"Unleash a mighty snuffle-sneeze.", "Wobble rapidly into the enemy.",
	"Toss a clod of dirt directly at them.", "A rapid-fire barrage of tiny berries.",
	# Uncommon (20)
	"Strike with an ember-hot paw.", "Fire a focused crystalline beam.",
	"Crush with ancient mossy strength.", "A bone-shaking thunder stomp.",
	"Bite with glacially cold teeth.", "Raise an impenetrable wall of stone.",
	"Spin in a destructive vortex.", "Shroud the field in deep dusk.",
	"Swipe with sharp thorny bramble claws.", "Pull the enemy with the tide.",
	"Smash with a jagged crag.", "Release a blinding cloud of ash.",
	"Charge with boulder-like momentum.", "Rush forward riding a storm.",
	"Erupt in a burst of cinders.", "Veil yourself in protective mist.",
	"Rain down a barrage of thorns.", "Bite with icy frost.",
	"Screech from the depths of a cave.", "Roar from the dungeon depths.",
	# Rare (12)
	"Surge forward with blazing flame.", "Blast with pressurised water.",
	"Shake the earth with seismic force.", "The full force of gale winds.",
	"Erupt like a great burning pyre.", "A crashing tidal wave attack.",
	"Build an impenetrable stone fortress.", "The fury of a storm unleashed.",
	"Strike silently from the shadows.", "A ray of powerful dawn light.",
	"Crush with the force of iron.", "Slash with a razor crimson blade.",
	# Holo (8)
	"A prismatic beam of pure aurora light.", "Shatter reality with prism rays.",
	"Strike with celestial energy.", "Pulse with raw void energy.",
	"A wave of luminescent power.", "Slash with spectral force.",
	"Burst with the energy of a nebula.", "Beam power through an eclipse.",
	# Ultra (4)
	"Blast a hole through the timestream.", "Unleash a catastrophic aetheric storm.",
	"Pulse with truly infinite energy.", "Harness the power of a solar flare.",
	# Secret (2)
	"The ultimate omega destruction beam.", "Annihilate with pure shimmer energy."
]

const CHORES = [
	{"id": "sibling",  "name": "Little Sibling Helper",       "icon": "👦", "base_cost": 5.0,       "fl_per_sec": 0.3,    "cost_mult": 1.15, "unlock_at": 0.0},
	{"id": "bins",     "name": "Take Out the Bins",            "icon": "🗑️",  "base_cost": 30.0,      "fl_per_sec": 1.1,    "cost_mult": 1.20, "unlock_at": 10.0},
	{"id": "dog",      "name": "Walk the Neighbour's Dog",     "icon": "🐕", "base_cost": 180.0,     "fl_per_sec": 5.0,    "cost_mult": 1.24, "unlock_at": 80.0},
	{"id": "lawn",     "name": "Mow the Lawn",                 "icon": "🌿", "base_cost": 1200.0,    "fl_per_sec": 18.0,   "cost_mult": 1.27, "unlock_at": 500.0},
	{"id": "lemonade", "name": "Run a Lemonade Stand",         "icon": "🍋", "base_cost": 8000.0,    "fl_per_sec": 60.0,   "cost_mult": 1.30, "unlock_at": 3000.0},
	{"id": "babysit",  "name": "Babysitting Round",            "icon": "👶", "base_cost": 60000.0,   "fl_per_sec": 220.0,  "cost_mult": 1.32, "unlock_at": 20000.0},
	{"id": "carwash",  "name": "Neighbourhood Car Wash",       "icon": "🚗", "base_cost": 500000.0,  "fl_per_sec": 800.0,  "cost_mult": 1.35, "unlock_at": 150000.0},
	{"id": "carboot",  "name": "Car Boot Sale Empire",         "icon": "🏪", "base_cost": 4000000.0, "fl_per_sec": 3200.0, "cost_mult": 1.38, "unlock_at": 1500000.0},
]

const PACKS = [
	{"id": "basic",     "label": "Basic Pack",     "icon": "📦", "base_cost": 300.0,    "scale_factor": 1.8, "scale_every": 20, "unlock_at": 0.0},
	{"id": "silver",    "label": "Silver Pack",    "icon": "🥈", "base_cost": 2500.0,   "scale_factor": 2.0, "scale_every": 15, "unlock_at": 5000.0},
	{"id": "gold",      "label": "Gold Pack",      "icon": "🥇", "base_cost": 15000.0,  "scale_factor": 2.2, "scale_every": 10, "unlock_at": 40000.0},
	{"id": "legendary", "label": "Legendary Pack", "icon": "✨", "base_cost": 150000.0, "scale_factor": 2.5, "scale_every": 5,  "unlock_at": 400000.0},
]

const UPGRADES = [
	{"id": "u1", "name": "Lucky Bag",        "desc": "+5% holo chance",              "icon": "🎒", "cost": 600.0,       "effect": "holo",   "value": 0.05, "unlock_at": 200.0},
	{"id": "u2", "name": "Foil Sleeve",      "desc": "+8% rare weight reduction",    "icon": "🃏", "cost": 3000.0,      "effect": "rare",   "value": 0.08, "unlock_at": 1000.0},
	{"id": "u3", "name": "Magnifying Glass", "desc": "+10% holo chance",             "icon": "🔍", "cost": 15000.0,     "effect": "holo",   "value": 0.10, "unlock_at": 6000.0},
	{"id": "u4", "name": "Price Guide Book", "desc": "+12% rare weight reduction",   "icon": "📖", "cost": 100000.0,    "effect": "rare",   "value": 0.12, "unlock_at": 40000.0},
	{"id": "u5", "name": "Special Order",    "desc": "+6% ultra chance",             "icon": "📬", "cost": 700000.0,    "effect": "ultra",  "value": 0.06, "unlock_at": 250000.0},
	{"id": "u6", "name": "Golden Wrapper",   "desc": "+10% ultra chance",            "icon": "🎁", "cost": 5000000.0,   "effect": "ultra",  "value": 0.10, "unlock_at": 1800000.0},
	{"id": "u7", "name": "Secret Card Map",  "desc": "+3% secret chance",            "icon": "🗺️",  "cost": 40000000.0,  "effect": "secret", "value": 0.03, "unlock_at": 12000000.0},
]

var CARDS: Array = []

func _ready():
	_build_cards()

func _lcg(s: int) -> int:
	return ((s * 1664525) + 1013904223) & 0xFFFFFFFF

func _gen_stats(card_index: int, rarity: String) -> Dictionary:
	var rarity_idx = RARITY_ORDER.find(rarity)
	var seed_val = card_index * 100 + rarity_idx
	var base = STAT_BASE[rarity]
	var rng = STAT_RANGE[rarity]
	var stats = {}
	for stat_name in ["health", "attack", "defence", "luck"]:
		seed_val = _lcg(seed_val)
		stats[stat_name] = base + (seed_val % (rng + 1))
	return stats

func _build_cards():
	var card_index = 0
	var move_index = 0
	for rarity in RARITY_ORDER:
		for card_name in CARD_NAMES[rarity]:
			CARDS.append({
				"index":     card_index,
				"name":      card_name,
				"rarity":    rarity,
				"stats":     _gen_stats(card_index, rarity),
				"move_name": MOVE_NAMES[move_index] if move_index < MOVE_NAMES.size() else "Tackle",
				"move_desc": MOVE_DESCS[move_index] if move_index < MOVE_DESCS.size() else "A basic attack.",
				"number":    card_index + 1,
			})
			card_index += 1
			move_index += 1

func get_card_by_name(card_name: String) -> Dictionary:
	for card in CARDS:
		if card["name"] == card_name:
			return card
	return {}

func get_cards_by_rarity(rarity: String) -> Array:
	var result = []
	for card in CARDS:
		if card["rarity"] == rarity:
			result.append(card)
	return result

func total_cards() -> int:
	return CARDS.size()
