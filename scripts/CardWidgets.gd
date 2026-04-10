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
	var rarity    = card.get("rarity", "common")
	var type      = card.get("type", CardDatabase.TYPE_EARTH)
	var stats     = card.get("stats",  {})
	var tc        = CardDatabase.TYPE_LABEL_COLORS.get(type, Color("#6B6B6B"))
	var rlabel    = CardDatabase.RARITY_LABELS.get(rarity, "Common")
	var variation = card.get("variation", "normal")
	var type_bg   = CardDatabase.TYPE_COLORS.get(type, Color("#7D5A3C"))
	var type_art  = CardDatabase.TYPE_ART_BG_COLORS.get(type, Color("#C4A882"))
	var foot_tc   = CardDatabase.TYPE_FOOTER_TEXT_COLORS.get(type, Color.WHITE)

	# Second move — deterministic placeholder from offset index
	var m2_idx  = (card.get("index", 0) + 38) % CardDatabase.MOVE_NAMES.size()
	var m2_name = CardDatabase.MOVE_NAMES[m2_idx]
	var m2_desc = CardDatabase.MOVE_DESCS[m2_idx]

	# ── Full Art variant: art fills card, all content overlays ───────────
	if variation == "full_art":
		return _make_big_card_full_art(card, tc, type_bg, type_art, foot_tc, rlabel, m2_name, m2_desc, stats)

	# ── Root: rarity colour background, silver border ─────────────────
	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(300, 0)
	var root_style = StyleBoxFlat.new()
	root_style.bg_color      = type_bg
	root_style.border_color  = Color("#B0B0B0")
	root_style.set_border_width_all(2)
	root_style.set_corner_radius_all(12)
	root_style.content_margin_left   = 8
	root_style.content_margin_right  = 8
	root_style.content_margin_top    = 8
	root_style.content_margin_bottom = 8
	root.add_theme_stylebox_override("panel", root_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	root.add_child(vbox)

	# ── Section 1: Name header + Art with HP overlay ──────────────────
	var s1 = PanelContainer.new()
	var s1_style = StyleBoxFlat.new()
	s1_style.bg_color = Color.WHITE
	s1_style.set_corner_radius_all(8)
	s1_style.content_margin_left   = 8
	s1_style.content_margin_right  = 8
	s1_style.content_margin_top    = 6
	s1_style.content_margin_bottom = 6
	s1.add_theme_stylebox_override("panel", s1_style)
	vbox.add_child(s1)

	var s1_vbox = VBoxContainer.new()
	s1_vbox.add_theme_constant_override("separation", 4)
	s1.add_child(s1_vbox)

	# Header row: card name left, type placeholder right
	var name_row = HBoxContainer.new()
	s1_vbox.add_child(name_row)

	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???")
	lbl_name.add_theme_font_size_override("font_size", 16)
	lbl_name.add_theme_color_override("font_color", Color("#1A1A1A"))
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(lbl_name)

	var lbl_type = Label.new()
	lbl_type.text = CardDatabase.TYPE_LABELS.get(type, "—")
	lbl_type.add_theme_font_size_override("font_size", 12)
	lbl_type.add_theme_color_override("font_color", tc)
	name_row.add_child(lbl_type)

	# Art panel with HP overlaid at bottom-left
	var art_panel = PanelContainer.new()
	art_panel.custom_minimum_size = Vector2(0, 150)
	var art_style = StyleBoxFlat.new()
	art_style.bg_color = type_art
	art_style.set_corner_radius_all(6)
	art_style.content_margin_left   = 0
	art_style.content_margin_right  = 0
	art_style.content_margin_top    = 0
	art_style.content_margin_bottom = 0
	art_panel.add_theme_stylebox_override("panel", art_style)
	s1_vbox.add_child(art_panel)

	var art_overlay = Control.new()
	art_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_panel.add_child(art_overlay)

	var art_lbl = Label.new()
	art_lbl.text = card.get("name", "?")[0]
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.add_theme_font_size_override("font_size", 48)
	art_lbl.add_theme_color_override("font_color", tc)
	art_overlay.add_child(art_lbl)

	var hp_lbl = Label.new()
	hp_lbl.text = "HP %d" % stats.get("health", 0)
	hp_lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hp_lbl.offset_left   = 6
	hp_lbl.offset_top    = -26
	hp_lbl.offset_right  = 72
	hp_lbl.offset_bottom = -4
	hp_lbl.add_theme_font_size_override("font_size", 13)
	hp_lbl.add_theme_color_override("font_color", Color("#1A1A1A"))
	art_overlay.add_child(hp_lbl)

	# ── Section 2: Stats (2-col) + 2 Moves ───────────────────────────
	var s2 = PanelContainer.new()
	var s2_style = StyleBoxFlat.new()
	s2_style.bg_color = Color.WHITE
	s2_style.set_corner_radius_all(8)
	s2_style.content_margin_left   = 8
	s2_style.content_margin_right  = 8
	s2_style.content_margin_top    = 6
	s2_style.content_margin_bottom = 6
	s2.add_theme_stylebox_override("panel", s2_style)
	vbox.add_child(s2)

	var s2_vbox = VBoxContainer.new()
	s2_vbox.add_theme_constant_override("separation", 5)
	s2.add_child(s2_vbox)

	# Stats grid: 2 columns (Health|Attack, Defence|Luck)
	var stat_names  = ["health", "attack", "defence", "luck"]
	var stat_labels = ["Health", "Attack", "Defence", "Luck"]
	var stat_icons  = ["❤", "⚔", "🛡", "✦"]
	var stat_colors = [Color("#E74C3C"), Color("#E67E22"), Color("#3498DB"), Color("#2ECC71")]

	var stat_max = 0
	var stat_min = 999
	for sn in stat_names:
		var v = stats.get(sn, 0)
		stat_max = maxi(stat_max, v)
		stat_min = mini(stat_min, v)

	var stat_grid = GridContainer.new()
	stat_grid.columns = 2
	stat_grid.add_theme_constant_override("h_separation", 10)
	stat_grid.add_theme_constant_override("v_separation", 4)
	s2_vbox.add_child(stat_grid)

	for si in range(stat_names.size()):
		var val  = stats.get(stat_names[si], 0)
		var cell = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 3)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_grid.add_child(cell)

		var lbl_icon = Label.new()
		lbl_icon.text = stat_icons[si]
		lbl_icon.add_theme_font_size_override("font_size", 11)
		cell.add_child(lbl_icon)

		var lbl_sname = Label.new()
		lbl_sname.text = stat_labels[si]
		lbl_sname.add_theme_font_size_override("font_size", 11)
		lbl_sname.add_theme_color_override("font_color", Color("#6B6B6B"))
		lbl_sname.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_child(lbl_sname)

		var val_color = stat_colors[si]
		if val == stat_max and stat_max != stat_min:
			val_color = Color("#0F6E56")
		elif val == stat_min and stat_max != stat_min:
			val_color = Color("#A32D2D")

		var lbl_val = Label.new()
		lbl_val.text = str(val)
		lbl_val.add_theme_font_size_override("font_size", 12)
		lbl_val.add_theme_color_override("font_color", val_color)
		cell.add_child(lbl_val)

	var sep = HSeparator.new()
	s2_vbox.add_child(sep)

	_add_move_row(s2_vbox, card.get("move_name", "Tackle"), card.get("move_desc", "A basic attack."), tc)
	_add_move_row(s2_vbox, m2_name, m2_desc, tc)

	# Spacer pushes footer to the bottom of the card
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# ── Footer: sits directly on the card background colour ──────────
	var footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 4)
	vbox.add_child(footer)

	# Left: set name + rarity (+ variation badge)
	var footer_left = VBoxContainer.new()
	footer_left.add_theme_constant_override("separation", 0)
	footer.add_child(footer_left)

	var lbl_set = Label.new()
	lbl_set.text = "Base Set"
	lbl_set.add_theme_font_size_override("font_size", 8)
	lbl_set.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
	footer_left.add_child(lbl_set)

	var var_badge = ""
	match variation:
		"shiny":    var_badge = " ✨"
		"full_art": var_badge = " 🎨"

	var lbl_rarity = Label.new()
	lbl_rarity.text = rlabel + var_badge
	lbl_rarity.add_theme_font_size_override("font_size", 9)
	lbl_rarity.add_theme_color_override("font_color", foot_tc)
	footer_left.add_child(lbl_rarity)

	# Centre: designer + illustrator
	var footer_centre = VBoxContainer.new()
	footer_centre.add_theme_constant_override("separation", 0)
	footer_centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_centre)

	var lbl_designer = Label.new()
	lbl_designer.text = "Design: —"
	lbl_designer.add_theme_font_size_override("font_size", 8)
	lbl_designer.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
	lbl_designer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_centre.add_child(lbl_designer)

	var lbl_illustrator = Label.new()
	lbl_illustrator.text = "Art: —"
	lbl_illustrator.add_theme_font_size_override("font_size", 8)
	lbl_illustrator.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
	lbl_illustrator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_centre.add_child(lbl_illustrator)

	# Right: card number
	var lbl_num = Label.new()
	lbl_num.text = "#%03d / %d" % [card.get("number", 1), CardDatabase.total_cards()]
	lbl_num.add_theme_font_size_override("font_size", 9)
	lbl_num.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
	lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.add_child(lbl_num)

	return root

