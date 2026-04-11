extends Control

# ── UI references ─────────────────────────────────────────────────────────────
var _lbl_balance:    Label
var _lbl_rate:       Label
var _lbl_total:      Label
var _lbl_save_time:  Label
var _btn_floridex:   Button
var _lbl_tap_count:  Label

const CHORES_PER_PAGE = 4
var _chore_rows:     Array = []  # [{panel, lbl_count, lbl_cost, lbl_rate, btn_buy}]
var _chore_page:     int   = 0
var _btn_chore_prev: Button
var _btn_chore_next: Button
var _lbl_chore_page: Label
var _pack_cards:     Array = []  # [{lbl_savings, lbl_cost, bar, btn_open, lbl_event}]
var _pack_tweens:    Array = []

var _latest_pull_container: HBoxContainer
var _latest_pull_header:    Label

var _upgrade_items:  Array = []  # [{container, btn_buy}]
var _btn_sell_dupes:  Button
var _btn_sell_small:  Button
var _field_notes_vbox: VBoxContainer

var _float_layer:  Control
var _floridex:     Control
var _cardviewer:   Control
var _debug_panel:  Control
var _lbl_title:    Label

# ── Debug tap trigger ─────────────────────────────────────────────────────────
var _debug_tap_count: int   = 0
var _debug_tap_timer: float = 0.0
const DEBUG_TAPS_REQUIRED   = 5
const DEBUG_TAP_WINDOW      = 2.0

# ── Tab navigation ─────────────────────────────────────────────────────────────
var _screens:    Array = []
var _active_tab: int   = 0
var _nav_btns:   Array = []
var _cards_tab_was_unlocked:    bool = false
var _upgrades_tab_was_unlocked: bool = false

# ── Progressive reveal refs ───────────────────────────────────────────────────
var _collection_panel: Control

# ── Compact collection refs ───────────────────────────────────────────────────
var _lbl_collect: Label
var _lbl_dupes:   Label
var _bar_collect: ProgressBar

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
	_build_overlays()

	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 0)
	add_child(root_vbox)

	_build_top_bar(root_vbox)

	var content_area = Control.new()
	content_area.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(content_area)

	_build_screen_earn(content_area)
	_build_screen_upgrades(content_area)
	_build_screen_cards(content_area)

	_build_bottom_nav(root_vbox)

	_float_layer = Control.new()
	_float_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_float_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_float_layer)

	move_child(_floridex,    get_child_count() - 1)
	move_child(_cardviewer,  get_child_count() - 1)
	move_child(_debug_panel, get_child_count() - 1)

	_connect_signals()

	# Silently mark already-unlocked tabs so we don't fire banners on load
	_cards_tab_was_unlocked    = GameState.total_earned >= CardDatabase.PACKS[0]["base_cost"]
	_upgrades_tab_was_unlocked = GameState.total_earned >= CardDatabase.UPGRADES[0]["unlock_at"]

	_switch_tab(0)
	_full_refresh()

	if not GameState.pending_offline.is_empty():
		_show_offline_banner(GameState.pending_offline)
		GameState.pending_offline = {}

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

	var DebugScript = load("res://scripts/DebugPanel.gd")
	_debug_panel = DebugScript.new()
	_debug_panel.visible = false
	add_child(_debug_panel)

# ── Top bar (merged with save bar) ───────────────────────────────────────────

