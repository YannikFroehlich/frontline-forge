extends Node
## Autoload "Save": the player's progress (plan 15.2, 15.3).
## Writes atomically (temp file, then rename), keeps the last three good states as backups and
## stores a SHA-256 checksum, so a damaged file falls back to the next backup instead of losing progress.
## The checksum detects damage, not cheating.
# ponytail: no export/import and no cloud yet. Settings get their own file with the settings screen.

const VERSION := 1
const DIR := "user://"
const BACKUPS := 3

var data: Dictionary = {}
## True when save.json was damaged and an older backup was loaded. The menu can tell the player.
var restored_from_backup := false


func _ready() -> void:
	var loaded := load_from(DIR)
	data = loaded["data"]
	restored_from_backup = loaded["backup"]


func save() -> void:
	if not write_to(DIR, data):
		push_error("Spielstand konnte nicht gespeichert werden.")


static func default_data() -> Dictionary:
	return {
		"version": VERSION,
		"coins": 0,
		"stats": {"runs": 0, "wins": 0, "kills": 0},
		"levels": {},
		"loadout": Parts.DEFAULT_LOADOUT.duplicate(),
		"owned": Arsenal.starter_owned(),
		"upgrades": {},
	}


## Books a finished run into the save data. Returns true for a new best time.
static func record_run(save_data: Dictionary, level: String, won: bool, coins: int, kills: int, time: float) -> bool:
	save_data["coins"] = int(save_data["coins"]) + coins
	var stats: Dictionary = save_data["stats"]
	stats["runs"] = int(stats["runs"]) + 1
	stats["kills"] = int(stats["kills"]) + kills
	if not won:
		return false
	stats["wins"] = int(stats["wins"]) + 1
	var levels: Dictionary = save_data["levels"]
	var entry: Dictionary = levels.get_or_add(level, {})
	entry["cleared"] = true
	if time < float(entry.get("best_time", INF)):
		entry["best_time"] = time
		return true
	return false


## File content: the data as JSON text plus its checksum, so the check does not depend on key order.
static func encode(save_data: Dictionary) -> String:
	var body := JSON.stringify(save_data)
	return JSON.stringify({"checksum": body.sha256_text(), "data": body})


## Parsed and migrated data, or {} if the text is damaged.
static func decode(text: String) -> Dictionary:
	var outer: Variant = _parse(text)
	if not outer is Dictionary:
		return {}
	var body: String = (outer as Dictionary).get("data", "")
	if body == "" or body.sha256_text() != (outer as Dictionary).get("checksum", ""):
		return {}
	var inner: Variant = _parse(body)
	if not inner is Dictionary:
		return {}
	return migrate(inner)


## Brings older saves up to VERSION. Add one step per format change, each with a test (plan 15.3).
static func migrate(save_data: Dictionary) -> Dictionary:
	var defaults := default_data()
	save_data.merge(defaults)
	(save_data["stats"] as Dictionary).merge(defaults["stats"])
	save_data["loadout"] = Parts.sanitize(save_data["loadout"])
	save_data["version"] = maxi(int(save_data["version"]), VERSION)
	return save_data


## Newest valid file wins: save.json, then save.1.json … save.3.json.
static func load_from(dir: String) -> Dictionary:
	for i in BACKUPS + 1:
		var path := _path(dir, i)
		if not FileAccess.file_exists(path):
			continue
		var loaded := decode(FileAccess.get_file_as_string(path))
		if not loaded.is_empty():
			return {"data": loaded, "backup": i > 0}
	return {"data": default_data(), "backup": false}


static func write_to(dir: String, save_data: Dictionary) -> bool:
	var temp := dir + "save.tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(encode(save_data))
	file.close()
	for i in range(BACKUPS, 0, -1):
		var older := _path(dir, i - 1)
		if FileAccess.file_exists(older):
			DirAccess.remove_absolute(_path(dir, i))
			DirAccess.rename_absolute(older, _path(dir, i))
	return DirAccess.rename_absolute(temp, _path(dir, 0)) == OK


## Like JSON.parse_string, but without logging an error for damaged files, which are expected here.
static func _parse(text: String) -> Variant:
	var json := JSON.new()
	return json.data if json.parse(text) == OK else null


static func _path(dir: String, index: int) -> String:
	return dir + ("save.json" if index == 0 else "save.%d.json" % index)