static func _add_move_row(parent: Control, move_name: String, move_desc: String, color: Color) -> void:
	var move_vbox = VBoxContainer.new()
	move_vbox.add_theme_constant_override("separation", 1)
	parent.add_child(move_vbox)

	var lbl_move_name = Label.new()
	lbl_move_name.text = "⚡ " + move_name
	lbl_move_name.add_theme_font_size_override("font_size", 12)
	lbl_move_name.add_theme_color_override("font_color", color)
	move_vbox.add_child(lbl_move_name)

	var lbl_move_desc = Label.new()
	lbl_move_desc.text = move_desc
	lbl_move_desc.add_theme_font_size_override("font_size", 10)
	lbl_move_desc.add_theme_color_override("font_color", Color("#6B6B6B"))
	lbl_move_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	move_vbox.add_child(lbl_move_desc)

# ── SmallCard ─────────────────────────────────────────────────────────────────
# Compact card thumbnail for pack reveal (100×150)

static func make_small_card(card: Dictionary, is_dupe: bool = false) -> Control:
	var rarity  = card.get("rarity", "common")
	var type    = card.get("type", CardDatabase.TYPE_EARTH)
	var bc      = CardDatabase.TYPE_COLORS.get(type, Color("#7D5A3C"))
	var bgc     = CardDatabase.TYPE_ART_BG_COLORS.get(type, Color("#C4A882"))
	var tc      = CardDatabase.TYPE_LABEL_COLORS.get(type, Color("#6B6B6B"))
	var foot_tc = CardDatabase.TYPE_FOOTER_TEXT_COLORS.get(type, Color.WHITE)

	# Root: type colour background, silver border — matches big card pattern
	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(100, 150)
	var root_style = StyleBoxFlat.new()
	root_style.bg_color     = bc
	root_style.border_color = Color("#B0B0B0")
	root_style.set_border_width_all(2)
	root_style.set_corner_radius_all(8)
	root_style.content_margin_left   = 6
	root_style.content_margin_right  = 6
	root_style.content_margin_top    = 6
	root_style.content_margin_bottom = 6
	root.add_theme_stylebox_override("panel", root_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	root.add_child(vbox)

	# Art panel — lighter type shade, sits inside coloured card bg
	var art = PanelContainer.new()
	art.custom_minimum_size = Vector2(0, 80)
	art.add_theme_stylebox_override("panel", flat_style(bgc, 6))
	vbox.add_child(art)

	var art_lbl = Label.new()
	art_lbl.text = card.get("name", "???")[0]
	art_lbl.add_theme_font_size_override("font_size", 36)
	art_lbl.add_theme_color_override("font_color", tc)
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(art_lbl)

	# Labels sit on the type-coloured background — use foot_tc for contrast
	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???")
	lbl_name.add_theme_font_size_override("font_size", 10)
	lbl_name.add_theme_color_override("font_color", foot_tc)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl_name)

	var lbl_rarity = Label.new()
	lbl_rarity.text = CardDatabase.RARITY_LABELS.get(rarity, "Common")
	lbl_rarity.add_theme_font_size_override("font_size", 9)
	lbl_rarity.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
	lbl_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_rarity)

	if is_dupe:
		var lbl_dupe = Label.new()
		lbl_dupe.text = "DUPE"
		lbl_dupe.add_theme_font_size_override("font_size", 9)
		lbl_dupe.add_theme_color_override("font_color", foot_tc)
		lbl_dupe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_dupe)

	var variation = card.get("variation", "normal")
	if variation != "normal":
		var lbl_var = Label.new()
		lbl_var.text = "✨ SHINY" if variation == "shiny" else "🎨 FULL ART"
		lbl_var.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.85))
		lbl_var.add_theme_font_size_override("font_size", 8)
		lbl_var.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_var)

	return root