func _build_top_bar(parent: Control) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _flat_style(C_BLUE, 0))
	parent.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Row 1: Title | Balance
	var row1 = HBoxContainer.new()
	vbox.add_child(row1)

	_lbl_title = Label.new()
	_lbl_title.text = "Florin Cards"
	_lbl_title.add_theme_font_size_override("font_size", 18)
	_lbl_title.add_theme_color_override("font_color", Color.WHITE)
	_lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_title.mouse_filter = Control.MOUSE_FILTER_PASS
	_lbl_title.gui_input.connect(_on_title_input)
	row1.add_child(_lbl_title)

	_lbl_balance = Label.new()
	_lbl_balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_balance.add_theme_font_size_override("font_size", 18)
	_lbl_balance.add_theme_color_override("font_color", Color.WHITE)
	row1.add_child(_lbl_balance)

	# Row 2: Rate | Total | Save time | Reset
	var row2 = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	vbox.add_child(row2)

	_lbl_rate = Label.new()
	_lbl_rate.add_theme_font_size_override("font_size", 10)
	_lbl_rate.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	row2.add_child(_lbl_rate)

	_lbl_total = Label.new()
	_lbl_total.add_theme_font_size_override("font_size", 10)
	_lbl_total.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	_lbl_total.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row2.add_child(_lbl_total)

	_lbl_save_time = Label.new()
	_lbl_save_time.add_theme_font_size_override("font_size", 10)
	_lbl_save_time.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	row2.add_child(_lbl_save_time)

	var btn_reset = Button.new()
	btn_reset.text = "Reset"
	btn_reset.add_theme_font_size_override("font_size", 10)
	btn_reset.add_theme_color_override("font_color", Color.WHITE)
	var rs = StyleBoxFlat.new()
	rs.bg_color = C_RED
	rs.set_corner_radius_all(4)
	rs.content_margin_left = 6;  rs.content_margin_right  = 6
	rs.content_margin_top  = 3;  rs.content_margin_bottom = 3
	btn_reset.add_theme_stylebox_override("normal", rs)
	var rsh = rs.duplicate()
	rsh.bg_color = C_RED.lightened(0.12)
	btn_reset.add_theme_stylebox_override("hover", rsh)
	btn_reset.pressed.connect(_on_reset_pressed)
	row2.add_child(btn_reset)

# ── Bottom nav ────────────────────────────────────────────────────────────────

func _build_bottom_nav(parent: Control) -> void:
	var panel = PanelContainer.new()
	var nav_style = StyleBoxFlat.new()
	nav_style.bg_color          = C_BG
	nav_style.border_color      = C_BORDER
	nav_style.border_width_top  = 1
	nav_style.content_margin_top    = 0
	nav_style.content_margin_bottom = 0
	nav_style.content_margin_left   = 0
	nav_style.content_margin_right  = 0
	panel.add_theme_stylebox_override("panel", nav_style)
	parent.add_child(panel)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	var tabs = [["🌱", "Earn"], ["⬆️", "Upgrades"], ["🃏", "Cards"]]
	for i in range(tabs.size()):
		var btn = Button.new()
		btn.text = ""
		btn.focus_mode = Control.FOCUS_NONE
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 58)
		var btn_normal = StyleBoxFlat.new()
		btn_normal.bg_color = Color.TRANSPARENT
		btn.add_theme_stylebox_override("normal",   btn_normal)
		btn.add_theme_stylebox_override("pressed",  btn_normal)
		btn.add_theme_stylebox_override("focus",    StyleBoxEmpty.new())
		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color(C_BLUE.r, C_BLUE.g, C_BLUE.b, 0.08)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.pressed.connect(_switch_tab.bind(i))

		var inner = VBoxContainer.new()
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.alignment    = BoxContainer.ALIGNMENT_CENTER
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_theme_constant_override("separation", 2)
		btn.add_child(inner)

		var lbl_icon = Label.new()
		lbl_icon.text = tabs[i][0]
		lbl_icon.add_theme_font_size_override("font_size", 20)
		lbl_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_icon.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		inner.add_child(lbl_icon)

		var lbl_text = Label.new()
		lbl_text.text = tabs[i][1]
		lbl_text.add_theme_font_size_override("font_size", 9)
		lbl_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_text.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		inner.add_child(lbl_text)

		_nav_btns.append(btn)
		hbox.add_child(btn)

# ── Tab switching ─────────────────────────────────────────────────────────────

