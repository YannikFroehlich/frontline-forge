extends "res://tests/test_case.gd"
## Catches typos in the hand-written level before they crash a run on the phone.


func test_events_sorted_and_boss_last() -> void:
	var events: Array = LevelData.LEVEL_1["events"]
	var last := -1.0
	for event: Dictionary in events:
		var at: float = event["at"]
		check(at >= last, "Ereignis bei %s nach %s" % [at, last])
		last = at
	var final: Dictionary = events[-1]
	check(final.has("boss"), "Letztes Ereignis ist der Boss")
	check_eq(final["at"], LevelData.LEVEL_1["length"], "Boss am Levelende")


func test_enemies_known() -> void:
	for event: Dictionary in LevelData.LEVEL_1["events"]:
		if event.has("enemy"):
			check(LevelData.ENEMIES.has(event["enemy"]), "Gegnertyp %s" % event["enemy"])
			check(int(event["count"]) > 0, "Anzahl > 0")
			check(event.has("x"), "Position x")


func test_gate_effects_valid() -> void:
	for event: Dictionary in LevelData.LEVEL_1["events"]:
		if event.has("enemy") or event.has("boss"):
			continue
		for key: String in ["left", "right"]:
			var side: Dictionary = event[key]
			var effects: Array = side["effects"]
			check(not effects.is_empty(), "Tor bei %s hat Effekte" % event["at"])
			for effect: Array in effects:
				check(WeaponStats.NAMES.has(effect[0]), "Wert %s" % effect[0])
				check(effect[1] in WeaponStats.OPS, "Operation %s" % effect[1])
			if side.has("grow"):
				check(int(side["per_hits"]) > 0 and float(side["max"]) > 0.0, "Schießbares Tor bei %s" % event["at"])
