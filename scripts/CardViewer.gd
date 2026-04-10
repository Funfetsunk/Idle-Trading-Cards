extends Control

var _owned_cards: Array = []
var _current_idx: int   = 0

var _big_card_slot: Control
var _lbl_nav: Label
var _btn_prev: Button
var _btn_next: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dark overlay background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Centre panel via CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 0)
	var style = StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_corner_radius_all(12)
	style.content_margin_left   = 16
	style.content_margin_right  = 16
	style.content_margin_top    = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Slot for BigCard content
	_big_card_slot = Control.new()
	_big_card_slot.custom_minimum_size = Vector2(290, 400)
	vbox.add_child(_big_card_slot)

	# Navigation row
	var nav_row = HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 8)
	vbox.add_child(nav_row)

	_btn_prev = _make_nav_btn("◀ Prev")
	_btn_prev.pressed.connect(_on_prev)
	nav_row.add_child(_btn_prev)

	_lbl_nav = Label.new()
	_lbl_nav.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_nav.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_nav.add_theme_font_size_override("font_size", 12)
	_lbl_nav.add_theme_color_override("font_color", Color("#6B6B6B"))
	nav_row.add_child(_lbl_nav)

	_btn_next = _make_nav_btn("Next ▶")
	_btn_next.pressed.connect(_on_next)
	nav_row.add_child(_btn_next)

	# Back button
	var btn_back = Button.new()
	btn_back.text = "Close"
	btn_back.pressed.connect(func(): visible = false)
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#E5E5E0")
	back_style.set_corner_radius_all(6)
	back_style.content_margin_left   = 20
	back_style.content_margin_right  = 20
	back_style.content_margin_top    = 8
	back_style.content_margin_bottom = 8
	btn_back.add_theme_stylebox_override("normal", back_style)
	btn_back.add_theme_color_override("font_color", Color("#1A1A1A"))
	vbox.add_child(btn_back)

func open_card(card: Dictionary, owned_cards: Array) -> void:
	_owned_cards = owned_cards
	var idx = 0
	for i in range(owned_cards.size()):
		if owned_cards[i]["name"] == card["name"]:
			idx = i
			break
	_current_idx = idx
	_refresh()
	visible = true

func _refresh() -> void:
	for child in _big_card_slot.get_children():
		child.queue_free()

	if _owned_cards.is_empty():
		return

	var card = _owned_cards[_current_idx]
	var owned_count = GameState.get_card_total_owned(card["name"])
	var big = CardWidgets.make_big_card(card, owned_count)
	big.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_big_card_slot.add_child(big)

	_lbl_nav.text = "%d / %d" % [_current_idx + 1, _owned_cards.size()]
	_btn_prev.disabled = _owned_cards.size() <= 1
	_btn_next.disabled = _owned_cards.size() <= 1

func _on_prev() -> void:
	if _owned_cards.is_empty():
		return
	_current_idx = (_current_idx - 1 + _owned_cards.size()) % _owned_cards.size()
	_refresh()

func _on_next() -> void:
	if _owned_cards.is_empty():
		return
	_current_idx = (_current_idx + 1) % _owned_cards.size()
	_refresh()

func _make_nav_btn(label: String) -> Button:
	var btn = Button.new()
	btn.text = label
	var s = StyleBoxFlat.new()
	s.bg_color = Color("#185FA5")
	s.set_corner_radius_all(6)
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 6
	s.content_margin_bottom = 6
	btn.add_theme_stylebox_override("normal", s)
	var sd = s.duplicate()
	sd.bg_color = Color("#AAAAAA")
	btn.add_theme_stylebox_override("disabled", sd)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color("#DDDDDD"))
	btn.add_theme_font_size_override("font_size", 12)
	return btn