func _switch_tab(idx: int) -> void:
	_active_tab = idx
	for i in range(_screens.size()):
		_screens[i].visible = (i == idx)
	for i in range(_nav_btns.size()):
		var active = (i == idx)
		var bg = StyleBoxFlat.new()
		bg.bg_color = C_BLUE if active else Color.TRANSPARENT
		_nav_btns[i].add_theme_stylebox_override("normal", bg)
		var col = Color.WHITE if active else C_TEXT3
		for child in _nav_btns[i].get_children():
			if child is VBoxContainer:
				for lbl in child.get_children():
					if lbl is Label:
						lbl.add_theme_color_override("font_color", col)

# ── Nav tab unlock system ─────────────────────────────────────────────────────

func _is_cards_tab_unlocked() -> bool:
	return GameState.total_earned >= CardDatabase.PACKS[0]["base_cost"]

func _is_upgrades_tab_unlocked() -> bool:
	return GameState.total_earned >= CardDatabase.UPGRADES[0]["unlock_at"]

func _update_nav_tabs() -> void:
	var unlocked = [true, _is_upgrades_tab_unlocked(), _is_cards_tab_unlocked()]

	# Fire one-time unlock banners; reset flags if tab goes locked again (e.g. debug reset)
	if unlocked[2]:
		if not _cards_tab_was_unlocked:
			_cards_tab_was_unlocked = true
			GameState.add_log("🃏 Card Packs unlocked!")
			_show_event_banner("🃏  Card Packs unlocked!", Color("#185FA5"), 2.5)
	else:
		_cards_tab_was_unlocked = false

	if unlocked[1]:
		if not _upgrades_tab_was_unlocked:
			_upgrades_tab_was_unlocked = true
			GameState.add_log("⬆️ Upgrades unlocked!")
			_show_event_banner("⬆️  Upgrades unlocked!", Color("#185FA5"), 2.5)
	else:
		_upgrades_tab_was_unlocked = false

	# If active tab just became locked, fall back to Earn
	if not unlocked[_active_tab]:
		_switch_tab(0)

	var tab_icons = ["🌱", "⬆️", "🃏"]
	for i in range(_nav_btns.size()):
		var btn       = _nav_btns[i]
		var is_active = (_active_tab == i)
		var is_open   = unlocked[i]

		btn.disabled = not is_open

		var bg = StyleBoxFlat.new()
		bg.bg_color = C_BLUE if (is_active and is_open) else Color.TRANSPARENT
		btn.add_theme_stylebox_override("normal", bg)

		var col = Color.WHITE if (is_active and is_open) else (C_TEXT2 if is_open else C_TEXT3)
		for child in btn.get_children():
			if child is VBoxContainer:
				for j in range(child.get_child_count()):
					var lbl = child.get_child(j)
					if lbl is Label:
						lbl.add_theme_color_override("font_color", col)
						if j == 0:  # icon label
							lbl.text = "🔒" if not is_open else tab_icons[i]

# ── Screen builders ───────────────────────────────────────────────────────────

func _build_screen_earn(content_area: Control) -> void:
	var screen = VBoxContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_theme_constant_override("separation", 0)
	screen.visible = false
	content_area.add_child(screen)
	_screens.append(screen)

	_build_tap_area(screen)
	_build_chore_section(screen)
	_build_field_notes(screen)

func _build_screen_upgrades(content_area: Control) -> void:
	var screen = ScrollContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.visible = false
	content_area.add_child(screen)
	_screens.append(screen)

	var m = MarginContainer.new()
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	screen.add_child(m)

	_build_upgrades_section(m)