# ── DexCard ───────────────────────────────────────────────────────────────────
# Small card for Floridex grid

static func make_dex_card(card: Dictionary, owned: int = 0, best_variant: String = "") -> Control:
	var is_owned = owned > 0
	var type     = card.get("type", CardDatabase.TYPE_EARTH)
	var bc       = CardDatabase.TYPE_COLORS.get(type, Color("#7D5A3C"))     if is_owned else Color("#D0D0C8")
	var bgc      = CardDatabase.TYPE_ART_BG_COLORS.get(type, Color("#C4A882")) if is_owned else Color("#F0F0EC")
	var tc       = CardDatabase.TYPE_LABEL_COLORS.get(type, Color("#6B6B6B")) if is_owned else Color("#A0A0A0")

	var foot_tc  = CardDatabase.TYPE_FOOTER_TEXT_COLORS.get(type, Color.WHITE) if is_owned else Color("#A0A0A0")

	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(80, 110)
	var dex_style = StyleBoxFlat.new()
	dex_style.bg_color     = bc if is_owned else Color.WHITE
	dex_style.border_color = Color("#B0B0B0") if is_owned else Color("#D0D0C8")
	dex_style.set_border_width_all(2)
	dex_style.set_corner_radius_all(6)
	dex_style.content_margin_left   = 5
	dex_style.content_margin_right  = 5
	dex_style.content_margin_top    = 5
	dex_style.content_margin_bottom = 5
	root.add_theme_stylebox_override("panel", dex_style)

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
		art_lbl.add_theme_color_override("font_color", tc)
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
	lbl_name.add_theme_color_override("font_color", foot_tc)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(lbl_name)

	if is_owned and owned > 1:
		var lbl_count = Label.new()
		lbl_count.text = "x%d" % owned
		lbl_count.add_theme_font_size_override("font_size", 9)
		lbl_count.add_theme_color_override("font_color", Color(foot_tc.r, foot_tc.g, foot_tc.b, 0.7))
		lbl_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_count)

	if is_owned and best_variant != "normal" and best_variant != "":
		var lbl_var = Label.new()
		lbl_var.text = "✨" if best_variant == "shiny" else "🎨"
		lbl_var.add_theme_font_size_override("font_size", 10)
		lbl_var.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl_var)

	return root

