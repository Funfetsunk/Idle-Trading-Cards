extends Control

# ── UI references ─────────────────────────────────────────────────────────────
var _lbl_balance:    Label
var _lbl_rate:       Label
var _lbl_total:      Label
var _lbl_save_time:  Label
var _btn_floridex:   Button
var _lbl_tap_count:  Label

var _chore_rows:     Array = []  # [{panel, lbl_count, lbl_cost, lbl_rate, btn_buy}]
var _pack_cards:     Array = []  # [{lbl_savings, lbl_cost, bar, btn_open, lbl_event}]
var _pack_tweens:    Array = []

var _latest_pull_container: HBoxContainer
var _latest_pull_header:    Label

var _upgrade_items:  Array = []  # [{container, btn_buy}]
var _rarity_rows:    Dictionary = {}  # rarity -> {lbl_unique, lbl_total, lbl_dupe}
var _lbl_total_dupes: Label
var _btn_sell_dupes:  Button
var _field_notes_vbox: VBoxContainer

var _float_layer: Control
var _floridex:    Control
var _cardviewer:  Control

# ── Colors ────────────────────────────────────────────────────────────────────
const C_BG          = Color("#FFFFFF")
const C_BG2         = Color("#F5F5F0")
const C_BORDER      = Color("#E5E5E0")
const C_TEXT        = Color("#1A1A1A")
const C_TEXT2       = Color("#6B6B6B")
const C_TEXT3       = Color("#A0A0A0")
const C_BLUE        = Color("#185FA5")
const C_GREEN       = Color("#0F6E56")
const C_RED         = Color("#A32D2D")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Build overlays first (they sit on top)
	_build_overlays()

	# Scrollable main content
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 0)
	scroll.add_child(content)

	_build_top_bar(content)
	_build_save_bar(content)
	_add_divider(content)
	_build_floridex_button(content)
	_add_divider(content)
	_build_tap_area(content)
	_build_chore_section(content)
	_build_pack_section(content)
	_build_latest_pull(content)
	_build_upgrades_section(content)
	_build_collection_summary(content)
	_build_field_notes(content)
	_add_spacer(content, 24)

	# Floating label layer (above scroll, below overlays)
	_float_layer = Control.new()
	_float_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_float_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_float_layer)

	# Move overlays to top
	move_child(_floridex,   get_child_count() - 1)
	move_child(_cardviewer, get_child_count() - 1)

	_connect_signals()
	_full_refresh()

# ── Overlays ──────────────────────────────────────────────────────────────────

func _build_overlays() -> void:
	var FloridexScript = load("res://scripts/Floridex.gd")
	_floridex = FloridexScript.new()
	_floridex.visible = false
	_floridex.card_selected.connect(_on_dex_card_selected)
	add_child(_floridex)

	var ViewerScript = load("res://scripts/CardViewer.gd")
	_cardviewer = ViewerScript.new()
	_cardviewer.visible = false
	add_child(_cardviewer)

# ── Top bar ───────────────────────────────────────────────────────────────────

func _build_top_bar(parent: Control) -> void:
	var panel = _make_panel(C_BLUE)
	panel.add_theme_stylebox_override("panel", _flat_style(C_BLUE, 0))
	parent.add_child(panel)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)

	var lbl_title = Label.new()
	lbl_title.text = "Florin Cards"
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color.WHITE)
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl_title)

	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(right_vbox)

	_lbl_balance = Label.new()
	_lbl_balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_balance.add_theme_font_size_override("font_size", 18)
	_lbl_balance.add_theme_color_override("font_color", Color.WHITE)
	right_vbox.add_child(_lbl_balance)

	var sub_row = HBoxContainer.new()
	sub_row.add_theme_constant_override("separation", 8)
	right_vbox.add_child(sub_row)

	_lbl_rate = Label.new()
	_lbl_rate.add_theme_font_size_override("font_size", 11)
	_lbl_rate.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	sub_row.add_child(_lbl_rate)

	_lbl_total = Label.new()
	_lbl_total.add_theme_font_size_override("font_size", 11)
	_lbl_total.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	sub_row.add_child(_lbl_total)