func _build_screen_cards(content_area: Control) -> void:
	var screen = VBoxContainer.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_theme_constant_override("separation", 0)
	screen.visible = false
	content_area.add_child(screen)
	_screens.append(screen)

	# Floridex button
	var m_dex = _make_margin(screen, 12, 12, 8, 4)
	_btn_floridex = Button.new()
	_btn_floridex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_floridex.custom_minimum_size   = Vector2(0, 44)
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#EEF3FA")
	s.border_color = C_BLUE
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	s.content_margin_left = 16; s.content_margin_right  = 16
	s.content_margin_top  = 8;  s.content_margin_bottom = 8
	_btn_floridex.add_theme_stylebox_override("normal", s)
	var fsh = s.duplicate()
	fsh.bg_color = Color("#DDE8F8")
	_btn_floridex.add_theme_stylebox_override("hover", fsh)
	_btn_floridex.add_theme_color_override("font_color", C_BLUE)
	_btn_floridex.add_theme_font_size_override("font_size", 14)
	_btn_floridex.pressed.connect(_on_floridex_pressed)
	m_dex.add_child(_btn_floridex)

	_build_pack_section_compact(screen)
	_build_latest_pull(screen)
	_build_collection_compact(screen)

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
		panel.visible = false  # controlled by pagination
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

	# Pagination controls
	var page_bar = HBoxContainer.new()
	page_bar.add_theme_constant_override("separation", 8)
	page_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	section.add_child(page_bar)

	_btn_chore_prev = _make_btn("< Prev", C_TEXT2)
	_btn_chore_prev.add_theme_font_size_override("font_size", 11)
	_btn_chore_prev.custom_minimum_size = Vector2(64, 0)
	_btn_chore_prev.pressed.connect(_on_chore_prev)
	page_bar.add_child(_btn_chore_prev)

	_lbl_chore_page = Label.new()
	_lbl_chore_page.add_theme_font_size_override("font_size", 11)
	_lbl_chore_page.add_theme_color_override("font_color", C_TEXT3)
	_lbl_chore_page.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_chore_page.custom_minimum_size = Vector2(80, 0)
	page_bar.add_child(_lbl_chore_page)

	_btn_chore_next = _make_btn("Next >", C_TEXT2)
	_btn_chore_next.add_theme_font_size_override("font_size", 11)
	_btn_chore_next.custom_minimum_size = Vector2(64, 0)
	_btn_chore_next.pressed.connect(_on_chore_next)
	page_bar.add_child(_btn_chore_next)

# ── Pack section (compact horizontal rows) ────────────────────────────────────

func _build_pack_section_compact(parent: Control) -> void:
	var section = _section_container(parent, "Card Packs")
	_pack_cards.clear()
	_pack_tweens.clear()

	for i in range(CardDatabase.PACKS.size()):
		var pack = CardDatabase.PACKS[i]
		var pd   = {}

		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _card_style())
		section.add_child(panel)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		panel.add_child(hbox)

		# Left: icon + name/savings stack
		var lbl_icon = Label.new()
		lbl_icon.text = pack["icon"]
		lbl_icon.add_theme_font_size_override("font_size", 22)
		lbl_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(lbl_icon)

		var name_vbox = VBoxContainer.new()
		name_vbox.add_theme_constant_override("separation", 1)
		hbox.add_child(name_vbox)

		var lbl_name = Label.new()
		lbl_name.text = pack["label"]
		lbl_name.add_theme_font_size_override("font_size", 12)
		lbl_name.add_theme_color_override("font_color", C_TEXT)
		name_vbox.add_child(lbl_name)

		var lbl_savings = Label.new()
		lbl_savings.add_theme_font_size_override("font_size", 10)
		lbl_savings.add_theme_color_override("font_color", C_TEXT2)
		name_vbox.add_child(lbl_savings)
		pd["lbl_savings"] = lbl_savings

		var lbl_event = Label.new()
		lbl_event.add_theme_font_size_override("font_size", 9)
		lbl_event.add_theme_color_override("font_color", C_RED)
		name_vbox.add_child(lbl_event)
		pd["lbl_event"] = lbl_event

		# Middle: progress bar (expands to fill remaining space)
		var bar = ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 1
		bar.value     = 0
		bar.show_percentage = false
		bar.custom_minimum_size   = Vector2(0, 8)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		var bar_bg = StyleBoxFlat.new()
		bar_bg.bg_color = C_BORDER
		bar_bg.set_corner_radius_all(4)
		bar.add_theme_stylebox_override("background", bar_bg)
		var bar_fill = StyleBoxFlat.new()
		bar_fill.bg_color = C_BLUE
		bar_fill.set_corner_radius_all(4)
		bar.add_theme_stylebox_override("fill", bar_fill)
		hbox.add_child(bar)
		pd["bar"] = bar

		# Right: open button
		var btn_open = _make_btn("Open", C_BLUE)
		btn_open.add_theme_font_size_override("font_size", 11)
		btn_open.custom_minimum_size = Vector2(56, 0)
		btn_open.pressed.connect(_on_open_pack.bind(i))
		hbox.add_child(btn_open)
		pd["btn_open"] = btn_open
		pd["lbl_cost"] = null  # not used in compact layout
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

	_latest_pull_container = HBoxContainer.new()
	_latest_pull_container.add_theme_constant_override("separation", 6)
	_latest_pull_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_latest_pull_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(_latest_pull_container)

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

