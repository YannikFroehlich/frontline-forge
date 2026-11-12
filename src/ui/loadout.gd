extends Control
## Weapon screen: pick chassis, barrel, core and chip. The choice is saved at once.
## All parts are available for now. Unlocking with coins and upgrades follow with the arsenal (M2 step 3).
# ponytail: UI built in code with inline styles, moves to theme.tres with the main menu (M2 step 4).

const BG := Color(0.043, 0.063, 0.125)
const PANEL := Color(0.102, 0.133, 0.22)
const TEXT := Color(0.8, 0.84, 0.9)
const DIM := Color(0.6, 0.65, 0.75)

var _loadout: Dictionary
var _names: Dictionary = {}
var _descs: Dictionary = {}
var _stats_label: Label
var _traits_label: Label


func _ready() -> void:
	get_tree().quit_on_go_back = false
	_loadout = Parts.sanitize(Save.data.get("loadout", {}))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	margin.add_theme_constant_override("margin_top", 64)
	margin.add_theme_constant_override("margin_bottom", 48)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	column.add_child(_label("WAFFE", 44, RunArt.CYAN))
	var stats_panel := _panel()
	column.add_child(stats_panel)
	var stats_box := VBoxContainer.new()
	stats_panel.add_child(stats_box)
	_stats_label = _label("", 26, TEXT)
	stats_box.add_child(_stats_label)
	_traits_label = _label("", 22, RunArt.AMBER)
	_traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_box.add_child(_traits_label)

	for slot: String in Parts.SLOTS:
		column.add_child(_slot_row(slot))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	column.add_child(buttons)
	var back := _button("Zurück", false)
	back.pressed.connect(_go_back)
	buttons.add_child(back)
	var play := _button("Spielen", true)
	play.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/run.tscn"))
	buttons.add_child(play)
	_refresh()


func _exit_tree() -> void:
	get_tree().quit_on_go_back = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_back()


func _slot_row(slot: String) -> Control:
	var panel := _panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_label(Parts.SLOT_NAMES[slot].to_upper(), 20, DIM))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var prev := _button("◀", false)
	prev.custom_minimum_size = Vector2(88.0, 72.0)
	prev.size_flags_horizontal = Control.SIZE_FILL
	prev.pressed.connect(_cycle.bind(slot, -1))
	row.add_child(prev)
	var name_label := _label("", 30, RunArt.CYAN)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(name_label)
	var next := _button("▶", false)
	next.custom_minimum_size = Vector2(88.0, 72.0)
	next.size_flags_horizontal = Control.SIZE_FILL
	next.pressed.connect(_cycle.bind(slot, 1))
	row.add_child(next)
	var desc := _label("", 20, TEXT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(desc)
	_names[slot] = name_label
	_descs[slot] = desc
	return panel


func _cycle(slot: String, step: int) -> void:
	var ids: Array = Parts.table(slot).keys()
	var index := ids.find(_loadout[slot])
	_loadout[slot] = ids[posmod(index + step, ids.size())]
	Save.data["loadout"] = _loadout.duplicate()
	Save.save()
	_refresh()


func _refresh() -> void:
	for slot: String in Parts.SLOTS:
		var part: Dictionary = Parts.table(slot)[_loadout[slot]]
		(_names[slot] as Label).text = part["name"]
		(_descs[slot] as Label).text = part["desc"]
	var stats := WeaponStats.from_loadout(_loadout)
	_stats_label.text = "Schaden %s · Feuerrate %s/s\nProjektile %d%s · Reichweite %d m\nSchaden pro Sekunde ≈ %s" % [
		WeaponStats.format_number(snappedf(stats.damage, 0.1)), WeaponStats.format_number(snappedf(stats.fire_rate, 0.1)),
		stats.projectiles, " ×%d Salve" % stats.burst if stats.burst > 1 else "", roundi(stats.range_m),
		WeaponStats.format_number(roundf(stats.dps()))]
	_traits_label.text = " · ".join(stats.traits())
	_traits_label.visible = _traits_label.text != ""


func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/boot.tscn")


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.set_corner_radius_all(10)
	style.set_content_margin_all(16.0)
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 84.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 30)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12.0)
	if primary:
		style.bg_color = RunArt.CYAN
		for state: String in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]:
			button.add_theme_color_override(state, BG)
	else:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		style.border_color = DIM
		style.set_border_width_all(2)
		button.add_theme_color_override("font_color", TEXT)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	return button
