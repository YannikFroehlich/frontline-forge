class_name RunHud
extends CanvasLayer
## HUD of the M1 prototype: progress or boss bar, shield, weapon values, gate messages, result screen.
# ponytail: built in code with inline styles. Becomes a proper scene with theme.tres in the UI milestone.

signal back_pressed
signal restart_pressed

const TEXT := Color(0.8, 0.84, 0.9)
const DIM := Color(0.6, 0.65, 0.75)
const PANEL := Color(0.102, 0.133, 0.22, 0.92)

var _progress: ProgressBar
var _boss_bar: ProgressBar
var _boss_title: Label
var _shield: Label
var _stats: Label
var _toast: Label
var _toast_time := 0.0
var _fps: Label
var _result: PanelContainer
var _result_title: Label
var _result_text: Label


func _ready() -> void:
	var back := _button("✕", false)
	back.position = Vector2(24.0, 56.0)
	back.custom_minimum_size = Vector2(80.0, 72.0)
	back.pressed.connect(back_pressed.emit)
	add_child(back)

	_progress = _bar(RunArt.CYAN)
	_progress.anchor_right = 1.0
	_progress.offset_left = 128.0
	_progress.offset_right = -180.0
	_progress.offset_top = 82.0
	_progress.offset_bottom = 100.0
	add_child(_progress)

	_shield = _label(36, RunArt.CYAN)
	_shield.anchor_left = 1.0
	_shield.anchor_right = 1.0
	_shield.offset_left = -170.0
	_shield.offset_right = -24.0
	_shield.offset_top = 66.0
	_shield.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_shield)

	_boss_title = _label(26, RunArt.MAGENTA)
	_boss_title.text = "WÄCHTER"
	_boss_title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_title.offset_left = -300.0
	_boss_title.offset_right = 300.0
	_boss_title.offset_top = 140.0
	_boss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_title.hide()
	add_child(_boss_title)
	_boss_bar = _bar(RunArt.MAGENTA)
	_boss_bar.anchor_right = 1.0
	_boss_bar.offset_left = 60.0
	_boss_bar.offset_right = -60.0
	_boss_bar.offset_top = 180.0
	_boss_bar.offset_bottom = 204.0
	_boss_bar.hide()
	add_child(_boss_bar)

	_toast = _label(40, Color.WHITE)
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.offset_left = -340.0
	_toast.offset_right = 340.0
	_toast.offset_top = 250.0
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_constant_override("outline_size", 10)
	_toast.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07))
	add_child(_toast)

	_stats = _label(24, TEXT)
	_stats.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_stats.offset_left = -340.0
	_stats.offset_right = 340.0
	_stats.offset_top = -90.0
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_stats)

	_fps = _label(18, DIM)
	_fps.position = Vector2(24.0, 136.0)
	add_child(_fps)

	_build_result()


func _process(delta: float) -> void:
	_toast_time = maxf(_toast_time - delta, 0.0)
	_toast.modulate.a = clampf(_toast_time / 0.4, 0.0, 1.0)
	_fps.text = "%d FPS" % Engine.get_frames_per_second()


func set_shield(value: int, maximum: int) -> void:
	var filled := clampi(value, 0, maximum)
	_shield.text = "■".repeat(filled) + "□".repeat(maximum - filled)


func set_stats(stats: WeaponStats) -> void:
	_stats.text = "SCHADEN %s   FEUERRATE %s/s   PROJEKTILE %d" % [
		WeaponStats.format_number(stats.damage), WeaponStats.format_number(stats.fire_rate), stats.projectiles]


func set_progress(value: float) -> void:
	_progress.value = value


func set_boss(value: float) -> void:
	_progress.hide()
	_boss_title.show()
	_boss_bar.show()
	_boss_bar.value = value


func toast(text: String, color: Color) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast_time = 1.6


func show_result(won: bool, text: String) -> void:
	_boss_title.hide()
	_boss_bar.hide()
	_result_title.text = "SEKTOR GESICHERT" if won else "PLATTFORM ZERSTÖRT"
	_result_title.add_theme_color_override("font_color", RunArt.GREEN if won else RunArt.RED)
	_result_text.text = text
	_result.show()


func _build_result() -> void:
	_result = PanelContainer.new()
	_result.set_anchors_preset(Control.PRESET_CENTER)
	_result.offset_left = -300.0
	_result.offset_right = 300.0
	_result.offset_top = -220.0
	_result.offset_bottom = 220.0
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color(RunArt.CYAN, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(32.0)
	_result.add_theme_stylebox_override("panel", style)
	_result.hide()
	add_child(_result)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_result.add_child(box)
	_result_title = _label(40, RunArt.GREEN)
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_result_title)
	_result_text = _label(26, TEXT)
	_result_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_result_text)
	var again := _button("Nochmal", true)
	again.pressed.connect(restart_pressed.emit)
	box.add_child(again)
	var menu := _button("Menü", false)
	menu.pressed.connect(back_pressed.emit)
	box.add_child(menu)


func _label(size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value = 1.0
	bar.step = 0.001
	bar.show_percentage = false
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.102, 0.133, 0.22, 0.8)
	back.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", back)
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 80.0)
	button.add_theme_font_size_override("font_size", 28)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16.0)
	if primary:
		style.bg_color = RunArt.CYAN
		button.add_theme_color_override("font_color", Color(0.043, 0.063, 0.125))
		button.add_theme_color_override("font_pressed_color", Color(0.043, 0.063, 0.125))
		button.add_theme_color_override("font_hover_color", Color(0.043, 0.063, 0.125))
	else:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.35)
		style.border_color = DIM
		style.set_border_width_all(2)
		button.add_theme_color_override("font_color", TEXT)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	return button
