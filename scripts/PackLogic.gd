extends Node

const BASE_WEIGHTS = {"rare": 0.72, "holo": 0.20, "ultra": 0.07, "secret": 0.01}

const PACK_BOOSTS = {
	"basic":     {"holo": 0.0,  "ultra": 0.0,  "secret": 0.0},
	"silver":    {"holo": 0.08, "ultra": 0.0,  "secret": 0.0},
	"gold":      {"holo": 0.12, "ultra": 0.06, "secret": 0.0},
	"legendary": {"holo": 0.15, "ultra": 0.12, "secret": 0.04},
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
	var upgrade_holo = 0.0
	var upgrade_rare_reduction = 0.0
	var upgrade_ultra = 0.0
	var upgrade_secret = 0.0

	for i in range(min(upgrades_bought.size(), CardDatabase.UPGRADES.size())):
		if upgrades_bought[i]:
			var upg = CardDatabase.UPGRADES[i]
			match upg["effect"]:
				"holo":   upgrade_holo += upg["value"]
				"rare":   upgrade_rare_reduction += upg["value"]
				"ultra":  upgrade_ultra += upg["value"]
				"secret": upgrade_secret += upg["value"]

	var w_rare   = maxf(0.0, BASE_WEIGHTS["rare"]   - upgrade_rare_reduction)
	var w_holo   = maxf(0.0, BASE_WEIGHTS["holo"]   + boosts["holo"]   + upgrade_holo)
	var w_ultra  = maxf(0.0, BASE_WEIGHTS["ultra"]  + boosts["ultra"]  + upgrade_ultra)
	var w_secret = maxf(0.0, BASE_WEIGHTS["secret"] + boosts["secret"] + upgrade_secret)

	var total = w_rare + w_holo + w_ultra + w_secret
	if total <= 0.0:
		return "rare"

	var r = randf() * total
	if r < w_rare:   return "rare"
	r -= w_rare
	if r < w_holo:   return "holo"
	r -= w_holo
	if r < w_ultra:  return "ultra"
	return "secret"

func _pick_random_card(rarity: String) -> Dictionary:
	var pool = CardDatabase.get_cards_by_rarity(rarity)
	if pool.is_empty():
		return CardDatabase.CARDS[0]
	return pool[randi() % pool.size()]