# ── Save bar ──────────────────────────────────────────────────────────────────

func _build_save_bar(parent: Control) -> void:
	var m = _make_margin(parent, 10, 10, 6, 6)
	var hbox = HBoxContainer.new()
	m.add_child(hbox)

	_lbl_save_time = Label.new()
	_lbl_save_time.add_theme_font_size_override("font_size", 11)
	_lbl_save_time.add_theme_color_override("font_color", C_TEXT3)
	_lbl_save_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(_lbl_save_time)

	var btn_reset = _make_btn("Reset", C_RED)
	btn_reset.add_theme_font_size_override("font_size", 11)
	btn_reset.pressed.connect(_on_reset_pressed)
	hbox.add_child(btn_reset)

# ── Floridex button ───────────────────────────────────────────────────────────

func _build_floridex_button(parent: Control) -> void:
	var m = _make_margin(parent, 12, 12, 8, 8)
	_btn_floridex = Button.new()
	_btn_floridex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#EEF3FA")
	s.border_color = C_BLUE
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	s.content_margin_left   = 16
	s.content_margin_right  = 16
	s.content_margin_top    = 12
	s.content_margin_bottom = 12
	_btn_floridex.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate()
	sh.bg_color = Color("#DDE8F8")
	_btn_floridex.add_theme_stylebox_override("hover", sh)
	_btn_floridex.add_theme_color_override("font_color", C_BLUE)
	_btn_floridex.add_theme_font_size_override("font_size", 16)
	_btn_floridex.pressed.connect(_on_floridex_pressed)
	m.add_child(_btn_floridex)

# ── Tap area ──────────────────────────────────────────────────────────────────

func _build_tap_area(parent: Control) -> void:
	var section = _section_container(parent, "Do a Chore")

	var btn_tap = Button.new()
	btn_tap.text = "👋  Tap to Earn +0.1 fl"
	btn_tap.custom_minimum_size = Vector2(0, 80)
	btn_tap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s = StyleBoxFlat.new()
	s.bg_color = C_GREEN
	s.set_corner_radius_all(10)
	s.content_margin_left   = 20
	s.content_margin_right  = 20
	s.content_margin_top    = 16
	s.content_margin_bottom = 16
	btn_tap.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate()
	sh.bg_color = C_GREEN.lightened(0.1)
	btn_tap.add_theme_stylebox_override("hover", sh)
	btn_tap.add_theme_color_override("font_color", Color.WHITE)
	btn_tap.add_theme_font_size_override("font_size", 18)
	btn_tap.pressed.connect(_on_tap_pressed.bind(btn_tap))
	section.add_child(btn_tap)

	_lbl_tap_count = Label.new()
	_lbl_tap_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_tap_count.add_theme_font_size_override("font_size", 12)
	_lbl_tap_count.add_theme_color_override("font_color", C_TEXT3)
	section.add_child(_lbl_tap_count)

# ── Chore section ─────────────────────────────────────────────────────────────

