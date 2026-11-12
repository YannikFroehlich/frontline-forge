class_name MainMenu
extends Control
## Main menu (plan 9.1): coin balance on top, pages in the middle, tab bar at the bottom in the thumb zone.
## From app start into a run takes one tap (plan 9.2). Also shows the update panel for new releases.
# ponytail: forge, shop and settings tabs come with their milestones (M3/M4).

## Tab to open next time the menu loads, for example "arsenal" from the result page.
static var start_tab := "play"

const TABS := {"play": "Spielen", "arsenal": "Arsenal", "profile": "Profil"}
const BG := Color(0.043, 0.063, 0.125)
const ICON := preload("res://icon.svg")

var _pages: Dictionary = {}
var _tab_buttons: Dictionary = {}
var _current := ""
var _coins: Label
var _level_best: Label
var _weapon_line: Label
var _profile_stats: Label

var _update_panel: PanelContainer
var _update_title: Label
var _update_notes: Label
var _update_status: Label
var _update_progress: ProgressBar
var _update_button: Button
var _later_button: Button
var _browser_button: Button


func _ready() -> void:
	get_tree().quit_on_go_back = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)
	layout.add_child(_top_bar())

	var page_area := MarginContainer.new()
	page_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right"]:
		page_area.add_theme_constant_override("margin_" + side, 32)
	page_area.add_theme_constant_override("margin_top", 8)
	page_area.add_theme_constant_override("margin_bottom", 24)
	layout.add_child(page_area)
	_pages["play"] = _play_page()
	_pages["arsenal"] = ArsenalPage.new()
	_pages["profile"] = _profile_page()
	for id: String in TABS:
		page_area.add_child(_pages[id])

	layout.add_child(_tab_bar())
	_build_update_panel()
	_show(start_tab)
	start_tab = "play"

	Updates.update_available.connect(_on_update_available)
	Updates.install_started.connect(_on_install_started)
	Updates.failed.connect(_on_update_failed)
	Updates.check()


func _exit_tree() -> void:
	get_tree().quit_on_go_back = true


## Android back: from another tab back to "Spielen", from there close the app.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _current != "play":
			_show("play")
		else:
			get_tree().quit()


func _process(_delta: float) -> void:
	_coins.text = "◆ %d" % int(Save.data["coins"])
	if _update_progress.visible:
		_update_progress.value = Updates.get_progress()


func _show(id: String) -> void:
	_current = id
	for page_id: String in _pages:
		(_pages[page_id] as Control).visible = page_id == id
		(_tab_buttons[page_id] as Button).set_pressed_no_signal(page_id == id)
	match id:
		"play":
			_refresh_play()
		"arsenal":
			if (_pages["arsenal"] as ArsenalPage).is_node_ready():
				(_pages["arsenal"] as ArsenalPage).refresh()
		"profile":
			_refresh_profile()


# --- Layout -----------------------------------------------------------------

func _top_bar() -> Control:
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 8)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	var logo := TextureRect.new()
	logo.texture = ICON
	logo.custom_minimum_size = Vector2(56.0, 56.0)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(logo)
	var title := _label("FRONTLINE FORGE", "TitleLabel")
	title.add_theme_font_size_override("font_size", 30)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)
	_coins = _label("", "CoinLabel")
	_coins.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_coins)
	return margin


func _tab_bar() -> Control:
	var bar := PanelContainer.new()
	bar.theme_type_variation = "BottomBar"
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_bottom", 24)
	bar.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	margin.add_child(row)
	var group := ButtonGroup.new()
	for id: String in TABS:
		var button := Button.new()
		button.text = TABS[id]
		button.theme_type_variation = "TabButton"
		button.toggle_mode = true
		button.button_group = group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0.0, 96.0)
		button.pressed.connect(_show.bind(id))
		row.add_child(button)
		_tab_buttons[id] = button
	return bar


func _play_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	var top_space := Control.new()
	top_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(top_space)
	var logo := TextureRect.new()
	logo.texture = ICON
	logo.custom_minimum_size = Vector2(220.0, 220.0)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	page.add_child(logo)
	var level := _label(str(LevelData.LEVEL_1["name"]).to_upper(), "TitleLabel")
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(level)
	_level_best = _label("", "CaptionLabel")
	_level_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(_level_best)
	_weapon_line = _label("")
	_weapon_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_weapon_line)
	var bottom_space := Control.new()
	bottom_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(bottom_space)
	if Save.restored_from_backup:
		var notice := _label("Der Spielstand war beschädigt und wurde aus einer Sicherung wiederhergestellt.")
		notice.add_theme_color_override("font_color", RunArt.AMBER)
		notice.add_theme_font_size_override("font_size", 22)
		notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		page.add_child(notice)
	var play := Button.new()
	play.text = "SPIELEN"
	play.theme_type_variation = "PrimaryButton"
	play.add_theme_font_size_override("font_size", 40)
	play.custom_minimum_size = Vector2(0.0, 128.0)
	play.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/run.tscn"))
	page.add_child(play)
	return page


