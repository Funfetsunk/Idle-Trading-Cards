extends Node

const RARITY_COMMON    = "common"
const RARITY_UNCOMMON  = "uncommon"
const RARITY_RARE      = "rare"
const RARITY_ULTRA     = "ultra"      # was: Holo Rare
const RARITY_SECRET    = "secret"     # was: Ultra Rare
const RARITY_LEGENDARY = "legendary"  # was: Secret Rare

const RARITY_ORDER = [RARITY_COMMON, RARITY_UNCOMMON, RARITY_RARE, RARITY_ULTRA, RARITY_SECRET, RARITY_LEGENDARY]

const RARITY_LABELS = {
	RARITY_COMMON:    "Common",
	RARITY_UNCOMMON:  "Uncommon",
	RARITY_RARE:      "Rare",
	RARITY_ULTRA:     "Ultra Rare",
	RARITY_SECRET:    "Secret Rare",
	RARITY_LEGENDARY: "Legendary",
}

const RARITY_BORDER_COLORS = {
	RARITY_COMMON:    Color("#AAAAAA"),
	RARITY_UNCOMMON:  Color("#0F6E56"),
	RARITY_RARE:      Color("#EF9F27"),
	RARITY_ULTRA:     Color("#7F77DD"),
	RARITY_SECRET:    Color("#D85A30"),
	RARITY_LEGENDARY: Color("#D4537E"),
}

const RARITY_BG_COLORS = {
	RARITY_COMMON:    Color("#F5F5F0"),
	RARITY_UNCOMMON:  Color("#EAF5F0"),
	RARITY_RARE:      Color("#FAEEDA"),
	RARITY_ULTRA:     Color("#EEEDFE"),
	RARITY_SECRET:    Color("#FAECE7"),
	RARITY_LEGENDARY: Color("#FBEAF0"),
}

const RARITY_TEXT_COLORS = {
	RARITY_COMMON:    Color("#6B6B6B"),
	RARITY_UNCOMMON:  Color("#0F6E56"),
	RARITY_RARE:      Color("#854F0B"),
	RARITY_ULTRA:     Color("#534AB7"),
	RARITY_SECRET:    Color("#993C1D"),
	RARITY_LEGENDARY: Color("#993556"),
}

const STAT_BASE = {
	RARITY_COMMON:    20,
	RARITY_UNCOMMON:  30,
	RARITY_RARE:      45,
	RARITY_ULTRA:     55,
	RARITY_SECRET:    65,
	RARITY_LEGENDARY: 75,
}

const STAT_RANGE = {
	RARITY_COMMON:    25,
	RARITY_UNCOMMON:  30,
	RARITY_RARE:      35,
	RARITY_ULTRA:     35,
	RARITY_SECRET:    30,
	RARITY_LEGENDARY: 25,
}

# ── Card variations ───────────────────────────────────────────────────────────

const VARIATION_NORMAL   = "normal"
const VARIATION_SHINY    = "shiny"
const VARIATION_FULL_ART = "full_art"

# Pull probabilities per variation per rarity. Must sum to 1.0.
# Common/Uncommon/Rare: normal or shiny only.
# Ultra/Secret: normal, shiny, or full art.
# Legendary: always full art.
const VARIATION_WEIGHTS = {
	"common":    {"normal": 0.90, "shiny": 0.10},
	"uncommon":  {"normal": 0.90, "shiny": 0.10},
	"rare":      {"normal": 0.85, "shiny": 0.15},
	"ultra":     {"normal": 0.78, "shiny": 0.17, "full_art": 0.05},
	"secret":    {"normal": 0.70, "shiny": 0.20, "full_art": 0.10},
	"legendary": {"full_art": 1.0},
}

# ── Card types ───────────────────────────────────────────────────────────────

const TYPE_FIRE  = "fire"
const TYPE_WATER = "water"
const TYPE_WIND  = "wind"
const TYPE_EARTH = "earth"
const TYPE_LIGHT = "light"
const TYPE_DARK  = "dark"

const TYPE_LABELS = {
	TYPE_FIRE:  "Fire",
	TYPE_WATER: "Water",
	TYPE_WIND:  "Wind",
	TYPE_EARTH: "Earth",
	TYPE_LIGHT: "Light",
	TYPE_DARK:  "Dark",
}

# Card background colour per type
const TYPE_COLORS = {
	TYPE_FIRE:  Color("#C0392B"),
	TYPE_WATER: Color("#2471A3"),
	TYPE_WIND:  Color("#85C1E9"),
	TYPE_EARTH: Color("#7D5A3C"),
	TYPE_LIGHT: Color("#D4AC0D"),
	TYPE_DARK:  Color("#1C2833"),
}