func _build_chore_section(parent: Control) -> void:
	var section = _section_container(parent, "Hire Help")
	_chore_rows.clear()

	for i in range(CardDatabase.CHORES.size()):
		var chore = CardDatabase.CHORES[i]
		var row_data = {}

		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _card_style())
		section.add_child(panel)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		panel.add_child(hbox)

		var icon_lbl = Label.new()
		icon_lbl.text = chore["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 28)
		icon_lbl.custom_minimum_size = Vector2(36, 0)
		hbox.add_child(icon_lbl)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(info_vbox)

		var lbl_name = Label.new()
		lbl_name.text = chore["name"]
		lbl_name.add_theme_font_size_override("font_size", 13)
		lbl_name.add_theme_color_override("font_color", C_TEXT)
		info_vbox.add_child(lbl_name)

		var sub_hbox = HBoxContainer.new()
		sub_hbox.add_theme_constant_override("separation", 8)
		info_vbox.add_child(sub_hbox)

		var lbl_rate = Label.new()
		lbl_rate.add_theme_font_size_override("font_size", 11)
		lbl_rate.add_theme_color_override("font_color", C_GREEN)
		sub_hbox.add_child(lbl_rate)
		row_data["lbl_rate"] = lbl_rate

		var lbl_count = Label.new()
		lbl_count.add_theme_font_size_override("font_size", 11)
		lbl_count.add_theme_color_override("font_color", C_TEXT3)
		sub_hbox.add_child(lbl_count)
		row_data["lbl_count"] = lbl_count

		var right_vbox = VBoxContainer.new()
		right_vbox.add_theme_constant_override("separation", 4)
		hbox.add_child(right_vbox)

		var lbl_cost = Label.new()
		lbl_cost.add_theme_font_size_override("font_size", 12)
		lbl_cost.add_theme_color_override("font_color", C_TEXT2)
		lbl_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		right_vbox.add_child(lbl_cost)
		row_data["lbl_cost"] = lbl_cost

		var btn_buy = _make_btn("Hire", C_BLUE)
		btn_buy.add_theme_font_size_override("font_size", 12)
		btn_buy.pressed.connect(_on_buy_chore.bind(i))
		right_vbox.add_child(btn_buy)
		row_data["btn_buy"] = btn_buy
		row_data["panel"]   = panel

		_chore_rows.append(row_data)

# ── Pack section ──────────────────────────────────────────────────────────────

func _build_pack_section(parent: Control) -> void:
	var section = _section_container(parent, "Card Packs")
	_pack_cards.clear()
	_pack_tweens.clear()

	for i in range(CardDatabase.PACKS.size()):
		var pack = CardDatabase.PACKS[i]
		var pd   = {}

		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _card_style())
		section.add_child(panel)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		panel.add_child(vbox)

		# Top row: icon + label + purchased count
		var top = HBoxContainer.new()
		vbox.add_child(top)

		var lbl_icon = Label.new()
		lbl_icon.text = pack["icon"]
		lbl_icon.add_theme_font_size_override("font_size", 24)
		top.add_child(lbl_icon)

		var lbl_name = Label.new()
		lbl_name.text = pack["label"]
		lbl_name.add_theme_font_size_override("font_size", 15)
		lbl_name.add_theme_color_override("font_color", C_TEXT)
		lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(lbl_name)

		var lbl_event = Label.new()
		lbl_event.add_theme_font_size_override("font_size", 11)
		lbl_event.add_theme_color_override("font_color", C_RED)
		top.add_child(lbl_event)
		pd["lbl_event"] = lbl_event

		# Savings / cost info
		var info_row = HBoxContainer.new()
		vbox.add_child(info_row)

		var lbl_savings = Label.new()
		lbl_savings.add_theme_font_size_override("font_size", 12)
		lbl_savings.add_theme_color_override("font_color", C_TEXT2)
		lbl_savings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_row.add_child(lbl_savings)
		pd["lbl_savings"] = lbl_savings

		var lbl_cost = Label.new()
		lbl_cost.add_theme_font_size_override("font_size", 12)
		lbl_cost.add_theme_color_override("font_color", C_TEXT2)
		info_row.add_child(lbl_cost)
		pd["lbl_cost"] = lbl_cost

		# Progress bar
		var bar = ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 1
		bar.value     = 0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 10)
		var bar_bg = StyleBoxFlat.new()
		bar_bg.bg_color = C_BORDER
		bar_bg.set_corner_radius_all(5)
		bar.add_theme_stylebox_override("background", bar_bg)
		var bar_fill = StyleBoxFlat.new()
		bar_fill.bg_color = C_BLUE
		bar_fill.set_corner_radius_all(5)
		bar.add_theme_stylebox_override("fill", bar_fill)
		vbox.add_child(bar)
		pd["bar"] = bar

		# Open button
		var btn_open = _make_btn("Open Pack", C_BLUE)
		btn_open.pressed.connect(_on_open_pack.bind(i))
		vbox.add_child(btn_open)
		pd["btn_open"] = btn_open
		pd["panel"]    = panel

		_pack_cards.append(pd)
		_pack_tweens.append(null)

# ── Latest pull ───────────────────────────────────────────────────────────────