# ── Collection (compact) ──────────────────────────────────────────────────────

func _build_collection_compact(parent: Control) -> void:
	var section = _section_container(parent, "Collection")
	_collection_panel = section.get_parent()  # the MarginContainer wrapping the section

	_bar_collect = ProgressBar.new()
	_bar_collect.min_value = 0
	_bar_collect.max_value = CardDatabase.total_cards()
	_bar_collect.value     = 0
	_bar_collect.show_percentage = false
	_bar_collect.custom_minimum_size = Vector2(0, 10)
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = C_BORDER
	bar_bg.set_corner_radius_all(5)
	_bar_collect.add_theme_stylebox_override("background", bar_bg)
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = C_BLUE
	bar_fill.set_corner_radius_all(5)
	_bar_collect.add_theme_stylebox_override("fill", bar_fill)
	section.add_child(_bar_collect)

	_lbl_collect = Label.new()
	_lbl_collect.add_theme_font_size_override("font_size", 12)
	_lbl_collect.add_theme_color_override("font_color", C_TEXT2)
	_lbl_collect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section.add_child(_lbl_collect)

	_lbl_dupes = Label.new()
	_lbl_dupes.add_theme_font_size_override("font_size", 12)
	_lbl_dupes.add_theme_color_override("font_color", C_TEXT2)
	_lbl_dupes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section.add_child(_lbl_dupes)

	var sell_row = HBoxContainer.new()
	sell_row.add_theme_constant_override("separation", 8)
	sell_row.alignment = BoxContainer.ALIGNMENT_CENTER
	section.add_child(sell_row)

	_btn_sell_small = _make_btn("Sell 10 → 20 fl", C_GREEN)
	_btn_sell_small.add_theme_font_size_override("font_size", 11)
	_btn_sell_small.pressed.connect(_on_sell_dupes.bind(10))
	sell_row.add_child(_btn_sell_small)

	_btn_sell_dupes = _make_btn("Sell 50 → 100 fl", C_GREEN)
	_btn_sell_dupes.add_theme_font_size_override("font_size", 11)
	_btn_sell_dupes.pressed.connect(_on_sell_dupes.bind(50))
	sell_row.add_child(_btn_sell_dupes)

# ── Field notes ───────────────────────────────────────────────────────────────

func _build_field_notes(parent: Control) -> void:
	var section = _section_container(parent, "Field Notes")
	_field_notes_vbox = VBoxContainer.new()
	_field_notes_vbox.add_theme_constant_override("separation", 4)
	section.add_child(_field_notes_vbox)