# Art panel background per type (lighter shade)
const TYPE_ART_BG_COLORS = {
	TYPE_FIRE:  Color("#F0A28A"),
	TYPE_WATER: Color("#85C1E9"),
	TYPE_WIND:  Color("#D5EAF5"),
	TYPE_EARTH: Color("#C4A882"),
	TYPE_LIGHT: Color("#FAE89A"),
	TYPE_DARK:  Color("#4A4E69"),
}

# Type label colour for use on white section panels
const TYPE_LABEL_COLORS = {
	TYPE_FIRE:  Color("#C0392B"),
	TYPE_WATER: Color("#2471A3"),
	TYPE_WIND:  Color("#5D8AA8"),
	TYPE_EARTH: Color("#7D5A3C"),
	TYPE_LIGHT: Color("#B7860B"),
	TYPE_DARK:  Color("#4A4E69"),
}

# Footer text colour — dark for light bg types, white for dark bg types
const TYPE_FOOTER_TEXT_COLORS = {
	TYPE_FIRE:  Color.WHITE,
	TYPE_WATER: Color.WHITE,
	TYPE_WIND:  Color("#1A1A1A"),
	TYPE_EARTH: Color.WHITE,
	TYPE_LIGHT: Color("#1A1A1A"),
	TYPE_DARK:  Color.WHITE,
}

# Every card name mapped to its type
const CARD_TYPES = {
	# Fire (13)
	"Grumplet": TYPE_FIRE, "Sparktail": TYPE_FIRE, "Flampling": TYPE_FIRE,
	"Fizzwick": TYPE_FIRE, "Emberpaw": TYPE_FIRE, "Thundertail": TYPE_FIRE,
	"Ashwhisker": TYPE_FIRE, "Boulderpaw": TYPE_FIRE, "Cinderkit": TYPE_FIRE,
	"Blazethorn": TYPE_FIRE, "Pyrespine": TYPE_FIRE, "Crimsontail": TYPE_FIRE,
	"Solarispine": TYPE_FIRE,
	# Water (12)
	"Snorkel": TYPE_WATER, "Wobblefin": TYPE_WATER, "Frogling": TYPE_WATER,
	"Shellsworth": TYPE_WATER, "Gloopfish": TYPE_WATER, "Blubbersnap": TYPE_WATER,
	"Squelchmore": TYPE_WATER, "Glacierpup": TYPE_WATER, "Tidesnout": TYPE_WATER,
	"Aquashade": TYPE_WATER, "Tidecrest": TYPE_WATER, "Spectralfin": TYPE_WATER,
	# Wind (13)
	"Fluffalo": TYPE_WIND, "Twiglet": TYPE_WIND, "Driftpuff": TYPE_WIND,
	"Whiskerbean": TYPE_WIND, "Noodlewing": TYPE_WIND, "Snuffleton": TYPE_WIND,
	"Vortexkit": TYPE_WIND, "Stormtail": TYPE_WIND, "Mistfang": TYPE_WIND,
	"Galewing": TYPE_WIND, "Stormveil": TYPE_WIND, "Eclipsewing": TYPE_WIND,
	"Aethermaw": TYPE_WIND,
	# Earth (13)
	"Munchkin": TYPE_EARTH, "Rootsnap": TYPE_EARTH, "Pebblesnout": TYPE_EARTH,
	"Puddingfoot": TYPE_EARTH, "Pamplemoose": TYPE_EARTH, "Grumbleleaf": TYPE_EARTH,
	"Mossmaw": TYPE_EARTH, "Stoneback": TYPE_EARTH, "Brambleclaw": TYPE_EARTH,
	"Thornback": TYPE_EARTH, "Terraveil": TYPE_EARTH, "Stonecrown": TYPE_EARTH,
	"Ironmaw": TYPE_EARTH,
	# Light (13)
	"Gleamoth": TYPE_LIGHT, "Crinklenose": TYPE_LIGHT, "Wobblebug": TYPE_LIGHT,
	"Bingleberry": TYPE_LIGHT, "Crystalfin": TYPE_LIGHT, "Frostveil": TYPE_LIGHT,
	"Dawnpetal": TYPE_LIGHT, "Auroraling": TYPE_LIGHT, "Prismback": TYPE_LIGHT,
	"Celestipaw": TYPE_LIGHT, "Luminescenthorn": TYPE_LIGHT, "Infinipaw": TYPE_LIGHT,
	"The Shimmering One": TYPE_LIGHT,
	# Dark (12)
	"Boulderbutt": TYPE_DARK, "Dozelington": TYPE_DARK, "Clodsworth": TYPE_DARK,
	"Duskwing": TYPE_DARK, "Cragfang": TYPE_DARK, "Cavewing": TYPE_DARK,
	"Dungeonpup": TYPE_DARK, "Shadowfang": TYPE_DARK, "Voidwhisker": TYPE_DARK,
	"Nebulaclaw": TYPE_DARK, "Chronofang": TYPE_DARK, "Omegaling": TYPE_DARK,
}

