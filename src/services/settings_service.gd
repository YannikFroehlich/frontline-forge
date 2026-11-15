extends Node
## Autoload "Settings": player options (plan 12) in their own file user://settings.cfg,
## so a damaged save never takes the settings with it and vice versa (plan 15.2).
## Covers the MVP set: volume, graphics level, sensitivity, left-handed layout, screen shake, update check.
# ponytail: no graphics test on first start, no per-category reset, no language option yet (plan 12).

signal changed

const PATH := "user://settings.cfg"
const DEFAULTS := {
	"master": 1.0,
	"music": 0.8,
	"effects": 1.0,
	## 0 low, 1 medium, 2 high (plan 11.2).
	"quality": 2,
	"sensitivity": 1.0,
	"left_handed": false,
	"screen_shake": true,
	"auto_update": true,
}
const QUALITY_NAMES := ["Niedrig", "Mittel", "Hoch"]
## 3D render resolution per quality level. Low also turns off glow and shadows, medium only shadows.
const RENDER_SCALE := [0.7, 0.85, 1.0]
const SENSITIVITY_RANGE := Vector2(0.5, 2.0)

var values: Dictionary = {}


func _ready() -> void:
	values = load_from(PATH)
	apply()


func get_value(key: String) -> Variant:
	return values.get(key, DEFAULTS[key])


func set_value(key: String, value: Variant) -> void:
	values[key] = sanitize(key, value)
	save_to(PATH, values)
	apply()
	changed.emit()


func reset() -> void:
	values = DEFAULTS.duplicate()
	save_to(PATH, values)
	apply()
	changed.emit()


func quality() -> int:
	return get_value("quality")


func apply() -> void:
	# Looked up by path so this script also compiles in the test runner, where autoloads do not exist.
	var audio := get_node_or_null("/root/Audio")
	for key: String in ["master", "music", "effects"]:
		if audio != null:
			audio.call("set_volume", key, get_value(key))
	get_tree().root.scaling_3d_scale = RENDER_SCALE[quality()]


## Value of the right type and range, or the default for unknown keys and broken values.
static func sanitize(key: String, value: Variant) -> Variant:
	if not DEFAULTS.has(key):
		return null
	var fallback: Variant = DEFAULTS[key]
	match typeof(fallback):
		TYPE_BOOL:
			return value if value is bool else fallback
		TYPE_INT:
			return clampi(int(value), 0, QUALITY_NAMES.size() - 1) if value is int or value is float else fallback
		_:
			if not (value is int or value is float):
				return fallback
			if key == "sensitivity":
				return clampf(float(value), SENSITIVITY_RANGE.x, SENSITIVITY_RANGE.y)
			return clampf(float(value), 0.0, 1.0)


static func load_from(path: String) -> Dictionary:
	var file := ConfigFile.new()
	file.load(path)
	var result := {}
	for key: String in DEFAULTS:
		result[key] = sanitize(key, file.get_value("settings", key, DEFAULTS[key]))
	return result


static func save_to(path: String, data: Dictionary) -> bool:
	var file := ConfigFile.new()
	for key: String in data:
		file.set_value("settings", key, data[key])
	return file.save(path) == OK
