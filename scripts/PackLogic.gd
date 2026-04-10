extends Node

const BASE_WEIGHTS = {"rare": 0.72, "ultra": 0.20, "secret": 0.07, "legendary": 0.01}

const PACK_BOOSTS = {
	"basic":     {"ultra": 0.0,  "secret": 0.0,  "legendary": 0.0},
	"silver":    {"ultra": 0.08, "secret": 0.0,  "legendary": 0.0},
	"gold":      {"ultra": 0.12, "secret": 0.06, "legendary": 0.0},
	"legendary": {"ultra": 0.15, "secret": 0.12, "legendary": 0.04},
}

func open_pack(pack_id: String, upgrades_bought: Array) -> Dictionary:
	var event = _roll_event()
	var slots = _get_slots(pack_id, event)
	var cards = []
	for slot_type in slots:
		var rarity = _roll_rarity_for_slot(slot_type, pack_id, upgrades_bought)
		cards.append(_pick_random_card(rarity))
	return {"cards": cards, "event": event}

func _roll_event() -> String:
	var r = randf()
	if r < 0.001:
		return "God Pack"
	elif r < 0.046:
		return "Double Rare"
	return "Normal"

func _get_slots(pack_id: String, event: String) -> Array:
	if event == "God Pack":
		return ["rare_plus", "rare_plus", "rare_plus", "rare_plus", "rare_plus"]
	match pack_id:
		"basic":
			if event == "Double Rare":
				return ["rare_plus", "rare_plus", "common_uncommon", "common_uncommon", "common_uncommon"]
			return ["common_uncommon", "common_uncommon", "common_uncommon", "common_uncommon", "rare_plus"]
		"silver":
			return ["uncommon_guaranteed", "uncommon_guaranteed", "uncommon_guaranteed", "rare_plus", "rare_plus"]
		"gold":
			return ["uncommon_guaranteed", "uncommon_guaranteed", "uncommon_guaranteed", "rare_plus", "rare_plus"]
		"legendary":
			return ["rare_plus", "rare_plus", "rare_plus", "rare_plus", "rare_plus"]
	return ["common_uncommon", "common_uncommon", "common_uncommon", "common_uncommon", "rare_plus"]

func _roll_rarity_for_slot(slot_type: String, pack_id: String, upgrades_bought: Array) -> String:
	match slot_type:
		"common_uncommon":
			return "uncommon" if randf() < 0.28 else "common"
		"uncommon_guaranteed":
			return "uncommon"
		"rare_plus":
			return _roll_rare_rarity(pack_id, upgrades_bought)
	return "common"

func _roll_rare_rarity(pack_id: String, upgrades_bought: Array) -> String:
	var boosts = PACK_BOOSTS[pack_id]
	var upgrade_ultra_boost     = 0.0
	var upgrade_rare_reduction  = 0.0
	var upgrade_secret_boost    = 0.0
	var upgrade_legendary_boost = 0.0

	for i in range(min(upgrades_bought.size(), CardDatabase.UPGRADES.size())):
		if upgrades_bought[i]:
			var upg = CardDatabase.UPGRADES[i]
			match upg["effect"]:
				"ultra":     upgrade_ultra_boost     += upg["value"]
				"rare":      upgrade_rare_reduction  += upg["value"]
				"secret":    upgrade_secret_boost    += upg["value"]
				"legendary": upgrade_legendary_boost += upg["value"]

	var w_rare      = maxf(0.0, BASE_WEIGHTS["rare"]      - upgrade_rare_reduction)
	var w_ultra     = maxf(0.0, BASE_WEIGHTS["ultra"]     + boosts["ultra"]     + upgrade_ultra_boost)
	var w_secret    = maxf(0.0, BASE_WEIGHTS["secret"]    + boosts["secret"]    + upgrade_secret_boost)
	var w_legendary = maxf(0.0, BASE_WEIGHTS["legendary"] + boosts["legendary"] + upgrade_legendary_boost)

	var total = w_rare + w_ultra + w_secret + w_legendary
	if total <= 0.0:
		return "rare"

	var r = randf() * total
	if r < w_rare:      return "rare"
	r -= w_rare
	if r < w_ultra:     return "ultra"
	r -= w_ultra
	if r < w_secret:    return "secret"
	return "legendary"

func _pick_random_card(rarity: String) -> Dictionary:
	var pool = CardDatabase.get_cards_by_rarity(rarity)
	if pool.is_empty():
		return CardDatabase.CARDS[0]
	var card = pool[randi() % pool.size()].duplicate()
	card["variation"] = CardDatabase.roll_variation(rarity)
	return card