# ── Card names ────────────────────────────────────────────────────────────────

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
	RARITY_ULTRA: [
		"Auroraling", "Prismback", "Celestipaw", "Voidwhisker",
		"Luminescenthorn", "Spectralfin", "Nebulaclaw", "Eclipsewing"
	],
	RARITY_SECRET: [
		"Chronofang", "Aethermaw", "Infinipaw", "Solarispine"
	],
	RARITY_LEGENDARY: [
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
	# Ultra Rare (8)
	"Aurora Beam", "Prism Ray", "Celestial Strike", "Void Pulse",
	"Luminescent Wave", "Spectral Slash", "Nebula Burst", "Eclipse Beam",
	# Secret Rare (4)
	"Chrono Blast", "Aether Storm", "Infinity Pulse", "Solar Flare",
	# Legendary (2)
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
	# Ultra Rare (8)
	"A prismatic beam of pure aurora light.", "Shatter reality with prism rays.",
	"Strike with celestial energy.", "Pulse with raw void energy.",
	"A wave of luminescent power.", "Slash with spectral force.",
	"Burst with the energy of a nebula.", "Beam power through an eclipse.",
	# Secret Rare (4)
	"Blast a hole through the timestream.", "Unleash a catastrophic aetheric storm.",
	"Pulse with truly infinite energy.", "Harness the power of a solar flare.",
	# Legendary (2)
	"The ultimate omega destruction beam.", "Annihilate with pure shimmer energy."
]

const CHORES = [
	{"id": "sibling",   "name": "Little Sibling Helper",    "icon": "👦", "base_cost": 5.0,            "fl_per_sec": 0.3,      "cost_mult": 1.15, "unlock_at": 0.0},
	{"id": "paperound", "name": "Paper Round",               "icon": "📰", "base_cost": 25.0,           "fl_per_sec": 0.9,      "cost_mult": 1.17, "unlock_at": 8.0},
	{"id": "bins",      "name": "Take Out the Bins",         "icon": "🗑️",  "base_cost": 80.0,           "fl_per_sec": 2.0,      "cost_mult": 1.19, "unlock_at": 30.0},
	{"id": "dog",       "name": "Walk the Neighbour's Dog",  "icon": "🐕", "base_cost": 400.0,          "fl_per_sec": 6.0,      "cost_mult": 1.22, "unlock_at": 150.0},
	{"id": "yardsale",  "name": "Weekend Yard Sale",         "icon": "🏷️",  "base_cost": 2000.0,         "fl_per_sec": 15.0,     "cost_mult": 1.25, "unlock_at": 800.0},
	{"id": "lawn",      "name": "Mow the Lawn",              "icon": "🌿", "base_cost": 8000.0,         "fl_per_sec": 30.0,     "cost_mult": 1.27, "unlock_at": 3000.0},
	{"id": "baking",    "name": "Run a Bake Sale",           "icon": "🍰", "base_cost": 35000.0,        "fl_per_sec": 80.0,     "cost_mult": 1.29, "unlock_at": 12000.0},
	{"id": "lemonade",  "name": "Run a Lemonade Stand",      "icon": "🍋", "base_cost": 120000.0,       "fl_per_sec": 180.0,    "cost_mult": 1.31, "unlock_at": 45000.0},
	{"id": "tutoring",  "name": "Tutoring Sessions",         "icon": "📚", "base_cost": 500000.0,       "fl_per_sec": 400.0,    "cost_mult": 1.33, "unlock_at": 180000.0},
	{"id": "babysit",   "name": "Babysitting Round",         "icon": "👶", "base_cost": 2000000.0,      "fl_per_sec": 900.0,    "cost_mult": 1.34, "unlock_at": 750000.0},
	{"id": "carwash",   "name": "Neighbourhood Car Wash",    "icon": "🚗", "base_cost": 8000000.0,      "fl_per_sec": 2000.0,   "cost_mult": 1.36, "unlock_at": 3000000.0},
	{"id": "carboot",   "name": "Car Boot Sale Empire",      "icon": "🏪", "base_cost": 35000000.0,     "fl_per_sec": 5000.0,   "cost_mult": 1.38, "unlock_at": 12000000.0},
	{"id": "delivery",  "name": "Food Delivery Round",       "icon": "🛵", "base_cost": 150000000.0,    "fl_per_sec": 12000.0,  "cost_mult": 1.39, "unlock_at": 60000000.0},
	{"id": "market",    "name": "Market Stall Trader",       "icon": "🛒", "base_cost": 650000000.0,    "fl_per_sec": 30000.0,  "cost_mult": 1.41, "unlock_at": 300000000.0},
	{"id": "onlineshop","name": "Online Resale Shop",        "icon": "💻", "base_cost": 3000000000.0,   "fl_per_sec": 80000.0,  "cost_mult": 1.43, "unlock_at": 1500000000.0},
	{"id": "cardempire","name": "Trading Card Empire",       "icon": "🃏", "base_cost": 15000000000.0,  "fl_per_sec": 250000.0, "cost_mult": 1.45, "unlock_at": 8000000000.0},
]