# ── Debug trigger ────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _debug_tap_count > 0:
		_debug_tap_timer += delta
		if _debug_tap_timer >= DEBUG_TAP_WINDOW:
			_debug_tap_count = 0
			_debug_tap_timer = 0.0

func _on_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_debug_tap_count += 1
		_debug_tap_timer = 0.0
		if _debug_tap_count >= DEBUG_TAPS_REQUIRED:
			_debug_tap_count = 0
			_debug_panel.visible = true

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
	GameState.chore_milestone.connect(_on_chore_milestone)
	GameState.state_reset.connect(_full_refresh)

# ── Full refresh ──────────────────────────────────────────────────────────────

func _full_refresh() -> void:
	_update_nav_tabs()
	_update_top_bar()
	_update_chores()
	_update_packs()
	_update_upgrades()
	_update_collection_summary()
	_update_field_notes(GameState.log_lines)
	_update_tap_count()

func _update_top_bar() -> void:
	_lbl_balance.text   = NumberFormatter.fmt(GameState.florins) + " fl"
	_lbl_rate.text      = NumberFormatter.fmt_rate(GameState.get_fl_per_sec())
	_lbl_total.text     = "Total: " + NumberFormatter.fmt(GameState.total_earned)
	_lbl_save_time.text = "Saved: " + NumberFormatter.fmt_time(GameState.last_save_time)
	_btn_floridex.text  = "📚  Floridex — %d / %d cards" % [
		GameState.get_unique_collected(), CardDatabase.total_cards()
	]

func _update_tap_count() -> void:
	_lbl_tap_count.text = "Taps: %d" % GameState.tap_count

func _update_chores() -> void:
	var total_earned = GameState.total_earned
	var total_pages  = int(ceil(float(_chore_rows.size()) / CHORES_PER_PAGE))
	_chore_page = clampi(_chore_page, 0, total_pages - 1)

	var page_start = _chore_page * CHORES_PER_PAGE
	var page_end   = mini(page_start + CHORES_PER_PAGE, _chore_rows.size())

	for i in range(_chore_rows.size()):
		var rd = _chore_rows[i]
		if i < page_start or i >= page_end:
			rd["panel"].visible = false
			continue

		var chore    = CardDatabase.CHORES[i]
		var count    = GameState.chore_counts[i]
		var cost     = GameState.get_chore_cost(i)
		var unlocked = total_earned >= chore["unlock_at"]
		var can_buy  = GameState.florins >= cost and unlocked

		rd["panel"].visible = true

		if not unlocked:
			rd["panel"].modulate   = Color(0.75, 0.75, 0.75, 1.0)
			rd["lbl_rate"].text    = "🔒 Unlocks at %s fl earned" % NumberFormatter.fmt(chore["unlock_at"])
			rd["lbl_count"].text   = ""
			rd["lbl_cost"].text    = ""
			rd["btn_buy"].text     = "Locked"
			rd["btn_buy"].disabled = true
			continue

		rd["panel"].modulate   = Color.WHITE
		rd["btn_buy"].text     = "Hire"
		rd["lbl_cost"].text    = NumberFormatter.fmt(cost) + " fl"
		rd["btn_buy"].disabled = not can_buy

		var mult = GameState.chore_milestone_mult(count)
		var fl_contribution = chore["fl_per_sec"] * count * mult
		if count == 0:
			rd["lbl_rate"].text  = "%s fl/s each" % NumberFormatter.fmt(chore["fl_per_sec"])
			rd["lbl_count"].text = ""
		else:
			rd["lbl_rate"].text  = "+%s fl/s" % NumberFormatter.fmt(fl_contribution)
			if mult > 1.0:
				rd["lbl_count"].text = "Owned: %d  ×%d bonus" % [count, int(mult)]
			else:
				rd["lbl_count"].text = "Owned: %d" % count

	_lbl_chore_page.text     = "Page %d / %d" % [_chore_page + 1, total_pages]
	_btn_chore_prev.disabled = _chore_page <= 0
	_btn_chore_next.disabled = _chore_page >= total_pages - 1

