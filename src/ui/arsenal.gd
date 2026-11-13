class_name ArsenalPage
extends VBoxContainer
## Arsenal page of the main menu: pick chassis, barrel, core and chip, unlock parts with coins
## and upgrade the equipped chassis. Owned parts are equipped and saved at once.
## Locked parts show a preview of the weapon and an unlock button.

var _loadout: Dictionary
## Part shown per slot. Differs from _loadout while browsing a locked part.
var _shown: Dictionary
var _names: Dictionary = {}
var _descs: Dictionary = {}
var _unlocks: Dictionary = {}
var _upgrade_labels: Dictionary = {}
var _upgrade_buttons: Dictionary = {}
var _stats_label: Label
var _traits_label: Label
var _upgrade_title: Label
var _preview: WeaponPreview


func _ready() -> void:
	_loadout = Arsenal.owned_loadout(Save.data)
	_shown = _loadout.duplicate()
	add_theme_constant_override("separation", 18)
	add_child(_label("ARSENAL", "TitleLabel"))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)

	var stats_panel := PanelContainer.new()
	content.add_child(stats_panel)
	var stats_box := VBoxContainer.new()
	stats_panel.add_child(stats_box)
	_preview = WeaponPreview.new()
	stats_box.add_child(_preview)
	_stats_label = _label("")
	stats_box.add_child(_stats_label)
	_traits_label = _label("")
	_traits_label.add_theme_color_override("font_color", RunArt.AMBER)
	_traits_label.add_theme_font_size_override("font_size", 22)
	_traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_box.add_child(_traits_label)
	content.add_child(_upgrade_panel())
	for slot: String in Parts.SLOTS:
		content.add_child(_slot_row(slot))
	refresh()


func _slot_row(slot: String) -> Control:
	var panel := PanelContainer.new()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_label(Parts.SLOT_NAMES[slot].to_upper(), "CaptionLabel"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	row.add_child(_arrow("◀", _cycle.bind(slot, -1)))
	var name_label := _label("")
	name_label.add_theme_font_size_override("font_size", 30)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(name_label)
	row.add_child(_arrow("▶", _cycle.bind(slot, 1)))
	var desc := _label("")
	desc.add_theme_font_size_override("font_size", 20)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(desc)
	var unlock := Button.new()
	unlock.theme_type_variation = "AccentButton"
	unlock.custom_minimum_size = Vector2(0.0, 72.0)
	unlock.pressed.connect(_unlock.bind(slot))
	box.add_child(unlock)
	_names[slot] = name_label
	_descs[slot] = desc
	_unlocks[slot] = unlock
	return panel


func _upgrade_panel() -> Control:
	var panel := PanelContainer.new()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	_upgrade_title = _label("", "CaptionLabel")
	box.add_child(_upgrade_title)
	for stat: String in Arsenal.UPGRADE_BASE:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		box.add_child(row)
		var label := _label("")
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var buy := Button.new()
		buy.theme_type_variation = "AccentButton"
		buy.custom_minimum_size = Vector2(190.0, 72.0)
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
	refresh()


func _unlock(slot: String) -> void:
	if Arsenal.buy_part(Save.data, slot, _shown[slot]):
		Audio.play("ui_buy")
		_equip(slot)
		refresh()


func _upgrade(stat: String) -> void:
	if Arsenal.buy_upgrade(Save.data, _loadout["chassis"], stat):
		Audio.play("ui_buy")
		Save.save()
		refresh()


func _equip(slot: String) -> void:
	_loadout[slot] = _shown[slot]
	Save.data["loadout"] = _loadout.duplicate()
	Save.save()


func refresh() -> void:
	var coins := int(Save.data["coins"])
	for slot: String in Parts.SLOTS:
		var id: String = _shown[slot]
		var part: Dictionary = Parts.table(slot)[id]
		var owned := Arsenal.is_owned(Save.data, slot, id)
		var name_label: Label = _names[slot]
		name_label.text = part["name"]
		name_label.add_theme_color_override("font_color", RunArt.CYAN if owned else Color(0.6, 0.65, 0.75))
		(_descs[slot] as Label).text = part["desc"]
		var unlock: Button = _unlocks[slot]
		unlock.visible = not owned
		unlock.text = "Freischalten · %d ◆" % Arsenal.part_price(slot, id)
		unlock.disabled = coins < Arsenal.part_price(slot, id)

	var stats := Arsenal.stats_for(Save.data, _shown)
	_stats_label.text = "%sSchaden %s · Feuerrate %s/s\nProjektile %d%s · Reichweite %d m\nSchaden pro Sekunde ≈ %s" % [
		"VORSCHAU\n" if _shown != _loadout else "",
		WeaponStats.format_number(stats.damage), WeaponStats.format_number(stats.fire_rate),
		stats.projectiles, " ×%d Salve" % stats.burst if stats.burst > 1 else "", roundi(stats.range_m),
		WeaponStats.format_number(roundf(stats.dps()))]
	_preview.show_loadout(_shown, stats.color)
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


func _arrow(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(88.0, 72.0)
	button.pressed.connect(action)
	return button


func _label(text: String, variation: String = "") -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	return label
