class_name SettingsPanel
extends VBoxContainer
## Settings page (plan 12): audio, graphics, controls, accessibility, updates, info.
## Used as the "Optionen" tab in the main menu and as an overlay in the pause menu.
## Every change is stored and applied at once by the Settings autoload.

signal closed

## Overlay mode adds a "Fertig" button and hides the manual update check.
var closable := false

var _sliders: Dictionary = {}
var _slider_labels: Dictionary = {}
var _toggles: Dictionary = {}
var _quality_buttons: Array[Button] = []
var _update_status: Label


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	add_child(_label("OPTIONEN", "TitleLabel"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	var audio := _section(content, "AUDIO")
	_slider(audio, "master", "Gesamt", 0.0, 1.0)
	_slider(audio, "music", "Musik", 0.0, 1.0)
	_slider(audio, "effects", "Effekte", 0.0, 1.0)

	var graphics := _section(content, "GRAFIK")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	graphics.add_child(row)
	var group := ButtonGroup.new()
	for i in Settings.QUALITY_NAMES.size():
		var button := Button.new()
		button.text = Settings.QUALITY_NAMES[i]
		button.toggle_mode = true
		button.button_group = group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0.0, 76.0)
		button.add_theme_font_size_override("font_size", 26)
		button.pressed.connect(Settings.set_value.bind("quality", i))
		row.add_child(button)
		_quality_buttons.append(button)
	var quality_hint := _label("Niedrig spart Akku: geringere Auflösung, ohne Leuchten und Schatten.", "CaptionLabel")
	quality_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	graphics.add_child(quality_hint)

	var controls := _section(content, "STEUERUNG")
	_slider(controls, "sensitivity", "Empfindlichkeit", Settings.SENSITIVITY_RANGE.x, Settings.SENSITIVITY_RANGE.y)
	_toggle(controls, "left_handed", "Linkshänder (Pause-Knopf rechts)")

	var access := _section(content, "BARRIEREFREIHEIT")
	_toggle(access, "screen_shake", "Bildschirm wackelt bei Treffern")
	var shapes := _label("Tore zeigen ihre Wirkung immer auch als Form: ▲ gut, ▼ schlecht, ◆ Risiko, ◎ beschießen.", "CaptionLabel")
	shapes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	access.add_child(shapes)

	var updates := _section(content, "AKTUALISIERUNG")
	_toggle(updates, "auto_update", "Beim Start nach neuer Version suchen")
	if not closable:
		var check := Button.new()
		check.text = "Jetzt suchen"
		check.custom_minimum_size = Vector2(0.0, 76.0)
		check.pressed.connect(_check_updates)
		updates.add_child(check)
		_update_status = _label("", "CaptionLabel")
		_update_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_update_status.hide()
		updates.add_child(_update_status)
		Updates.checked.connect(_on_checked)

	var info := _section(content, "INFO")
	var about := _label("Version %s\nMusik: Juhani Junkala (CC0)\nSchriften: Rajdhani, Inter (SIL Open Font License)\nSoundeffekte: im Spiel erzeugt\nKeine Daten verlassen das Gerät außer der Versionsabfrage bei GitHub." % AppVersion.current(), "CaptionLabel")
	about.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(about)

	var reset := Button.new()
	reset.text = "Alles zurücksetzen"
	reset.custom_minimum_size = Vector2(0.0, 76.0)
	reset.pressed.connect(Settings.reset)
	content.add_child(reset)

	if closable:
		var done := Button.new()
		done.text = "Fertig"
		done.theme_type_variation = "PrimaryButton"
		done.custom_minimum_size = Vector2(0.0, 84.0)
		done.pressed.connect(closed.emit)
		add_child(done)

	Settings.changed.connect(refresh)
	refresh()


func refresh() -> void:
	for key: String in _sliders:
		var slider: HSlider = _sliders[key]
		slider.set_value_no_signal(float(Settings.get_value(key)))
		(_slider_labels[key] as Label).text = "%d %%" % roundi(slider.value * 100.0)
	for key: String in _toggles:
		(_toggles[key] as CheckButton).set_pressed_no_signal(Settings.get_value(key))
	for i in _quality_buttons.size():
		_quality_buttons[i].set_pressed_no_signal(i == Settings.quality())


func _section(parent: Control, title: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(_label(title, "CaptionLabel"))
	return box


func _slider(parent: Control, key: String, text: String, min_value: float, max_value: float) -> void:
	var head := HBoxContainer.new()
	parent.add_child(head)
	var name_label := _label(text)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_label)
	var value_label := _label("")
	head.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = 0.05
	slider.custom_minimum_size = Vector2(0.0, 56.0)
	slider.value_changed.connect(_on_slider.bind(key))
	parent.add_child(slider)
	_sliders[key] = slider
	_slider_labels[key] = value_label


func _on_slider(value: float, key: String) -> void:
	(_slider_labels[key] as Label).text = "%d %%" % roundi(value * 100.0)
	# Save once the finger lets go would be nicer; saving a tiny file per step is cheap enough.
	Settings.set_value(key, value)


func _toggle(parent: Control, key: String, text: String) -> void:
	var toggle := CheckButton.new()
	toggle.text = text
	toggle.custom_minimum_size = Vector2(0.0, 64.0)
	toggle.add_theme_font_size_override("font_size", 24)
	toggle.toggled.connect(func(on: bool) -> void: Settings.set_value(key, on))
	parent.add_child(toggle)
	_toggles[key] = toggle


func _check_updates() -> void:
	_update_status.show()
	if OS.has_feature("dev"):
		_update_status.text = "Die Testversion sucht nicht nach Updates."
		return
	_update_status.text = "Suche …"
	Updates.check(true)


func _on_checked(found: bool) -> void:
	if _update_status != null and _update_status.visible and not OS.has_feature("dev"):
		_update_status.text = "Neue Version gefunden." if found else "Keine neuere Version gefunden."


func _label(text: String, variation: String = "") -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	return label
