class_name CardWidgets

# ── Colour helpers ────────────────────────────────────────────────────────────

static func border_color(rarity: String) -> Color:
	return CardDatabase.RARITY_BORDER_COLORS.get(rarity, Color("#AAAAAA"))

static func bg_color(rarity: String) -> Color:
	return CardDatabase.RARITY_BG_COLORS.get(rarity, Color("#F5F5F0"))

static func text_color(rarity: String) -> Color:
	return CardDatabase.RARITY_TEXT_COLORS.get(rarity, Color("#6B6B6B"))

# ── Style helpers ─────────────────────────────────────────────────────────────

static func panel_style(bg: Color, border: Color, radius: int = 8, border_w: int = 2) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.content_margin_left   = 10
	s.content_margin_right  = 10
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	return s

static func flat_style(bg: Color, radius: int = 6) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	return s

# ── BigCard ───────────────────────────────────────────────────────────────────
# Full-width card for viewer / pack reveal detail

static func make_big_card(card: Dictionary, owned_count: int = 0) -> Control:
	var rarity  = card.get("rarity", "common")
	var stats   = card.get("stats",  {})
	var bc      = border_color(rarity)
	var bgc     = bg_color(rarity)
	var tc      = text_color(rarity)
	var rlabel  = CardDatabase.RARITY_LABELS.get(rarity, "Common")

	var root = PanelContainer.new()
	root.add_theme_stylebox_override("panel", panel_style(Color.WHITE, bc, 12, 3))
	root.custom_minimum_size = Vector2(300, 0)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	root.add_child(vbox)

	# — Header row —
	var header = HBoxContainer.new()
	vbox.add_child(header)

	var lbl_rarity = Label.new()
	lbl_rarity.text = rlabel
	lbl_rarity.add_theme_color_override("font_color", tc)
	lbl_rarity.add_theme_font_size_override("font_size", 12)
	lbl_rarity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(lbl_rarity)

	var lbl_hp = Label.new()
	lbl_hp.text = "HP %d" % stats.get("health", 0)
	lbl_hp.add_theme_color_override("font_color", Color("#1A1A1A"))
	lbl_hp.add_theme_font_size_override("font_size", 13)
	header.add_child(lbl_hp)

	# — Art area —
	var art_panel = PanelContainer.new()
	art_panel.custom_minimum_size = Vector2(0, 130)
	art_panel.add_theme_stylebox_override("panel", flat_style(bgc, 8))
	vbox.add_child(art_panel)

	var art_label = Label.new()
	art_label.text = card.get("name", "???")
	art_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_label.add_theme_font_size_override("font_size", 22)
	art_label.add_theme_color_override("font_color", tc)
	art_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_panel.add_child(art_label)

	# — Name + owned —
	var name_row = HBoxContainer.new()
	vbox.add_child(name_row)

	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???")
	lbl_name.add_theme_font_size_override("font_size", 18)
	lbl_name.add_theme_color_override("font_color", Color("#1A1A1A"))
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(lbl_name)

	if owned_count > 0:
		var lbl_owned = Label.new()
		lbl_owned.text = "Owned: %d" % owned_count
		lbl_owned.add_theme_font_size_override("font_size", 12)
		lbl_owned.add_theme_color_override("font_color", Color("#6B6B6B"))
		name_row.add_child(lbl_owned)

	# — Stats —
	var stat_names  = ["health", "attack", "defence", "luck"]
	var stat_labels = ["Health", "Attack", "Defence", "Luck"]
	var stat_colors = [Color("#E74C3C"), Color("#E67E22"), Color("#3498DB"), Color("#2ECC71")]

	var stat_max = 0
	var stat_min = 999
	for sn in stat_names:
		var v = stats.get(sn, 0)
		stat_max = maxi(stat_max, v)
		stat_min = mini(stat_min, v)

	for si in range(stat_names.size()):
		var sname = stat_names[si]
		var val   = stats.get(sname, 0)
		var row   = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vbox.add_child(row)

		var lbl_s = Label.new()
		lbl_s.text = stat_labels[si]
		lbl_s.custom_minimum_size = Vector2(60, 0)
		lbl_s.add_theme_font_size_override("font_size", 12)
		lbl_s.add_theme_color_override("font_color", Color("#6B6B6B"))
		row.add_child(lbl_s)

		var bar = ProgressBar.new()
		bar.min_value       = 0
		bar.max_value       = 100
		bar.value           = val
		bar.show_percentage = false
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.custom_minimum_size = Vector2(0, 14)
		# Colour bar based on stat
		var bar_bg = StyleBoxFlat.new()
		bar_bg.bg_color = Color("#E5E5E0")
		bar_bg.set_corner_radius_all(4)
		bar.add_theme_stylebox_override("background", bar_bg)
		var bar_fill_color = stat_colors[si]
		if val == stat_max and stat_max != stat_min:
			bar_fill_color = Color("#0F6E56")
		elif val == stat_min and stat_max != stat_min:
			bar_fill_color = Color("#A32D2D")
		var bar_fill = StyleBoxFlat.new()
		bar_fill.bg_color = bar_fill_color
		bar_fill.set_corner_radius_all(4)
		bar.add_theme_stylebox_override("fill", bar_fill)
		row.add_child(bar)

		var lbl_v = Label.new()
		lbl_v.text = str(val)
		lbl_v.custom_minimum_size = Vector2(28, 0)
		lbl_v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_v.add_theme_font_size_override("font_size", 12)
		lbl_v.add_theme_color_override("font_color", Color("#1A1A1A"))
		row.add_child(lbl_v)

	# — Move box —
	var move_panel = PanelContainer.new()
	move_panel.add_theme_stylebox_override("panel", flat_style(bgc, 6))
	vbox.add_child(move_panel)

	var move_vbox = VBoxContainer.new()
	move_vbox.add_theme_constant_override("separation", 2)
	move_panel.add_child(move_vbox)

	var lbl_move_name = Label.new()
	lbl_move_name.text = card.get("move_name", "Tackle")
	lbl_move_name.add_theme_font_size_override("font_size", 13)
	lbl_move_name.add_theme_color_override("font_color", tc)
	move_vbox.add_child(lbl_move_name)

	var lbl_move_desc = Label.new()
	lbl_move_desc.text = card.get("move_desc", "A basic attack.")
	lbl_move_desc.add_theme_font_size_override("font_size", 11)
	lbl_move_desc.add_theme_color_override("font_color", Color("#6B6B6B"))
	lbl_move_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	move_vbox.add_child(lbl_move_desc)

	# — Footer —
	var footer = HBoxContainer.new()
	vbox.add_child(footer)

	var lbl_brand = Label.new()
	lbl_brand.text = "Florin Cards"
	lbl_brand.add_theme_font_size_override("font_size", 10)
	lbl_brand.add_theme_color_override("font_color", Color("#A0A0A0"))
	lbl_brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(lbl_brand)

	var lbl_num = Label.new()
	lbl_num.text = "#%03d / %d" % [card.get("number", 1), CardDatabase.total_cards()]
	lbl_num.add_theme_font_size_override("font_size", 10)
	lbl_num.add_theme_color_override("font_color", Color("#A0A0A0"))
	footer.add_child(lbl_num)

	return root

