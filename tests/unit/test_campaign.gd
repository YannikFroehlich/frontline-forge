extends "res://tests/test_case.gd"
## Catches typos in the level files before they crash a run on the phone.

const SaveService := preload("res://src/services/save_service.gd")


func _ids() -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in Campaign.levels():
		ids.append(entry["id"])
	return ids


func test_world_has_fifteen_levels_and_one_boss() -> void:
	var ids := _ids()
	check_eq(ids.size(), 15, "15 Level (MVP, Plan 5.1)")
	for i in ids.size():
		check_eq(Campaign.is_boss(ids[i]), i == ids.size() - 1, "Boss nur im letzten Level: %s" % ids[i])


func test_every_level_builds() -> void:
	var segments: Dictionary = Campaign._json(Campaign.SEGMENTS_PATH)
	var gates: Dictionary = Campaign._json(Campaign.GATES_PATH)
	for id in _ids():
		for entry: String in Campaign.level(id)["segments"]:
			if entry.begins_with("gate:"):
				check(gates.has(entry.substr(5)), "%s: Tor %s" % [id, entry])
			else:
				check(segments.has(entry), "%s: Segment %s" % [id, entry])
		var track := Campaign.build(id)
		check(float(track["length"]) > 200.0, "%s: Länge %s" % [id, track["length"]])
		check(int(track["enemies"]) > 0, "%s hat Gegner" % id)
		var last := -1.0
		for event: Dictionary in track["events"]:
			check(float(event["at"]) >= last, "%s: Ereignisse sortiert" % id)
			last = event["at"]
			if event.has("enemy"):
				check(LevelData.ENEMIES.has(event["enemy"]), "%s: Gegner %s" % [id, event["enemy"]])


func test_gate_presets_valid() -> void:
	var gates: Dictionary = Campaign._json(Campaign.GATES_PATH)
	for name: String in gates:
		if name.begins_with("_"):
			continue
		for key: String in ["left", "right"]:
			var side: Dictionary = gates[name][key]
			for effect: Array in side["effects"]:
				check(WeaponStats.NAMES.has(effect[0]) and effect[1] in WeaponStats.OPS, "%s/%s: %s" % [name, key, effect])
			if side.has("grow"):
				check(float(side["per_hits"]) > 0.0 and float(side["max"]) > 0.0, "%s: schießbares Tor" % name)


func test_specials_match_plan() -> void:
	check_eq(Campaign.special_name("w1_l05"), "Ohne Tore", "Level 5 Sonderlevel")
	check_eq(Campaign.special_name("w1_l10"), "Zeitrennen", "Level 10 Sonderlevel")
	for event: Dictionary in Campaign.build("w1_l05")["events"]:
		check(not event.has("left"), "Level 5 hat keine Tore")


func test_difficulty_grows() -> void:
	check_eq(Campaign.hp_scale("w1_l01"), 1.0, "Level 1 unverändert")
	check(is_equal_approx(Campaign.hp_scale("w1_l02"), 1.09), "+9 % je Level")
	check(Campaign.win_coins("w1_l15") > Campaign.win_coins("w1_l01"), "Belohnung wächst")
	check_eq(Campaign.win_coins("w1_l01"), 85, "80 × 1,06")


func test_unlocks() -> void:
	var data := SaveService.default_data()
	check(Campaign.is_unlocked(data, "w1_l01"), "Level 1 offen")
	check(not Campaign.is_unlocked(data, "w1_l02"), "Level 2 gesperrt")
	check_eq(Campaign.first_open(data), "w1_l01", "Erstes offenes Level")
	SaveService.record_run(data, "w1_l01", true, 0, 0, 60.0, 1)
	check(Campaign.is_unlocked(data, "w1_l02"), "Level 2 nach Sieg offen")
	check_eq(Campaign.first_open(data), "w1_l02", "Weiter mit Level 2")
	check(not Campaign.is_unlocked(data, "w1_l99"), "Unbekanntes Level")
	check_eq(Campaign.next_id("w1_l15"), "", "Nach dem letzten Level kommt keins")


func test_stars() -> void:
	check_eq(Campaign.star_mask(false, 0, 100, 100), 0, "Niederlage: keine Sterne")
	check_eq(Campaign.star_mask(true, 2, 10, 100), 1, "Nur geschafft")
	check_eq(Campaign.star_mask(true, 0, 10, 100), 3, "Ohne Schildverlust")
	check_eq(Campaign.star_mask(true, 1, 80, 100), 5, "80 % zerstört")
	check_eq(Campaign.star_count(7), 3, "Drei Sterne")
	check_eq(Campaign.stars_text(5), "★☆★", "Anzeige")


func test_stars_are_kept_across_runs() -> void:
	var data := SaveService.default_data()
	SaveService.record_run(data, "w1_l01", true, 0, 0, 60.0, 3)
	SaveService.record_run(data, "w1_l01", true, 0, 0, 70.0, 5)
	check_eq(int(Campaign.level_state(data, "w1_l01")["stars"]), 7, "Sterne vereinigt")
	check_eq(Campaign.total_stars(data), 3, "Summe")
	check_eq(Campaign.cleared_count(data), 1, "Geschafft")
