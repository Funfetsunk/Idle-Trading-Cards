extends Control

signal card_selected(card: Dictionary)

const COLS = 4
const RARITY_FILTERS = ["all", "common", "uncommon", "rare", "ultra", "secret", "legendary"]

var _filter: String = "all"
var _grid: GridContainer
var _lbl_progress: Label
var _filter_btns: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	var bg = ColorRect.new()
	bg.color = Color("#F5F5F0")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# — Header —
	var header_panel = PanelContainer.new()
	var hstyle = StyleBoxFlat.new()
	hstyle.bg_color = Color("#185FA5")
	hstyle.content_margin_left   = 12
	hstyle.content_margin_right  = 12
	hstyle.content_margin_top    = 10
	hstyle.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", hstyle)
	root.add_child(header_panel)

	var header_hbox = HBoxContainer.new()
	header_panel.add_child(header_hbox)

	var lbl_title = Label.new()
	lbl_title.text = "Floridex"
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color.WHITE)
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(lbl_title)

	_lbl_progress = Label.new()
	_lbl_progress.add_theme_font_size_override("font_size", 14)
	_lbl_progress.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	header_hbox.add_child(_lbl_progress)

	# — Filter bar —
	var filter_scroll = ScrollContainer.new()
	filter_scroll.custom_minimum_size = Vector2(0, 44)
	filter_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var fstyle = StyleBoxFlat.new()
	fstyle.bg_color = Color.WHITE
	fstyle.content_margin_left  = 8
	fstyle.content_margin_right = 8
	fstyle.content_margin_top   = 6
	fstyle.content_margin_bottom = 6
	filter_scroll.add_theme_stylebox_override("panel", fstyle)
	root.add_child(filter_scroll)

	var filter_hbox = HBoxContainer.new()
	filter_hbox.add_theme_constant_override("separation", 6)
	filter_scroll.add_child(filter_hbox)

	for f in RARITY_FILTERS:
		var btn = _make_filter_btn(f)
		btn.pressed.connect(_on_filter.bind(f))
		filter_hbox.add_child(btn)
		_filter_btns[f] = btn
	_highlight_filter("all")

	# — Separator —
	var sep = HSeparator.new()
	root.add_child(sep)

	# — Scrollable card grid —
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var grid_margin = MarginContainer.new()
	grid_margin.add_theme_constant_override("margin_left",   8)
	grid_margin.add_theme_constant_override("margin_right",  8)
	grid_margin.add_theme_constant_override("margin_top",    8)
	grid_margin.add_theme_constant_override("margin_bottom", 8)
	scroll.add_child(grid_margin)

	_grid = GridContainer.new()
	_grid.columns = COLS
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_margin.add_child(_grid)

	# — Back button overlay —
	var btn_back = Button.new()
	btn_back.text = "✕  Close"
	btn_back.pressed.connect(func(): visible = false)
	var bstyle = StyleBoxFlat.new()
	bstyle.bg_color = Color("#A32D2D")
	bstyle.set_corner_radius_all(6)
	bstyle.content_margin_left   = 16
	bstyle.content_margin_right  = 16
	bstyle.content_margin_top    = 8
	bstyle.content_margin_bottom = 8
	btn_back.add_theme_stylebox_override("normal", bstyle)
	btn_back.add_theme_color_override("font_color", Color.WHITE)
	btn_back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	btn_back.offset_left   = -110
	btn_back.offset_top    = -52
	btn_back.offset_right  = -12
	btn_back.offset_bottom = -12
	add_child(btn_back)

	refresh()

func refresh() -> void:
	_update_progress()
	_rebuild_grid()

func _update_progress() -> void:
	var unique = GameState.get_unique_collected()
	var total  = CardDatabase.total_cards()
	_lbl_progress.text = "%d / %d" % [unique, total]

func _rebuild_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()

	var cards_to_show: Array = []
	for card in CardDatabase.CARDS:
		if _filter == "all" or card["rarity"] == _filter:
			cards_to_show.append(card)

	for card in cards_to_show:
		var owned        = GameState.get_card_total_owned(card["name"])
		var best_variant = GameState.get_card_best_variant(card["name"])
		var dex_card     = CardWidgets.make_dex_card(card, owned, best_variant)
		if owned > 0:
			dex_card.gui_input.connect(_on_card_gui_input.bind(card))
			dex_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_grid.add_child(dex_card)

func _on_card_gui_input(event: InputEvent, card: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(card)
	elif event is InputEventScreenTouch and event.pressed:
		card_selected.emit(card)

func _on_filter(f: String) -> void:
	_filter = f
	_highlight_filter(f)
	_rebuild_grid()

func _highlight_filter(active: String) -> void:
	for f in _filter_btns:
		var btn: Button = _filter_btns[f]
		if f == active:
			var s = StyleBoxFlat.new()
			s.bg_color = Color("#185FA5")
			s.set_corner_radius_all(12)
			s.content_margin_left   = 12
			s.content_margin_right  = 12
			s.content_margin_top    = 4
			s.content_margin_bottom = 4
			btn.add_theme_stylebox_override("normal", s)
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			var s = StyleBoxFlat.new()
			s.bg_color = Color("#E5E5E0")
			s.set_corner_radius_all(12)
			s.content_margin_left   = 12
			s.content_margin_right  = 12
			s.content_margin_top    = 4
			s.content_margin_bottom = 4
			btn.add_theme_stylebox_override("normal", s)
			btn.add_theme_color_override("font_color", Color("#1A1A1A"))

func _make_filter_btn(f: String) -> Button:
	var btn = Button.new()
	if f == "all":
		btn.text = "All"
	else:
		btn.text = CardDatabase.RARITY_LABELS.get(f, f.capitalize())
	btn.add_theme_font_size_override("font_size", 12)
	btn.flat = false
	return btn
