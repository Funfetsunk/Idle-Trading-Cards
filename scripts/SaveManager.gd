extends Node

const SAVE_PATH = "user://save.json"
const OFFLINE_CAP_SECS = 8 * 3600

var _save_timer: float = 0.0
const AUTO_SAVE_INTERVAL: float = 30.0

func _process(delta: float) -> void:
	_save_timer += delta
	if _save_timer >= AUTO_SAVE_INTERVAL:
		_save_timer = 0.0
		save()

func save() -> void:
	var gs = get_node("/root/GameState")
	var data = {
		"florins":          gs.florins,
		"total_earned":     gs.total_earned,
		"tap_count":        gs.tap_count,
		"chore_counts":     gs.chore_counts,
		"upgrades_bought":  gs.upgrades_bought,
		"pack_state":       gs.pack_state,
		"collected":        gs.collected,
		"duplicates":       gs.duplicates,
		"log_lines":        gs.log_lines,
		"pity_counter":     gs.pity_counter,
		"packs_announced":  gs.packs_announced,
		"saved_at":         Time.get_unix_time_from_system(),
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		gs.last_save_time = Time.get_unix_time_from_system()

func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		# First launch — grant welcome bonus
		var gs = get_node("/root/GameState")
		gs.add_florins(50.0)
		gs.add_log("Welcome to Florin Cards! Here's 50 fl to get you started.")
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(text) != OK:
		return false
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return false

	var gs = get_node("/root/GameState")
	gs.florins       = float(data.get("florins",      0.0))
	gs.total_earned  = float(data.get("total_earned", 0.0))
	gs.tap_count     = int(data.get("tap_count",      0))
	gs.chore_counts  = _ensure_int_array(data.get("chore_counts", []),   CardDatabase.CHORES.size(),   0)
	gs.upgrades_bought = _ensure_bool_array(data.get("upgrades_bought", []), CardDatabase.UPGRADES.size())
	gs.pack_state    = _load_pack_state(data.get("pack_state", []))
	gs.collected     = _to_dict(data.get("collected",  {}))
	gs.duplicates    = _to_dict(data.get("duplicates", {}))
	gs.log_lines        = _to_str_array(data.get("log_lines", []))
	gs.last_save_time   = float(data.get("saved_at", 0.0))
	gs.pity_counter     = int(data.get("pity_counter", 0))
	gs.packs_announced  = _to_str_array(data.get("packs_announced", []))

	# Offline earnings — apply florins now, defer banner to Main.gd
	var saved_at = float(data.get("saved_at", 0.0))
	if saved_at > 0:
		var elapsed = minf(Time.get_unix_time_from_system() - saved_at, OFFLINE_CAP_SECS)
		if elapsed > 5.0:
			var rate   = gs.get_fl_per_sec()
			var earned = elapsed * rate
			if earned > 0.0:
				gs.add_florins(earned)
				gs.pending_offline = {"amount": earned, "seconds": int(elapsed)}
	return true

func reset() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("save.json")
	get_node("/root/GameState").initialize()

func _ensure_int_array(arr, size: int, default_val: int) -> Array:
	var result = []
	for i in range(size):
		result.append(int(arr[i]) if i < arr.size() else default_val)
	return result

func _ensure_bool_array(arr, size: int) -> Array:
	var result = []
	for i in range(size):
		result.append(bool(arr[i]) if i < arr.size() else false)
	return result

func _load_pack_state(arr) -> Array:
	var result = []
	for i in range(CardDatabase.PACKS.size()):
		if i < arr.size() and typeof(arr[i]) == TYPE_DICTIONARY:
			result.append({
				"purchased": int(arr[i].get("purchased", 0)),
				"savings":   float(arr[i].get("savings", 0.0)),
			})
		else:
			result.append({"purchased": 0, "savings": 0.0})
	return result

func _to_dict(v) -> Dictionary:
	return v if typeof(v) == TYPE_DICTIONARY else {}

func _to_str_array(v) -> Array:
	if typeof(v) != TYPE_ARRAY:
		return []
	var result = []
	for item in v:
		result.append(str(item))
	return result
