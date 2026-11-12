extends Control
## Arsenal: pick chassis, barrel, core and chip, unlock parts with coins and upgrade the chassis.
## Owned parts are equipped and saved at once. Locked parts show a preview and an unlock button.
# ponytail: UI built in code with inline styles, moves to theme.tres with the main menu (M2 step 4).

const BG := Color(0.043, 0.063, 0.125)
const PANEL := Color(0.102, 0.133, 0.22)
const TEXT := Color(0.8, 0.84, 0.9)
const DIM := Color(0.6, 0.65, 0.75)

var _loadout: Dictionary
## Part shown per slot. Differs from _loadout while browsing a locked part.
var _shown: Dictionary
var _names: Dictionary = {}
var _descs: Dictionary = {}
var _unlocks: Dictionary = {}
var _upgrade_labels: Dictionary = {}
var _upgrade_buttons: Dictionary = {}
var _coins_label: Label
var _stats_label: Label
var _traits_label: Label
var _upgrade_title: Label


func _ready() -> void:
	get_tree().quit_on_go_back = false
	_loadout = Arsenal.owned_loadout(Save.data)
	_shown = _loadout.duplicate()
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

	var header := HBoxContainer.new()
	column.add_child(header)
	var title := _label("ARSENAL", 44, RunArt.CYAN)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_coins_label = _label("", 34, RunArt.AMBER)
	header.add_child(_coins_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)

	var stats_panel := _panel()
	content.add_child(stats_panel)
	var stats_box := VBoxContainer.new()
	stats_panel.add_child(stats_box)
	_stats_label = _label("", 26, TEXT)
	stats_box.add_child(_stats_label)
	_traits_label = _label("", 22, RunArt.AMBER)
	_traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_box.add_child(_traits_label)
	content.add_child(_upgrade_panel())
	for slot: String in Parts.SLOTS:
		content.add_child(_slot_row(slot))

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
	var unlock := _button("", true, RunArt.AMBER)
	unlock.custom_minimum_size = Vector2(0.0, 72.0)
	unlock.pressed.connect(_unlock.bind(slot))
	box.add_child(unlock)
	_names[slot] = name_label
	_descs[slot] = desc
	_unlocks[slot] = unlock
	return panel


func _upgrade_panel() -> Control:
	var panel := _panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	_upgrade_title = _label("", 20, DIM)
	box.add_child(_upgrade_title)
	for stat: String in Arsenal.UPGRADE_BASE:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		box.add_child(row)
		var label := _label("", 26, TEXT)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var buy := _button("", true, RunArt.AMBER)
		buy.custom_minimum_size = Vector2(190.0, 72.0)
		buy.size_flags_horizontal = Control.SIZE_FILL
		buy.pressed.connect(_upgrade.bind(stat))
		row.add_child(buy)
		_upgrade_labels[stat] = label
		_upgrade_buttons[stat] = buy
	return panel


func _cycle(slot: String, step: int) -> void:
	var ids: Array = Parts.table(slot).keys()
	_shown[slot] = ids[posmod(ids.find(_shown[slot]) + step, ids.size())]
	if Arsenal.is_owned(Save.data, slot, _shown[slot]):
		_equip(slot)
	_refresh()


func _unlock(slot: String) -> void:
	if Arsenal.buy_part(Save.data, slot, _shown[slot]):
		_equip(slot)
		_refresh()


func _upgrade(stat: String) -> void:
	if Arsenal.buy_upgrade(Save.data, _loadout["chassis"], stat):
		Save.save()
		_refresh()


func _equip(slot: String) -> void:
	_loadout[slot] = _shown[slot]
	Save.data["loadout"] = _loadout.duplicate()
	Save.save()


func _refresh() -> void:
	var coins := int(Save.data["coins"])
	_coins_label.text = "◆ %d" % coins
	for slot: String in Parts.SLOTS:
		var id: String = _shown[slot]
		var part: Dictionary = Parts.table(slot)[id]
		var owned := Arsenal.is_owned(Save.data, slot, id)
		var name_label: Label = _names[slot]
		name_label.text = part["name"]
		name_label.add_theme_color_override("font_color", RunArt.CYAN if owned else DIM)
		(_descs[slot] as Label).text = part["desc"]
		var unlock: Button = _unlocks[slot]
		unlock.visible = not owned
		unlock.text = "Freischalten · %d ◆" % Arsenal.part_price(slot, id)
		unlock.disabled = coins < Arsenal.part_price(slot, id)

	var preview := _shown != _loadout
	var stats := Arsenal.stats_for(Save.data, _shown)
	_stats_label.text = "%sSchaden %s · Feuerrate %s/s\nProjektile %d%s · Reichweite %d m\nSchaden pro Sekunde ≈ %s" % [
		"VORSCHAU\n" if preview else "",
		WeaponStats.format_number(stats.damage), WeaponStats.format_number(stats.fire_rate),
		stats.projectiles, " ×%d Salve" % stats.burst if stats.burst > 1 else "", roundi(stats.range_m),
		WeaponStats.format_number(roundf(stats.dps()))]
	_traits_label.text = " · ".join(stats.traits())
	_traits_label.visible = _traits_label.text != ""

	var chassis: String = _loadout["chassis"]
	_upgrade_title.text = "VERBESSERUNGEN · %s" % Parts.CHASSIS[chassis]["name"].to_upper()
	for stat: String in Arsenal.UPGRADE_BASE:
		var level := Arsenal.upgrade_level(Save.data, chassis, stat)
		(_upgrade_labels[stat] as Label).text = "%s · Stufe %d/%d\n+%d %%" % [
			Arsenal.UPGRADE_NAMES[stat], level, Arsenal.MAX_LEVEL, roundi((pow(Arsenal.UPGRADE_GAIN, level) - 1.0) * 100.0)]
		var buy: Button = _upgrade_buttons[stat]
		if level >= Arsenal.MAX_LEVEL:
			buy.text = "MAX"
			buy.disabled = true
		else:
			var cost := Arsenal.upgrade_cost(stat, level)
			buy.text = "%d ◆" % cost
			buy.disabled = coins < cost


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


func _button(text: String, primary: bool, color: Color = RunArt.CYAN) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 84.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 30)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12.0)
	if primary:
		style.bg_color = color
		for state: String in ["font_color", "font_pressed_color", "font_hover_color", "font_focus_color"]:
			button.add_theme_color_override(state, BG)
		button.add_theme_color_override("font_disabled_color", Color(BG, 0.6))
	else:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		style.border_color = DIM
		style.set_border_width_all(2)
		button.add_theme_color_override("font_color", TEXT)
	var disabled := style.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(style.bg_color, style.bg_color.a * 0.35)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	button.add_theme_stylebox_override("disabled", disabled)
	return button
