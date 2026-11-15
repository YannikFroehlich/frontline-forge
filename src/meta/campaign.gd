class_name Campaign
## Campaign of world 1 (plan 5.1): levels are chains of hand-built segments from data/, plus unlocks and stars.
## Pure logic on the data files and the save data, so it runs without the scene tree.

const WORLD_PATH := "res://data/levels/world_1.json"
const SEGMENTS_PATH := "res://data/segments.json"
const GATES_PATH := "res://data/gates.json"
const GATE_LENGTH := 35.0
const GATE_AT := 20.0
## Enemy health grows 9 % per level (plan 14.2). The boss keeps its own fixed value.
const HP_GROWTH := 1.09
const KILL_GOAL := 0.8
const RUSH_SPEED := 1.4
const SPECIAL_NAMES := {"no_gates": "Ohne Tore", "rush": "Zeitrennen"}
## One bit per star: 1 = cleared, 2 = no shield lost, 4 = kill goal reached.
const STAR_TEXTS := ["Abgeschlossen", "Ohne Schildverlust", "80 % der Gegner zerstört"]

## Level the next run plays. The menu and the result page set it. "" = first open level.
static var selected := ""

static var _files: Dictionary = {}


static func levels() -> Array:
	return _json(WORLD_PATH)["levels"]


static func world_name() -> String:
	return _json(WORLD_PATH)["name"]


static func index_of(id: String) -> int:
	var list := levels()
	for i in list.size():
		if (list[i] as Dictionary)["id"] == id:
			return i
	return -1


static func level(id: String) -> Dictionary:
	return levels()[maxi(index_of(id), 0)]


static func number(id: String) -> int:
	return index_of(id) + 1


static func special_name(id: String) -> String:
	return SPECIAL_NAMES.get(level(id).get("special", ""), "")


static func is_boss(id: String) -> bool:
	return level(id).get("boss", false)


## Id of the following level, or "" after the last one.
static func next_id(id: String) -> String:
	var index := index_of(id)
	if index < 0 or index + 1 >= levels().size():
		return ""
	return (levels()[index + 1] as Dictionary)["id"]


## Track of one level: events with absolute "at", total length, number of enemies, special, boss.
static func build(id: String) -> Dictionary:
	var definition := level(id)
	var segments := _json(SEGMENTS_PATH)
	var gates := _json(GATES_PATH)
	var events: Array[Dictionary] = []
	var position := 0.0
	var enemies := 0
	for entry: String in definition["segments"]:
		if entry.begins_with("gate:"):
			var gate: Dictionary = (gates[entry.substr(5)] as Dictionary).duplicate(true)
			gate["at"] = position + GATE_AT
			events.append(gate)
			position += GATE_LENGTH
			continue
		var segment: Dictionary = segments[entry]
		for event: Dictionary in segment["events"]:
			var copy := event.duplicate(true)
			copy["at"] = position + float(event["at"])
			copy["count"] = int(event["count"])
			enemies += int(event["count"])
			events.append(copy)
		position += float(segment["length"])
	if is_boss(id):
		events.append({"at": position, "boss": true})
	return {
		"events": events,
		"length": position,
		"enemies": enemies,
		"special": definition.get("special", ""),
		"boss": is_boss(id),
	}


static func hp_scale(id: String) -> float:
	return pow(HP_GROWTH, maxi(index_of(id), 0))


## Clear bonus (plan 6.3: about 80 × (1 + 0.06 × level)).
static func win_coins(id: String) -> int:
	return roundi(80.0 * (1.0 + 0.06 * number(id)))


static func star_mask(won: bool, damage_taken: int, kills: int, enemies: int) -> int:
	if not won:
		return 0
	var mask := 1
	if damage_taken == 0:
		mask |= 2
	if enemies == 0 or kills >= ceili(enemies * KILL_GOAL):
		mask |= 4
	return mask


static func star_count(mask: int) -> int:
	return (mask & 1) + ((mask >> 1) & 1) + ((mask >> 2) & 1)


static func stars_text(mask: int) -> String:
	var text := ""
	for i in 3:
		text += "★" if mask & (1 << i) else "☆"
	return text


static func level_state(data: Dictionary, id: String) -> Dictionary:
	return (data.get("levels", {}) as Dictionary).get(id, {})


static func is_cleared(data: Dictionary, id: String) -> bool:
	return level_state(data, id).get("cleared", false)


## The first level is always open, every other one after its predecessor is cleared.
static func is_unlocked(data: Dictionary, id: String) -> bool:
	var index := index_of(id)
	if index <= 0:
		return index == 0
	return is_cleared(data, (levels()[index - 1] as Dictionary)["id"])


## First unlocked level that is not cleared yet, or the last level when everything is done.
static func first_open(data: Dictionary) -> String:
	for entry: Dictionary in levels():
		if not is_cleared(data, entry["id"]):
			return entry["id"]
	return (levels()[-1] as Dictionary)["id"]


static func total_stars(data: Dictionary) -> int:
	var total := 0
	for entry: Dictionary in levels():
		total += star_count(int(level_state(data, entry["id"]).get("stars", 0)))
	return total


static func cleared_count(data: Dictionary) -> int:
	var count := 0
	for entry: Dictionary in levels():
		if is_cleared(data, entry["id"]):
			count += 1
	return count


static func _json(path: String) -> Dictionary:
	if not _files.has(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		_files[path] = parsed if parsed is Dictionary else {}
	return _files[path]