func _build_latest_pull(parent: Control) -> void:
	var section = _section_container(parent, "Latest Pull")

	_latest_pull_header = Label.new()
	_latest_pull_header.text = "Open a pack to see your cards!"
	_latest_pull_header.add_theme_font_size_override("font_size", 13)
	_latest_pull_header.add_theme_color_override("font_color", C_TEXT3)
	_latest_pull_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section.add_child(_latest_pull_header)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size      = Vector2(0, 160)
	scroll.vertical_scroll_mode     = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal    = Control.SIZE_EXPAND_FILL
	section.add_child(scroll)

	_latest_pull_container = HBoxContainer.new()
	_latest_pull_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_latest_pull_container)

# ── Upgrades section ──────────────────────────────────────────────────────────

func _build_upgrades_section(parent: Control) -> void:
	var section = _section_container(parent, "Luck Upgrades")
	_upgrade_items.clear()

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(grid)

	for i in range(CardDatabase.UPGRADES.size()):
		var upg = CardDatabase.UPGRADES[i]
		var ud  = {}

		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _card_style())
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(panel)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		panel.add_child(vbox)

		var top_row = HBoxContainer.new()
		vbox.add_child(top_row)

		var lbl_icon = Label.new()
		lbl_icon.text = upg["icon"]
		lbl_icon.add_theme_font_size_override("font_size", 18)
		top_row.add_child(lbl_icon)

		var lbl_name = Label.new()
		lbl_name.text = upg["name"]
		lbl_name.add_theme_font_size_override("font_size", 12)
		lbl_name.add_theme_color_override("font_color", C_TEXT)
		lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		top_row.add_child(lbl_name)

		var lbl_desc = Label.new()
		lbl_desc.text = upg["desc"]
		lbl_desc.add_theme_font_size_override("font_size", 10)
		lbl_desc.add_theme_color_override("font_color", C_TEXT2)
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(lbl_desc)

		var btn_buy = _make_btn(NumberFormatter.fmt(upg["cost"]) + " fl", C_BLUE)
		btn_buy.add_theme_font_size_override("font_size", 11)
		btn_buy.pressed.connect(_on_buy_upgrade.bind(i))
		vbox.add_child(btn_buy)

		ud["panel"]   = panel
		ud["btn_buy"] = btn_buy
		_upgrade_items.append(ud)

# ── Collection summary ────────────────────────────────────────────────────────

func _build_collection_summary(parent: Control) -> void:
	var section = _section_container(parent, "Collection")
	_rarity_rows.clear()

	# Table header
	var header = HBoxContainer.new()
	section.add_child(header)
	for h_text in ["Rarity", "Unique", "Total", "Dupes"]:
		var lbl = Label.new()
		lbl.text = h_text
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", C_TEXT3)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
		header.add_child(lbl)

	var sep = HSeparator.new()
	section.add_child(sep)

	for rarity in CardDatabase.RARITY_ORDER:
		var rd = {}
		var row = HBoxContainer.new()
		section.add_child(row)

		var lbl_rarity = Label.new()
		lbl_rarity.text = CardDatabase.RARITY_LABELS[rarity]
		lbl_rarity.add_theme_font_size_override("font_size", 12)
		lbl_rarity.add_theme_color_override("font_color", CardDatabase.RARITY_TEXT_COLORS[rarity])
		lbl_rarity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl_rarity)

		for key in ["lbl_unique", "lbl_total", "lbl_dupe"]:
			var lbl = Label.new()
			lbl.text = "0"
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", C_TEXT2)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
			row.add_child(lbl)
			rd[key] = lbl

		_rarity_rows[rarity] = rd

	var sep2 = HSeparator.new()
	section.add_child(sep2)

	var sell_row = HBoxContainer.new()
	sell_row.add_theme_constant_override("separation", 8)
	section.add_child(sell_row)

	_lbl_total_dupes = Label.new()
	_lbl_total_dupes.add_theme_font_size_override("font_size", 12)
	_lbl_total_dupes.add_theme_color_override("font_color", C_TEXT2)
	_lbl_total_dupes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_row.add_child(_lbl_total_dupes)

	_btn_sell_dupes = _make_btn("Sell 50 Dupes → 100 fl", C_GREEN)
	_btn_sell_dupes.add_theme_font_size_override("font_size", 12)
	_btn_sell_dupes.pressed.connect(_on_sell_dupes)
	sell_row.add_child(_btn_sell_dupes)

