extends Control

const C_BLUE  = Color("#185FA5")
const C_GREEN = Color("#0F6E56")
const C_RED   = Color("#A32D2D")
const C_TEXT3 = Color("#A0A0A0")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dark overlay — absorbs clicks so game behind is not interactive
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# CenterContainer → PanelContainer → VBoxContainer (same pattern as CardViewer)
	var centre = CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centre)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color.WHITE
	ps.set_corner_radius_all(12)
	ps.content_margin_left   = 0
	ps.content_margin_right  = 0
	ps.content_margin_top    = 0
	ps.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", ps)
	centre.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	_build_header(vbox)
	_build_presets(vbox)
	_build_florins(vbox)
	_build_cards(vbox)

# ── Header ────────────────────────────────────────────────────────────────────

func _build_header(parent: Control) -> void:
	var header = PanelContainer.new()
	var hs = StyleBoxFlat.new()
	hs.bg_color = C_BLUE
	hs.corner_radius_top_left  = 12
	hs.corner_radius_top_right = 12
	hs.content_margin_left   = 16; hs.content_margin_right  = 12
	hs.content_margin_top    = 12; hs.content_margin_bottom = 12
	header.add_theme_stylebox_override("panel", hs)
	parent.add_child(header)

	var row = HBoxContainer.new()
	header.add_child(row)

	var lbl = Label.new()
	lbl.text = "Debug Panel"
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)

	var btn_close = Button.new()
	btn_close.text = "X  Close"
	btn_close.focus_mode = Control.FOCUS_NONE
	btn_close.add_theme_font_size_override("font_size", 12)
	btn_close.add_theme_color_override("font_color", Color.WHITE)
	var cs = StyleBoxFlat.new()
	cs.bg_color = Color(1, 1, 1, 0.2)
	cs.set_corner_radius_all(6)
	cs.content_margin_left  = 10; cs.content_margin_right  = 10
	cs.content_margin_top   =  4; cs.content_margin_bottom =  4
	btn_close.add_theme_stylebox_override("normal", cs)
	var csh = cs.duplicate(); csh.bg_color = Color(1, 1, 1, 0.3)
	btn_close.add_theme_stylebox_override("hover", csh)
	btn_close.pressed.connect(func(): visible = false)
	row.add_child(btn_close)

# ── Section helper ────────────────────────────────────────────────────────────

func _section(parent: Control, title: String) -> VBoxContainer:
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   16)
	m.add_theme_constant_override("margin_right",  16)
	m.add_theme_constant_override("margin_top",    16)
	m.add_theme_constant_override("margin_bottom",  4)
	parent.add_child(m)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	m.add_child(vbox)

	var lbl = Label.new()
	lbl.text = title.to_upper()
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", C_TEXT3)
	vbox.add_child(lbl)

	return vbox

func _btn(label: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.focus_mode = Control.FOCUS_NONE
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(8)
	s.content_margin_left   = 10; s.content_margin_right  = 10
	s.content_margin_top    = 10; s.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate(); sh.bg_color = color.lightened(0.1)
	btn.add_theme_stylebox_override("hover", sh)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 12)
	return btn

# ── Preset states ─────────────────────────────────────────────────────────────

func _build_presets(parent: Control) -> void:
	var sec = _section(parent, "Preset States")

	var presets = [
		["Fresh Start",          0.0,      0.0,      0.0     ],
		["Cards Tab (~305 fl)",  305.0,    305.0,    305.0   ],
		["Upgrades (~1,600 fl)", 1600.0,   1600.0,   1600.0  ],
		["Mid Game (~10K fl)",   10000.0,  10000.0,  10000.0 ],
		["Late Game (~500K fl)", 500000.0, 500000.0, 500000.0],
	]

	for p in presets:
		var btn = _btn(p[0], C_BLUE)
		btn.pressed.connect(_apply_preset.bind(p[1], p[2], p[3]))
		sec.add_child(btn)

# ── Add florins ───────────────────────────────────────────────────────────────

func _build_florins(parent: Control) -> void:
	var sec = _section(parent, "Add Florins")

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	sec.add_child(grid)

	var amounts = [
		["+100",   100.0],
		["+1K",    1000.0],
		["+10K",   10000.0],
		["+100K",  100000.0],
		["+1M",    1000000.0],
	]
	for a in amounts:
		var btn = _btn(a[0], C_GREEN)
		btn.pressed.connect(_add_florins.bind(a[1]))
		grid.add_child(btn)

# ── Cards ─────────────────────────────────────────────────────────────────────

func _build_cards(parent: Control) -> void:
	var sec = _section(parent, "Cards")

	var btn_give = _btn("Give All Cards", C_GREEN)
	btn_give.pressed.connect(_give_all_cards)
	sec.add_child(btn_give)

	var btn_clear = _btn("Clear All Cards", C_RED)
	btn_clear.pressed.connect(_clear_all_cards)
	sec.add_child(btn_clear)

# ── Actions ───────────────────────────────────────────────────────────────────

func _apply_preset(florins: float, total_earned: float, savings_0: float) -> void:
	GameState.florins      = florins
	GameState.total_earned = total_earned
	GameState.tap_count    = 0
	GameState.chore_counts    = GameState.chore_counts.map(func(_x): return 0)
	GameState.upgrades_bought = GameState.upgrades_bought.map(func(_x): return false)
	for i in range(GameState.pack_state.size()):
		GameState.pack_state[i] = {"purchased": 0, "savings": savings_0 if i == 0 else 0.0}
	GameState.collected       = {}
	GameState.duplicates      = {}
	GameState.packs_announced = []
	GameState.pity_counter    = 0
	GameState.log_lines       = []
	SaveManager.save()
	GameState.state_reset.emit()
	visible = false

func _add_florins(amount: float) -> void:
	GameState.add_florins(amount)

func _give_all_cards() -> void:
	for card in CardDatabase.CARDS:
		var key = card["name"] + "|normal"
		if not GameState.collected.has(key):
			GameState.collected[key] = 1
	GameState.collection_changed.emit()
	GameState.dupes_changed.emit(GameState.get_total_dupes())

func _clear_all_cards() -> void:
	GameState.collected  = {}
	GameState.duplicates = {}
	GameState.collection_changed.emit()
	GameState.dupes_changed.emit(0)