# ── Full Art BigCard ──────────────────────────────────────────────────────────
# Art fills the entire card interior; all content overlays without section panels.
# Per-card text colour: set card["full_art_text_color"] = Color(...) when adding
# custom art so text remains readable against that specific artwork.

static func _make_big_card_full_art(card: Dictionary, tc: Color, type_bg: Color, type_art: Color, foot_tc: Color, rlabel: String, m2_name: String, m2_desc: String, stats: Dictionary) -> Control:
	var type      = card.get("type", CardDatabase.TYPE_EARTH)
	var variation = card.get("variation", "full_art")

	# Per-card text colour override — default white works on most dark art.
	# Set card["full_art_text_color"] per card once custom artwork is added.
	var fat_tc  : Color = card.get("full_art_text_color", Color.WHITE)
	var fat_tc2 : Color = Color(fat_tc.r, fat_tc.g, fat_tc.b, 0.75)

	var var_badge = " 🎨" if variation == "full_art" else (" ✨" if variation == "shiny" else "")

	# Root: thin margins so art is nearly edge-to-edge behind the border
	var root = PanelContainer.new()
	root.custom_minimum_size = Vector2(300, 0)
	var root_style = StyleBoxFlat.new()
	root_style.bg_color     = type_bg
	root_style.border_color = Color("#B0B0B0")
	root_style.set_border_width_all(2)
	root_style.set_corner_radius_all(12)
	root_style.content_margin_left   = 4
	root_style.content_margin_right  = 4
	root_style.content_margin_top    = 4
	root_style.content_margin_bottom = 4
	root.add_theme_stylebox_override("panel", root_style)

	# Art panel fills entire inner area
	var art_panel = PanelContainer.new()
	art_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var art_style = StyleBoxFlat.new()
	art_style.bg_color = type_art
	art_style.set_corner_radius_all(8)
	art_style.content_margin_left   = 0
	art_style.content_margin_right  = 0
	art_style.content_margin_top    = 0
	art_style.content_margin_bottom = 0
	art_panel.add_theme_stylebox_override("panel", art_style)
	root.add_child(art_panel)

	# Overlay: fills art panel
	var overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_panel.add_child(overlay)

	# Placeholder art letter — large, very faint, centred
	var art_lbl = Label.new()
	art_lbl.text = card.get("name", "?")[0]
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.add_theme_font_size_override("font_size", 120)
	art_lbl.add_theme_color_override("font_color", Color(tc.r, tc.g, tc.b, 0.25))
	overlay.add_child(art_lbl)

	# Content VBox inset from the overlay edges
	var content = VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left   = 10
	content.offset_right  = -10
	content.offset_top    = 10
	content.offset_bottom = -10
	content.add_theme_constant_override("separation", 5)
	overlay.add_child(content)

	# ── Header: name (left) | HP + type (right) ──────────────────────────
	var header = HBoxContainer.new()
	content.add_child(header)

	var lbl_name = Label.new()
	lbl_name.text = card.get("name", "???")
	lbl_name.add_theme_font_size_override("font_size", 16)
	lbl_name.add_theme_color_override("font_color", fat_tc)
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(lbl_name)

	var header_right = VBoxContainer.new()
	header_right.add_theme_constant_override("separation", 0)
	header.add_child(header_right)

	var lbl_hp = Label.new()
	lbl_hp.text = "HP %d" % stats.get("health", 0)
	lbl_hp.add_theme_font_size_override("font_size", 13)
	lbl_hp.add_theme_color_override("font_color", fat_tc)
	lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header_right.add_child(lbl_hp)

	var lbl_type_lbl = Label.new()
	lbl_type_lbl.text = CardDatabase.TYPE_LABELS.get(type, "—")
	lbl_type_lbl.add_theme_font_size_override("font_size", 10)
	lbl_type_lbl.add_theme_color_override("font_color", fat_tc2)
	lbl_type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header_right.add_child(lbl_type_lbl)

	# ── Spacer: art shows through the middle ──────────────────────────────
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	# ── Stats grid (2-col, no background) ────────────────────────────────
	var stat_names  = ["health", "attack", "defence", "luck"]
	var stat_labels = ["Health", "Attack", "Defence", "Luck"]
	var stat_icons  = ["❤", "⚔", "🛡", "✦"]
	var stat_colors = [Color("#E74C3C"), Color("#E67E22"), Color("#3498DB"), Color("#2ECC71")]

	var stat_max = 0
	var stat_min = 999
	for sn in stat_names:
		var v = stats.get(sn, 0)
		stat_max = maxi(stat_max, v)
		stat_min = mini(stat_min, v)

	var stat_grid = GridContainer.new()
	stat_grid.columns = 2
	stat_grid.add_theme_constant_override("h_separation", 10)
	stat_grid.add_theme_constant_override("v_separation", 3)
	content.add_child(stat_grid)

	for si in range(stat_names.size()):
		var val  = stats.get(stat_names[si], 0)
		var cell = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 3)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_grid.add_child(cell)

		var lbl_icon = Label.new()
		lbl_icon.text = stat_icons[si]
		lbl_icon.add_theme_font_size_override("font_size", 11)
		cell.add_child(lbl_icon)

		var lbl_sname = Label.new()
		lbl_sname.text = stat_labels[si]
		lbl_sname.add_theme_font_size_override("font_size", 11)
		lbl_sname.add_theme_color_override("font_color", fat_tc2)
		lbl_sname.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_child(lbl_sname)

		var val_color = stat_colors[si]
		if val == stat_max and stat_max != stat_min:
			val_color = Color("#0F6E56")
		elif val == stat_min and stat_max != stat_min:
			val_color = Color("#A32D2D")

		var lbl_val = Label.new()
		lbl_val.text = str(val)
		lbl_val.add_theme_font_size_override("font_size", 12)
		lbl_val.add_theme_color_override("font_color", val_color)
		cell.add_child(lbl_val)

	var sep = HSeparator.new()
	content.add_child(sep)

	# ── Moves (no background) ─────────────────────────────────────────────
	_add_move_row_fat(content, card.get("move_name", "Tackle"), card.get("move_desc", "A basic attack."), fat_tc, fat_tc2)
	_add_move_row_fat(content, m2_name, m2_desc, fat_tc, fat_tc2)

	# ── Footer ────────────────────────────────────────────────────────────
	var footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 4)
	content.add_child(footer)

	var footer_left = VBoxContainer.new()
	footer_left.add_theme_constant_override("separation", 0)
	footer.add_child(footer_left)

	var lbl_set = Label.new()
	lbl_set.text = "Base Set"
	lbl_set.add_theme_font_size_override("font_size", 8)
	lbl_set.add_theme_color_override("font_color", fat_tc2)
	footer_left.add_child(lbl_set)

	var lbl_rarity = Label.new()
	lbl_rarity.text = rlabel + var_badge
	lbl_rarity.add_theme_font_size_override("font_size", 9)
	lbl_rarity.add_theme_color_override("font_color", fat_tc)
	footer_left.add_child(lbl_rarity)

	var footer_centre = VBoxContainer.new()
	footer_centre.add_theme_constant_override("separation", 0)
	footer_centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_centre)

	var lbl_designer = Label.new()
	lbl_designer.text = "Design: —"
	lbl_designer.add_theme_font_size_override("font_size", 8)
	lbl_designer.add_theme_color_override("font_color", fat_tc2)
	lbl_designer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_centre.add_child(lbl_designer)

	var lbl_illustrator = Label.new()
	lbl_illustrator.text = "Art: —"
	lbl_illustrator.add_theme_font_size_override("font_size", 8)
	lbl_illustrator.add_theme_color_override("font_color", fat_tc2)
	lbl_illustrator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_centre.add_child(lbl_illustrator)

	var lbl_num = Label.new()
	lbl_num.text = "#%03d / %d" % [card.get("number", 1), CardDatabase.total_cards()]
	lbl_num.add_theme_font_size_override("font_size", 9)
	lbl_num.add_theme_color_override("font_color", fat_tc2)
	lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.add_child(lbl_num)

	return root

static func _add_move_row_fat(parent: Control, move_name: String, move_desc: String, primary: Color, secondary: Color) -> void:
	var move_vbox = VBoxContainer.new()
	move_vbox.add_theme_constant_override("separation", 1)
	parent.add_child(move_vbox)

	var lbl_move_name = Label.new()
	lbl_move_name.text = "⚡ " + move_name
	lbl_move_name.add_theme_font_size_override("font_size", 12)
	lbl_move_name.add_theme_color_override("font_color", primary)
	move_vbox.add_child(lbl_move_name)

	var lbl_move_desc = Label.new()
	lbl_move_desc.text = move_desc
	lbl_move_desc.add_theme_font_size_override("font_size", 10)
	lbl_move_desc.add_theme_color_override("font_color", secondary)
	lbl_move_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	move_vbox.add_child(lbl_move_desc)