# ── Field notes ───────────────────────────────────────────────────────────────

func _build_field_notes(parent: Control) -> void:
	var section = _section_container(parent, "Field Notes")
	_field_notes_vbox = VBoxContainer.new()
	_field_notes_vbox.add_theme_constant_override("separation", 4)
	section.add_child(_field_notes_vbox)

# ── Signal connections ────────────────────────────────────────────────────────

func _connect_signals() -> void:
	GameState.florins_changed.connect(_on_florins_changed)
	GameState.rate_changed.connect(_on_rate_changed)
	GameState.pack_opened.connect(_on_pack_opened)
	GameState.collection_changed.connect(_on_collection_changed)
	GameState.log_updated.connect(_on_log_updated)
	GameState.dupes_changed.connect(_on_dupes_changed)
	GameState.upgrades_changed.connect(_on_upgrades_changed)
	GameState.chores_changed.connect(_on_chores_changed)
	GameState.state_reset.connect(_full_refresh)

# ── Full refresh ──────────────────────────────────────────────────────────────

func _full_refresh() -> void:
	_update_top_bar()
	_update_chores()
	_update_packs()
	_update_upgrades()
	_update_collection_summary()
	_update_field_notes(GameState.log_lines)
	_update_tap_count()

func _update_top_bar() -> void:
	_lbl_balance.text = NumberFormatter.fmt(GameState.florins) + " fl"
	_lbl_rate.text    = NumberFormatter.fmt_rate(GameState.get_fl_per_sec())
	_lbl_total.text   = "Total: " + NumberFormatter.fmt(GameState.total_earned)
	_lbl_save_time.text = "Saved: " + NumberFormatter.fmt_time(GameState.last_save_time)
	_btn_floridex.text  = "📚  Floridex — %d / %d cards" % [
		GameState.get_unique_collected(), CardDatabase.total_cards()
	]

func _update_tap_count() -> void:
	_lbl_tap_count.text = "Taps: %d" % GameState.tap_count

func _update_chores() -> void:
	var total_earned = GameState.total_earned
	for i in range(_chore_rows.size()):
		var chore  = CardDatabase.CHORES[i]
		var rd     = _chore_rows[i]
		var count  = GameState.chore_counts[i]
		var cost   = GameState.get_chore_cost(i)
		var unlocked = total_earned >= chore["unlock_at"]
		var can_buy  = GameState.florins >= cost and unlocked

		rd["panel"].visible = unlocked
		if not unlocked:
			continue

		var fl_contribution = chore["fl_per_sec"] * count
		rd["lbl_count"].text = "Owned: %d" % count
		rd["lbl_rate"].text  = "+%s fl/s" % NumberFormatter.fmt(fl_contribution) if count > 0 else "%s fl/s each" % NumberFormatter.fmt(chore["fl_per_sec"])
		rd["lbl_cost"].text  = NumberFormatter.fmt(cost) + " fl"
		rd["btn_buy"].disabled = not can_buy

func _update_packs() -> void:
	var total_earned = GameState.total_earned
	for i in range(_pack_cards.size()):
		var pack    = CardDatabase.PACKS[i]
		var pd      = _pack_cards[i]
		var cost    = GameState.get_pack_cost(i)
		var savings = GameState.pack_state[i]["savings"]
		var purchased = GameState.pack_state[i]["purchased"]
		var unlocked = total_earned >= pack["unlock_at"]

		# Show pack once unlocked
		pd["panel"].visible = unlocked
		if not unlocked:
			continue

		pd["lbl_savings"].text = "Saved: " + NumberFormatter.fmt(savings)
		pd["lbl_cost"].text    = " / " + NumberFormatter.fmt(cost) + " fl"

		var ratio = clampf(savings / cost, 0.0, 1.0) if cost > 0 else 0.0

		# Smooth tween on progress bar
		if _pack_tweens[i] and is_instance_valid(_pack_tweens[i]):
			_pack_tweens[i].kill()
		_pack_tweens[i] = create_tween()
		_pack_tweens[i].tween_property(pd["bar"], "value", ratio, 0.4)

		pd["btn_open"].disabled = savings < cost
		pd["lbl_event"].text = "(%d opened)" % purchased if purchased > 0 else ""