# ── SmallCard ─────────────────────────────────────────────────────────────────
# Compact card thumbnail for pack reveal (100×150)

static func make_small_card(card: Dictionary, is_dupe: bool = false) -> Control:
	var rarity = card.get("rarity", "common")
	var bc     = border_color(rarity)
	var bgc    = bg_color(rarity)
	var tc     = text_color(rarity)

	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(100, 150)
	root.add_theme_stylebox_override("panel", panel_style(Color.WHITE, bc, 8, 3))

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	root.add_child(vbox)

	# Art placeholder
	var art = PanelContainer.new()
	art.custom_minimum_size = Vector2(0, 80)
	art.add_theme_stylebox_override("panel", flat_style(bgc, 6))
	vbox.add_child(art)

	var art_lbl = Label.new()
	art_lbl.text = card.get("name", "???")[0]  # First letter as placeholder
	art_lbl.add_theme_font_size_override("font_size", 36)
	art_lbl.add_theme_color_override("font_color", bc)
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(art_lbl)

	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???")
	lbl_name.add_theme_font_size_override("font_size", 10)
	lbl_name.add_theme_color_override("font_color", Color("#1A1A1A"))
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_name)

	var lbl_rarity = Label.new()
	lbl_rarity.text = CardDatabase.RARITY_LABELS.get(rarity, "Common")
	lbl_rarity.add_theme_font_size_override("font_size", 9)
	lbl_rarity.add_theme_color_override("font_color", tc)
	lbl_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_rarity)

	if is_dupe:
		var lbl_dupe = Label.new()
		lbl_dupe.text = "DUPE"
		lbl_dupe.add_theme_font_size_override("font_size", 9)
		lbl_dupe.add_theme_color_override("font_color", Color("#A32D2D"))
		lbl_dupe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_dupe)

	return root

# ── DexCard ───────────────────────────────────────────────────────────────────
# Small card for Floridex grid

static func make_dex_card(card: Dictionary, owned: int = 0) -> Control:
	var is_owned = owned > 0
	var rarity   = card.get("rarity", "common")
	var bc       = border_color(rarity) if is_owned else Color("#D0D0C8")
	var bgc      = bg_color(rarity)     if is_owned else Color("#F0F0EC")
	var tc       = text_color(rarity)   if is_owned else Color("#A0A0A0")

	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(80, 110)
	root.add_theme_stylebox_override("panel", panel_style(Color.WHITE, bc, 6, 2))

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	root.add_child(vbox)

	var art = PanelContainer.new()
	art.custom_minimum_size = Vector2(0, 60)
	art.add_theme_stylebox_override("panel", flat_style(bgc, 4))
	vbox.add_child(art)

	var art_lbl = Label.new()
	if is_owned:
		art_lbl.text = card.get("name", "?")[0]
		art_lbl.add_theme_font_size_override("font_size", 28)
		art_lbl.add_theme_color_override("font_color", bc)
	else:
		art_lbl.text = "?"
		art_lbl.add_theme_font_size_override("font_size", 28)
		art_lbl.add_theme_color_override("font_color", Color("#AAAAAA"))
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(art_lbl)

	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???") if is_owned else "???"
	lbl_name.add_theme_font_size_override("font_size", 9)
	lbl_name.add_theme_color_override("font_color", tc)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(lbl_name)

	if is_owned and owned > 1:
		var lbl_count = Label.new()
		lbl_count.text = "x%d" % owned
		lbl_count.add_theme_font_size_override("font_size", 9)
		lbl_count.add_theme_color_override("font_color", Color("#6B6B6B"))
		lbl_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_count)

	return root