func _update_packs() -> void:
	var total_earned = GameState.total_earned
	for i in range(_pack_cards.size()):
		var pack      = CardDatabase.PACKS[i]
		var pd        = _pack_cards[i]
		var cost      = GameState.get_pack_cost(i)
		var savings   = GameState.pack_state[i]["savings"]
		var purchased = GameState.pack_state[i]["purchased"]
		var unlocked  = total_earned >= pack["unlock_at"]

		var pack_id = pack["id"]
		if unlocked and pack["unlock_at"] > 0 and not (pack_id in GameState.packs_announced):
			GameState.packs_announced.append(pack_id)
			GameState.add_log("🎉 %s unlocked!" % pack["label"])
			_show_event_banner("🎉  " + pack["label"] + " unlocked!", Color("#0F6E56"), 2.5)
			SaveManager.save()

		pd["panel"].visible = unlocked
		if not unlocked:
			continue

		pd["lbl_savings"].text = NumberFormatter.fmt(savings) + " / " + NumberFormatter.fmt(cost) + " fl"
		pd["lbl_event"].text   = "(%d opened)" % purchased if purchased > 0 else ""

		var ratio = clampf(savings / cost, 0.0, 1.0) if cost > 0 else 0.0

		if _pack_tweens[i] and is_instance_valid(_pack_tweens[i]):
			_pack_tweens[i].kill()
		_pack_tweens[i] = create_tween()
		_pack_tweens[i].tween_property(pd["bar"], "value", ratio, 0.4)

		pd["btn_open"].disabled = savings < cost

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
			s.content_margin_left = 8; s.content_margin_right  = 8
			s.content_margin_top  = 6; s.content_margin_bottom = 6
			ud["btn_buy"].add_theme_stylebox_override("normal",   s)
			ud["btn_buy"].add_theme_stylebox_override("disabled", s)
		else:
			ud["btn_buy"].disabled = GameState.florins < upg["cost"]

func _update_collection_summary() -> void:
	var unique      = GameState.get_unique_collected()
	var total_dupes = GameState.get_total_dupes()
	var has_cards   = unique > 0

	_btn_floridex.visible      = has_cards
	_collection_panel.visible  = has_cards

	if not has_cards:
		return

	_bar_collect.value  = unique
	_lbl_collect.text   = "%d / %d cards collected" % [unique, CardDatabase.total_cards()]
	_lbl_dupes.text     = "Total dupes: %d" % total_dupes
	_btn_sell_small.disabled = total_dupes < 10
	_btn_sell_dupes.disabled = total_dupes < 50

func _update_field_notes(lines: Array) -> void:
	for child in _field_notes_vbox.get_children():
		child.queue_free()
	var display_lines = lines.slice(maxi(0, lines.size() - 3))
	for line in display_lines:
		var lbl = Label.new()
		lbl.text = "• " + line
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", C_TEXT2)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_field_notes_vbox.add_child(lbl)

# ── Signal handlers ───────────────────────────────────────────────────────────