func _profile_page() -> Control:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 18)
	page.add_child(_label("PROFIL", "TitleLabel"))
	var panel := PanelContainer.new()
	page.add_child(panel)
	_profile_stats = _label("")
	_profile_stats.add_theme_constant_override("line_spacing", 10)
	panel.add_child(_profile_stats)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(spacer)
	var version := _label("Version %s" % AppVersion.current(), "CaptionLabel")
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(version)
	return page


func _refresh_play() -> void:
	var level: Dictionary = (Save.data["levels"] as Dictionary).get(LevelData.LEVEL_1["id"], {})
	_level_best.text = "Bestzeit %s" % _format_time(float(level["best_time"])) if level.has("best_time") \
			else "Noch nicht geschafft"
	var names: PackedStringArray = []
	var loadout := Arsenal.owned_loadout(Save.data)
	for slot: String in Parts.SLOTS:
		if loadout[slot] != "none":
			names.append(Parts.table(slot)[loadout[slot]]["name"])
	_weapon_line.text = " · ".join(names)


func _refresh_profile() -> void:
	var stats: Dictionary = Save.data["stats"]
	var owned := 0
	var total := 0
	for slot: String in Parts.SLOTS:
		for id: String in Parts.table(slot):
			total += 1
			if Arsenal.is_owned(Save.data, slot, id):
				owned += 1
	var level: Dictionary = (Save.data["levels"] as Dictionary).get(LevelData.LEVEL_1["id"], {})
	_profile_stats.text = "Läufe  %d\nSiege  %d\nZerstörte Gegner  %d\nMünzen  %d\nTeile  %d / %d\nBestzeit %s  %s" % [
		int(stats["runs"]), int(stats["wins"]), int(stats["kills"]), int(Save.data["coins"]), owned, total,
		LevelData.LEVEL_1["name"], _format_time(float(level["best_time"])) if level.has("best_time") else "–"]


# --- Update panel -----------------------------------------------------------

func _build_update_panel() -> void:
	_update_panel = PanelContainer.new()
	_update_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_update_panel.offset_left = 24.0
	_update_panel.offset_right = -24.0
	_update_panel.offset_bottom = -150.0
	_update_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var style := (get_theme_stylebox("panel", "PanelContainer") as StyleBoxFlat).duplicate() as StyleBoxFlat
	style.border_color = Color(RunArt.CYAN, 0.6)
	style.set_border_width_all(2)
	style.set_content_margin_all(28.0)
	_update_panel.add_theme_stylebox_override("panel", style)
	_update_panel.hide()
	add_child(_update_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	_update_panel.add_child(box)
	_update_title = _label("", "CoinLabel")
	_update_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_update_title)
	_update_notes = _label("")
	_update_notes.add_theme_font_size_override("font_size", 22)
	_update_notes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_update_notes.max_lines_visible = 5
	box.add_child(_update_notes)
	_update_status = _label("")
	_update_status.add_theme_font_size_override("font_size", 22)
	_update_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_update_status)
	_update_progress = ProgressBar.new()
	_update_progress.custom_minimum_size = Vector2(0.0, 24.0)
	_update_progress.max_value = 1.0
	_update_progress.step = 0.001
	_update_progress.show_percentage = false
	box.add_child(_update_progress)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	_later_button = _button("Später", "")
	_later_button.pressed.connect(_on_later_pressed)
	row.add_child(_later_button)
	_update_button = _button("Aktualisieren", "PrimaryButton")
	_update_button.pressed.connect(_on_update_pressed)
	row.add_child(_update_button)
	_browser_button = _button("Im Browser öffnen", "")
	_browser_button.pressed.connect(Updates.open_release_page)
	box.add_child(_browser_button)


func _on_update_available(info: Dictionary) -> void:
	var size_mb := float(info.get("size", 0)) / 1048576.0
	_update_title.text = "Version %s verfügbar (%.0f MB)" % [info["version"], size_mb]
	_update_notes.text = String(info["notes"]).strip_edges()
	_update_notes.visible = _update_notes.text != ""
	_set_update_state("", false)
	_update_panel.show()


func _on_update_pressed() -> void:
	_set_update_state("Wird geladen …", true)
	_update_button.disabled = true
	_later_button.disabled = true
	Updates.install()


func _on_later_pressed() -> void:
	Updates.skip()
	_update_panel.hide()


func _on_install_started() -> void:
	_set_update_state("Bitte die Installation im Android-Dialog bestätigen.", false)
	_update_button.disabled = false
	_update_button.text = "Erneut installieren"
	_later_button.disabled = false


func _on_update_failed(message: String) -> void:
	_set_update_state(message, false)
	_update_button.disabled = false
	_update_button.text = "Erneut versuchen"
	_later_button.disabled = false
	_browser_button.show()


func _set_update_state(status: String, downloading: bool) -> void:
	_update_status.text = status
	_update_status.visible = status != ""
	_update_progress.visible = downloading
	_browser_button.hide()


# --- Helpers ----------------------------------------------------------------

static func _format_time(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


func _label(text: String, variation: String = "") -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	return label


func _button(text: String, variation: String) -> Button:
	var button := Button.new()
	button.text = text
	button.theme_type_variation = variation
	button.custom_minimum_size = Vector2(0.0, 80.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button