func _update_upgrades() -> void:
	var total_earned = GameState.total_earned
	for i in range(_upgrade_items.size()):
		var upg  = CardDatabase.UPGRADES[i]
		var ud   = _upgrade_items[i]
		var unlocked = total_earned >= upg["unlock_at"]
		var bought   = GameState.upgrades_bought[i]

		ud["panel"].visible = unlocked
		if not unlocked:
			continue

		if bought:
			ud["btn_buy"].text     = "✓ Owned"
			ud["btn_buy"].disabled = true
			var s = StyleBoxFlat.new()
			s.bg_color = C_GREEN
			s.set_corner_radius_all(6)
			s.content_margin_left = 8; s.content_margin_right = 8
			s.content_margin_top  = 6; s.content_margin_bottom = 6
			ud["btn_buy"].add_theme_stylebox_override("normal", s)
			ud["btn_buy"].add_theme_stylebox_override("disabled", s)
		else:
			ud["btn_buy"].disabled = GameState.florins < upg["cost"]

func _update_collection_summary() -> void:
	for rarity in CardDatabase.RARITY_ORDER:
		var rd          = _rarity_rows[rarity]
		var total_pool  = CardDatabase.CARD_NAMES[rarity].size()
		var unique      = 0
		var total_owned = 0
		for cname in CardDatabase.CARD_NAMES[rarity]:
			var cnt = GameState.collected.get(cname, 0)
			if cnt > 0:
				unique += 1
				total_owned += cnt
		var dupes = GameState.duplicates.get(rarity, 0)
		rd["lbl_unique"].text = "%d/%d" % [unique, total_pool]
		rd["lbl_total"].text  = str(total_owned)
		rd["lbl_dupe"].text   = str(dupes)

	var total_dupes = GameState.get_total_dupes()
	_lbl_total_dupes.text    = "Total dupes: %d (need 50 to sell)" % total_dupes
	_btn_sell_dupes.disabled = total_dupes < 50

func _update_field_notes(lines: Array) -> void:
	for child in _field_notes_vbox.get_children():
		child.queue_free()
	for line in lines:
		var lbl = Label.new()
		lbl.text = "• " + line
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", C_TEXT2)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_field_notes_vbox.add_child(lbl)

# ── Signal handlers ───────────────────────────────────────────────────────────

func _on_florins_changed(_v: float) -> void:
	_update_top_bar()
	_update_chores()
	_update_packs()
	_update_upgrades()
	_update_collection_summary()

func _on_rate_changed(_r: float) -> void:
	_lbl_rate.text = NumberFormatter.fmt_rate(GameState.get_fl_per_sec())

func _on_pack_opened(result: Dictionary) -> void:
	_show_pack_reveal(result)

func _on_collection_changed() -> void:
	_update_collection_summary()
	_update_top_bar()

func _on_log_updated(lines: Array) -> void:
	_update_field_notes(lines)

func _on_dupes_changed(_total: int) -> void:
	_update_collection_summary()

func _on_upgrades_changed() -> void:
	_update_upgrades()

func _on_chores_changed() -> void:
	_update_chores()
	_update_top_bar()

# ── Pack reveal ───────────────────────────────────────────────────────────────

