extends "res://tests/test_case.gd"

const SaveService := preload("res://src/services/save_service.gd")


func _stats(chassis: String, barrel: String, core: String, chip: String) -> WeaponStats:
	return WeaponStats.from_loadout({"chassis": chassis, "barrel": barrel, "core": core, "chip": chip})


func test_counts_match_plan() -> void:
	check_eq(Parts.CHASSIS.size(), 4, "Gehäuse")
	check_eq(Parts.BARRELS.size(), 4, "Läufe")
	check_eq(Parts.CORES.size(), 4, "Kerne")
	check_eq(Parts.CHIPS.size(), 9, "8 Chips plus leerer Platz")


func test_every_part_is_valid() -> void:
	var known := WeaponStats.MUL_KEYS + WeaponStats.ADD_KEYS + WeaponStats.MAX_KEYS \
			+ ["name", "desc", "price", "color", "damage", "fire_rate", "projectiles", "range"]
	for slot: String in Parts.SLOTS:
		for id: String in Parts.table(slot):
			var part: Dictionary = Parts.table(slot)[id]
			check(str(part.get("name", "")) != "" and str(part.get("desc", "")) != "", "%s/%s Name und Text" % [slot, id])
			for key: String in part:
				check(key in known, "%s/%s unbekannter Schlüssel %s" % [slot, id, key])


func test_default_matches_prototype() -> void:
	var stats := WeaponStats.from_loadout(Parts.DEFAULT_LOADOUT)
	check_eq(stats.damage, 10.0, "Schaden")
	check_eq(stats.fire_rate, 4.0, "Feuerrate")
	check_eq(stats.projectiles, 1, "Projektile")
	check_eq(stats.burst, 1, "Keine Salve")


func test_chassis_are_balanced() -> void:
	for id: String in Parts.CHASSIS:
		var dps := _stats(id, "single", "kinetic", "none").dps()
		check(dps >= 35.0 and dps <= 50.0, "%s: %s Schaden pro Sekunde" % [id, dps])


func test_modifiers_combine() -> void:
	var stats := _stats("rifle", "fan", "plasma", "heavy")
	check_eq(stats.projectiles, 3, "Fächer +2")
	check(is_equal_approx(stats.damage, 10.0 * 0.7 * 1.15 * 1.25), "Schaden multipliziert: %s" % stats.damage)
	check(is_equal_approx(stats.fire_rate, 4.0 * 0.85), "Feuerrate: %s" % stats.fire_rate)
	check(is_equal_approx(stats.speed, 40.0 * 0.7), "Plasma langsamer")
	check(stats.spread > 0.0 and stats.radius > 0.2, "Fächer und große Projektile")


func test_shotgun_spread_and_fan_take_larger_value() -> void:
	var stats := _stats("shotgun", "fan", "kinetic", "none")
	check_eq(stats.projectiles, 5, "3 + 2")
	check_eq(stats.spread, 9.0, "Größere Streuung gewinnt")


func test_behaviour_parts() -> void:
	check_eq(_stats("rifle", "burst", "kinetic", "none").burst, 3, "Salve")
	check(_stats("rifle", "single", "cryo", "none").slow > 0.0, "Kryo")
	check(_stats("rifle", "single", "shock", "none").chain > 0.0, "Schock")
	check_eq(_stats("rifle", "single", "kinetic", "pierce").pierce, 1, "Durchschlag")
	check_eq(_stats("rifle", "single", "kinetic", "ricochet").bounce, 1, "Abpraller")
	check(_stats("rifle", "single", "kinetic", "split").split, "Teilung")
	check_eq(_stats("rifle", "single", "kinetic", "leech").leech, 40, "Schildraub")


func test_gates_still_apply_on_top() -> void:
	var stats := _stats("smg", "single", "kinetic", "none")
	stats.apply(["fire_rate", "mul", 3.0])
	check_eq(stats.fire_rate, WeaponStats.MAX_FIRE_RATE, "Deckel gilt auch für Bauteilwaffen")


func test_unknown_ids_fall_back() -> void:
	var clean := Parts.sanitize({"chassis": "laser_sword", "barrel": "fan"})
	check_eq(clean["chassis"], "rifle", "Unbekanntes Gehäuse")
	check_eq(clean["barrel"], "fan", "Bekannter Lauf bleibt")
	check_eq(clean["chip"], "none", "Fehlender Chip")
	check_eq(Parts.sanitize(null), Parts.DEFAULT_LOADOUT, "Kein Wörterbuch")


func test_save_gets_loadout() -> void:
	var old := SaveService.migrate({"version": 1, "coins": 3, "stats": {}, "levels": {}})
	check_eq(old["loadout"], Parts.DEFAULT_LOADOUT, "Alter Stand bekommt Standardwaffe")


func test_traits_listed() -> void:
	var traits := _stats("shotgun", "wave", "shock", "crit").traits()
	check("Kettenblitz" in traits and "Welle" in traits and "Kritisch 15 %" in traits, "Eigenschaften: %s" % [traits])