func _on_florins_changed(_v: float) -> void:
	_update_nav_tabs()
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

	var card_delay_mult = 0.12
	if event == "God Pack":
		GameState.add_log("⭐ GOD PACK opened!")
		_show_event_banner("⭐  GOD PACK  ⭐", Color("#D4AC0D"), 1.5)
		card_delay_mult = 0.28
	elif event == "Double Rare":
		_show_event_banner("★  DOUBLE RARE  ★", Color("#7F77DD"), 0.9)

	var cards = result.get("cards", [])
	for i in range(cards.size()):
		var card      = cards[i]
		var cname     = card.get("name", "")
		var variation = card.get("variation", "normal")
		var is_dupe = GameState.collected.get(cname + "|" + variation, 0) > 1

		var small = CardWidgets.make_small_card(card, is_dupe)
		small.pivot_offset = Vector2(32, 48)
		small.scale      = Vector2(0.01, 0.01)
		small.modulate.a = 0.0
		_latest_pull_container.add_child(small)

		var tween = create_tween()
		tween.tween_interval(i * card_delay_mult)
		tween.set_parallel(true)
		tween.tween_property(small, "scale",      Vector2(1, 1), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(small, "modulate:a", 1.0,           0.25)

	# Switch to Cards tab so the reveal is always visible
	_switch_tab(2)

# ── Button handlers ───────────────────────────────────────────────────────────

func _on_tap_pressed(btn: Button) -> void:
	GameState.tap()
	_update_tap_count()
	_show_float_label(btn.global_position + Vector2(randf_range(10, 50), randf_range(0, 20)), "+0.1 fl")

func _on_buy_chore(idx: int) -> void:
	GameState.buy_chore(idx)

func _on_chore_prev() -> void:
	_chore_page -= 1
	_update_chores()

func _on_chore_next() -> void:
	_chore_page += 1
	_update_chores()

func _on_chore_milestone(chore_name: String, count: int) -> void:
	var mult_text = "×2" if count == 10 else ("×10" if count == 25 else "×250")
	var msg = "%s — %d hired! Production %s!" % [chore_name, count, mult_text]
	GameState.add_log("🏆 " + msg)
	_show_event_banner("🏆 " + msg, Color("#185FA5"), 3.5)

func _on_open_pack(idx: int) -> void:
	GameState.open_pack(idx)

func _on_buy_upgrade(idx: int) -> void:
	GameState.buy_upgrade(idx)

func _on_sell_dupes(batch_size: int = 50) -> void:
	GameState.sell_dupes(batch_size)

func _on_floridex_pressed() -> void:
	_floridex.refresh()
	_floridex.visible = true

func _on_dex_card_selected(card: Dictionary) -> void:
	var owned_list: Array = []
	for c in CardDatabase.CARDS:
		if GameState.get_card_total_owned(c["name"]) > 0:
			var entry = c.duplicate()
			entry["variation"] = GameState.get_card_best_variant(c["name"])
			owned_list.append(entry)
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

# ── Floating banners ─────────────────────────────────────────────────────────

func _show_event_banner(text: String, bg: Color, duration: float) -> void:
	var vp_w = get_viewport().get_visible_rect().size.x

	var banner = Control.new()
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.position     = Vector2(20, 80)
	banner.size         = Vector2(vp_w - 40, 50)
	_float_layer.add_child(banner)

	var bg_panel = Panel.new()
	var style    = StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(6)
	bg_panel.add_theme_stylebox_override("panel", style)
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.add_child(bg_panel)

	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	lbl.mouse_filter         = Control.MOUSE_FILTER_IGNORE
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.add_child(lbl)

	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(banner, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(banner.queue_free)

func _show_offline_banner(data: Dictionary) -> void:
	var earned  = data.get("amount",  0.0)
	var seconds = data.get("seconds", 0)
	var mins    = int(seconds / 60)
	var hrs     = int(mins / 60)
	var time_str = ("%dh %dm" % [hrs, mins % 60]) if hrs > 0 else ("%dm" % mins)
	var text = "Welcome back! Earned %s fl while away (%s)" % [NumberFormatter.fmt(earned), time_str]
	GameState.add_log(text)
	_show_event_banner(text, Color("#185FA5"), 3.5)

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
	btn.add_theme_color_override("font_color",          Color.WHITE)
	btn.add_theme_color_override("font_hover_color",    Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color("#EEEEEE"))
	return btn

func _add_divider(parent: Control) -> void:
	var sep = HSeparator.new()
	parent.add_child(sep)

func _add_spacer(parent: Control, height: int) -> void:
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, height)
	parent.add_child(sp)