func _show_pack_reveal(result: Dictionary) -> void:
	for child in _latest_pull_container.get_children():
		child.queue_free()

	var event = result.get("event", "Normal")
	if event != "Normal":
		_latest_pull_header.text = "★ " + event + " ★"
		_latest_pull_header.add_theme_color_override("font_color", C_RED)
	else:
		_latest_pull_header.text = "Latest Pull"
		_latest_pull_header.add_theme_color_override("font_color", C_TEXT3)

	var cards = result.get("cards", [])
	for i in range(cards.size()):
		var card   = cards[i]
		var cname  = card.get("name", "")
		# It's a dupe if collected count > 1 (already incremented in GameState)
		var is_dupe = GameState.collected.get(cname, 0) > 1

		var small = CardWidgets.make_small_card(card, is_dupe)
		small.pivot_offset = Vector2(50, 75)
		small.scale  = Vector2(0.01, 0.01)
		small.modulate.a = 0.0
		_latest_pull_container.add_child(small)

		var tween = create_tween()
		tween.tween_interval(i * 0.12)
		tween.set_parallel(true)
		tween.tween_property(small, "scale",      Vector2(1, 1), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(small, "modulate:a", 1.0,           0.25)

# ── Button handlers ───────────────────────────────────────────────────────────

func _on_tap_pressed(btn: Button) -> void:
	GameState.tap()
	_update_tap_count()
	_show_float_label(btn.global_position + Vector2(randf_range(10, 50), randf_range(0, 20)), "+0.1 fl")

func _on_buy_chore(idx: int) -> void:
	GameState.buy_chore(idx)

func _on_open_pack(idx: int) -> void:
	GameState.open_pack(idx)

func _on_buy_upgrade(idx: int) -> void:
	GameState.buy_upgrade(idx)

func _on_sell_dupes() -> void:
	GameState.sell_dupes()

func _on_floridex_pressed() -> void:
	_floridex.refresh()
	_floridex.visible = true

func _on_dex_card_selected(card: Dictionary) -> void:
	var owned_list: Array = []
	for c in CardDatabase.CARDS:
		if GameState.collected.get(c["name"], 0) > 0:
			owned_list.append(c)
	_cardviewer.open_card(card, owned_list)

func _on_reset_pressed() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Reset Game"
	dialog.dialog_text = "Are you sure? All progress will be lost!"
	dialog.confirmed.connect(_do_reset)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()

func _do_reset() -> void:
	SaveManager.reset()
	_full_refresh()

# ── Floating label animation ──────────────────────────────────────────────────

func _show_float_label(pos: Vector2, text: String) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", C_GREEN)
	lbl.position = pos
	_float_layer.add_child(lbl)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position:y", pos.y - 55, 0.9)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(lbl.queue_free)

# ── Builder helpers ───────────────────────────────────────────────────────────

func _section_container(parent: Control, title: String) -> VBoxContainer:
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   12)
	m.add_theme_constant_override("margin_right",  12)
	m.add_theme_constant_override("margin_top",    12)
	m.add_theme_constant_override("margin_bottom", 8)
	parent.add_child(m)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	m.add_child(vbox)

	var lbl = Label.new()
	lbl.text = title.to_upper()
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", C_TEXT3)
	vbox.add_child(lbl)

	return vbox

func _make_margin(parent: Control, l: int, r: int, t: int, b: int) -> MarginContainer:
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   l)
	m.add_theme_constant_override("margin_right",  r)
	m.add_theme_constant_override("margin_top",    t)
	m.add_theme_constant_override("margin_bottom", b)
	parent.add_child(m)
	return m

func _make_panel(bg: Color) -> PanelContainer:
	var p = PanelContainer.new()
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 10
	s.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", s)
	return p

func _card_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color     = C_BG
	s.border_color = C_BORDER
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left   = 10
	s.content_margin_right  = 10
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	return s

func _flat_style(color: Color, radius: int = 6) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 10
	s.content_margin_bottom = 10
	return s

func _make_btn(label: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = label
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(6)
	s.content_margin_left   = 10
	s.content_margin_right  = 10
	s.content_margin_top    = 6
	s.content_margin_bottom = 6
	btn.add_theme_stylebox_override("normal", s)
	var sh = s.duplicate()
	sh.bg_color = color.lightened(0.12)
	btn.add_theme_stylebox_override("hover", sh)
	var sd = StyleBoxFlat.new()
	sd.bg_color = Color("#BBBBBB")
	sd.set_corner_radius_all(6)
	sd.content_margin_left   = 10
	sd.content_margin_right  = 10
	sd.content_margin_top    = 6
	sd.content_margin_bottom = 6
	btn.add_theme_stylebox_override("disabled", sd)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color("#EEEEEE"))
	return btn

func _add_divider(parent: Control) -> void:
	var sep = HSeparator.new()
	parent.add_child(sep)

func _add_spacer(parent: Control, height: int) -> void:
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, height)
	parent.add_child(sp)
