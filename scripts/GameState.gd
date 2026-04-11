extends Node

signal florins_changed(new_value: float)
signal rate_changed(new_rate: float)
signal pack_opened(result: Dictionary)
signal collection_changed()
signal log_updated(lines: Array)
signal dupes_changed(total: int)
signal upgrades_changed()
signal chores_changed()
signal state_reset()

const TAP_EARN = 0.1

var florins:        float = 0.0
var total_earned:   float = 0.0
var tap_count:      int   = 0
var chore_counts:   Array = []
var upgrades_bought: Array = []
var pack_state:     Array = []
var collected:      Dictionary = {}
var duplicates:     Dictionary = {}
var log_lines:      Array = []
var last_save_time: float = 0.0
var pity_counter:    int        = 0   # packs opened without an ultra+ pull
var packs_announced: Array      = []  # pack IDs whose unlock has been celebrated
var pending_offline: Dictionary = {}  # set by SaveManager; consumed by Main.gd for banner

var _tick_accum: float = 0.0

func _ready() -> void:
	initialize()
	var loaded = SaveManager.load_save()
	if not loaded:
		add_log("Welcome to Florin Cards! Tap to earn florins.")

func initialize() -> void:
	florins       = 0.0
	total_earned  = 0.0
	tap_count     = 0
	chore_counts  = []
	for _i in range(CardDatabase.CHORES.size()):
		chore_counts.append(0)
	upgrades_bought = []
	for _i in range(CardDatabase.UPGRADES.size()):
		upgrades_bought.append(false)
	pack_state = []
	for _i in range(CardDatabase.PACKS.size()):
		pack_state.append({"purchased": 0, "savings": 0.0})
	collected    = {}
	duplicates   = {}
	log_lines    = []
	last_save_time  = 0.0
	pity_counter    = 0
	packs_announced = []
	pending_offline = {}
	_tick_accum = 0.0
	state_reset.emit()

func _process(delta: float) -> void:
	_tick_accum += delta
	if _tick_accum >= 0.1:
		var earn = _tick_accum * get_fl_per_sec()
		_tick_accum = 0.0
		if earn > 0.0:
			add_florins(earn)

func get_fl_per_sec() -> float:
	var rate = 0.0
	for i in range(CardDatabase.CHORES.size()):
		rate += CardDatabase.CHORES[i]["fl_per_sec"] * chore_counts[i]
	return rate

func get_chore_cost(idx: int) -> float:
	var c = CardDatabase.CHORES[idx]
	return floor(c["base_cost"] * pow(c["cost_mult"], chore_counts[idx]))

func get_pack_cost(idx: int) -> float:
	var p = CardDatabase.PACKS[idx]
	var purchased = pack_state[idx]["purchased"]
	return floor(p["base_cost"] * pow(p["scale_factor"], floor(float(purchased) / p["scale_every"])))

func add_florins(amount: float) -> void:
	florins      += amount
	total_earned += amount
	for i in range(pack_state.size()):
		pack_state[i]["savings"] += amount
	florins_changed.emit(florins)

func tap() -> void:
	florins      += TAP_EARN
	total_earned += TAP_EARN
	tap_count    += 1
	for i in range(pack_state.size()):
		pack_state[i]["savings"] += TAP_EARN
	florins_changed.emit(florins)

func buy_chore(idx: int) -> bool:
	var cost = get_chore_cost(idx)
	if florins < cost:
		return false
	florins -= cost
	chore_counts[idx] += 1
	florins_changed.emit(florins)
	rate_changed.emit(get_fl_per_sec())
	chores_changed.emit()
	add_log("Hired: " + CardDatabase.CHORES[idx]["name"])
	SaveManager.save()
	return true

func buy_upgrade(idx: int) -> bool:
	if upgrades_bought[idx]:
		return false
	var upg = CardDatabase.UPGRADES[idx]
	if florins < upg["cost"]:
		return false
	florins -= upg["cost"]
	upgrades_bought[idx] = true
	florins_changed.emit(florins)
	upgrades_changed.emit()
	add_log("Bought upgrade: " + upg["name"])
	SaveManager.save()
	return true

func open_pack(pack_idx: int) -> Dictionary:
	var cost    = get_pack_cost(pack_idx)
	var savings = pack_state[pack_idx]["savings"]
	if savings < cost:
		return {}

	pack_state[pack_idx]["savings"]   -= cost
	pack_state[pack_idx]["purchased"] += 1

	var result = PackLogic.open_pack(CardDatabase.PACKS[pack_idx]["id"], upgrades_bought)

	for card in result["cards"]:
		var cname     = card["name"]
		var variation = card.get("variation", CardDatabase.VARIATION_NORMAL)
		var key       = cname + "|" + variation
		# Dupe if any variant of this card was already owned before this pull
		if _is_any_variant_owned(cname):
			var rarity = card["rarity"]
			duplicates[rarity] = duplicates.get(rarity, 0) + 1
		collected[key] = collected.get(key, 0) + 1

	var event = result["event"]
	var pname = CardDatabase.PACKS[pack_idx]["label"]
	add_log("Opened %s%s" % [pname, (" — " + event + "!") if event != "Normal" else ""])

	pack_opened.emit(result)
	collection_changed.emit()
	dupes_changed.emit(get_total_dupes())
	SaveManager.save()
	return result

func get_total_dupes() -> int:
	var total = 0
	for rarity in duplicates:
		total += duplicates[rarity]
	return total

func sell_dupes(batch_size: int = 50) -> bool:
	var total = get_total_dupes()
	if total < batch_size:
		return false
	var sets      = int(total / batch_size)
	var earn      = sets * (batch_size * 2.0)   # 2 fl per dupe regardless of batch size
	var remaining = sets * batch_size
	for rarity in CardDatabase.RARITY_ORDER:
		if remaining <= 0:
			break
		var have = duplicates.get(rarity, 0)
		var take = mini(have, remaining)
		duplicates[rarity] = have - take
		remaining -= take
	add_florins(earn)
	add_log("Sold %d dupes for %s fl" % [sets * batch_size, NumberFormatter.fmt(earn)])
	dupes_changed.emit(get_total_dupes())
	SaveManager.save()
	return true

func get_unique_collected() -> int:
	var unique_names: Dictionary = {}
	for key in collected:
		if collected[key] > 0:
			unique_names[key.split("|")[0]] = true
	return unique_names.size()

# Returns true if the player owns any variant of card_name.
func _is_any_variant_owned(card_name: String) -> bool:
	for key in collected:
		if key.split("|")[0] == card_name and collected[key] > 0:
			return true
	return false

# Total copies owned across all variants.
func get_card_total_owned(card_name: String) -> int:
	var total = 0
	for key in collected:
		if key.split("|")[0] == card_name:
			total += collected.get(key, 0)
	return total

# Best variant owned (full_art > shiny > normal), or "" if not owned.
func get_card_best_variant(card_name: String) -> String:
	for v in [CardDatabase.VARIATION_FULL_ART, CardDatabase.VARIATION_SHINY, CardDatabase.VARIATION_NORMAL]:
		if collected.get(card_name + "|" + v, 0) > 0:
			return v
	return ""

func add_log(msg: String) -> void:
	log_lines.append(msg)
	if log_lines.size() > 5:
		log_lines = log_lines.slice(log_lines.size() - 5)
	log_updated.emit(log_lines)