const PACKS = [
	{"id": "basic",     "label": "Basic Pack",     "icon": "📦", "base_cost": 300.0,      "scale_factor": 1.8, "scale_every": 20, "unlock_at": 0.0},
	{"id": "silver",    "label": "Silver Pack",    "icon": "🥈", "base_cost": 80000.0,    "scale_factor": 2.0, "scale_every": 15, "unlock_at": 30000.0},
	{"id": "gold",      "label": "Gold Pack",      "icon": "🥇", "base_cost": 600000.0,   "scale_factor": 2.2, "scale_every": 10, "unlock_at": 400000.0},
	{"id": "legendary", "label": "Legendary Pack", "icon": "✨", "base_cost": 8000000.0,  "scale_factor": 2.5, "scale_every": 5,  "unlock_at": 4000000.0},
]

const UPGRADES = [
	{"id": "u1", "name": "Lucky Bag",        "desc": "+5% ultra rare chance",        "icon": "🎒", "cost": 4000.0,       "effect": "ultra",     "value": 0.05, "unlock_at": 1500.0},
	{"id": "u2", "name": "Foil Sleeve",      "desc": "+8% rare weight reduction",    "icon": "🃏", "cost": 25000.0,      "effect": "rare",      "value": 0.08, "unlock_at": 8000.0},
	{"id": "u3", "name": "Magnifying Glass", "desc": "+10% ultra rare chance",       "icon": "🔍", "cost": 150000.0,     "effect": "ultra",     "value": 0.10, "unlock_at": 50000.0},
	{"id": "u4", "name": "Price Guide Book", "desc": "+12% rare weight reduction",   "icon": "📖", "cost": 1000000.0,    "effect": "rare",      "value": 0.12, "unlock_at": 350000.0},
	{"id": "u5", "name": "Special Order",    "desc": "+6% secret rare chance",       "icon": "📬", "cost": 8000000.0,    "effect": "secret",    "value": 0.06, "unlock_at": 3000000.0},
	{"id": "u6", "name": "Golden Wrapper",   "desc": "+10% secret rare chance",      "icon": "🎁", "cost": 60000000.0,   "effect": "secret",    "value": 0.10, "unlock_at": 25000000.0},
	{"id": "u7", "name": "Secret Card Map",  "desc": "+3% legendary chance",         "icon": "🗺️",  "cost": 500000000.0,  "effect": "legendary", "value": 0.03, "unlock_at": 200000000.0},
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
				"type":      CARD_TYPES.get(card_name, TYPE_EARTH),
				"stats":     _gen_stats(card_index, rarity),
				"move_name": MOVE_NAMES[move_index] if move_index < MOVE_NAMES.size() else "Tackle",
				"move_desc": MOVE_DESCS[move_index] if move_index < MOVE_DESCS.size() else "A basic attack.",
				"number":    card_index + 1,
			})
			card_index += 1
			move_index += 1

func roll_variation(rarity: String) -> String:
	var weights = VARIATION_WEIGHTS.get(rarity, {"normal": 1.0})
	var r = randf()
	var cumul = 0.0
	for v in [VARIATION_NORMAL, VARIATION_SHINY, VARIATION_FULL_ART]:
		cumul += weights.get(v, 0.0)
		if r < cumul:
			return v
	return VARIATION_FULL_ART

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
