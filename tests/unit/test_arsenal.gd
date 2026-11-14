extends "res://tests/test_case.gd"

const SaveService := preload("res://src/services/save_service.gd")


func _data(coins: int) -> Dictionary:
	var data := SaveService.default_data()
	data["coins"] = coins
	return data


func test_starter_parts_are_owned() -> void:
	var data := _data(0)
	for slot: String in Parts.SLOTS:
		check(Arsenal.is_owned(data, slot, Parts.DEFAULT_LOADOUT[slot]), "Standardteil %s" % slot)
	check(not Arsenal.is_owned(data, "chassis", "cannon"), "Kanone gesperrt")


func test_buy_part() -> void:
	var data := _data(500)
	check(Arsenal.buy_part(data, "chassis", "cannon"), "Kauf")
	check_eq(int(data["coins"]), 100, "Preis abgezogen")
	check(Arsenal.is_owned(data, "chassis", "cannon"), "Besitz")
	check(not Arsenal.buy_part(data, "chassis", "cannon"), "Kein Doppelkauf")
	check(not Arsenal.buy_part(data, "core", "plasma"), "Zu teuer")
	check_eq(int(data["coins"]), 100, "Nichts abgezogen")
	check(not Arsenal.buy_part(data, "chip", "gibt_es_nicht"), "Unbekannt")


func test_upgrade_cost_curve() -> void:
	check_eq(Arsenal.upgrade_cost("damage", 0), 50, "Stufe 1")
	check_eq(Arsenal.upgrade_cost("fire_rate", 0), 60, "Feuerrate teurer")
	var ratio := float(Arsenal.upgrade_cost("damage", 19)) / Arsenal.upgrade_cost("damage", 0)
	check(ratio > 13.0 and ratio < 15.0, "Stufe 20 etwa 14-mal Stufe 1 (1,15^19): %s" % ratio)


func test_buy_upgrade() -> void:
	var data := _data(100)
	check(Arsenal.buy_upgrade(data, "rifle", "damage"), "Erste Stufe")
	check_eq(Arsenal.upgrade_level(data, "rifle", "damage"), 1, "Stufe 1")
	check_eq(int(data["coins"]), 50, "50 abgezogen")
	check(not Arsenal.buy_upgrade(data, "rifle", "damage"), "58 zu teuer")
	check_eq(Arsenal.upgrade_level(data, "smg", "damage"), 0, "Stufen je Gehäuse")


func test_max_level() -> void:
	var data := _data(1000000)
	for i in Arsenal.MAX_LEVEL:
		Arsenal.buy_upgrade(data, "rifle", "fire_rate")
	check_eq(Arsenal.upgrade_level(data, "rifle", "fire_rate"), Arsenal.MAX_LEVEL, "Stufe 20")
	check(not Arsenal.buy_upgrade(data, "rifle", "fire_rate"), "Nicht über 20")


func test_upgrades_change_weapon() -> void:
	var data := _data(1000)
	Arsenal.buy_upgrade(data, "rifle", "damage")
	Arsenal.buy_upgrade(data, "rifle", "damage")
	var stats := Arsenal.equipped_stats(data)
	check(is_equal_approx(stats.damage, 10.0 * 1.08 * 1.08), "+8 %% je Stufe: %s" % stats.damage)
	check_eq(stats.fire_rate, 4.0, "Feuerrate unverändert")


func test_locked_parts_are_not_used() -> void:
	var data := _data(0)
	data["loadout"] = {"chassis": "cannon", "barrel": "fan", "core": "kinetic", "chip": "none"}
	var loadout := Arsenal.owned_loadout(data)
	check_eq(loadout["chassis"], "rifle", "Gesperrte Kanone ersetzt")
	check_eq(loadout["barrel"], "single", "Gesperrter Fächer ersetzt")


func test_save_roundtrip_keeps_progress() -> void:
	var data := _data(1000)
	Arsenal.buy_part(data, "barrel", "fan")
	Arsenal.buy_upgrade(data, "rifle", "damage")
	var loaded := SaveService.decode(SaveService.encode(data))
	check(Arsenal.is_owned(loaded, "barrel", "fan"), "Besitz gespeichert")
	check_eq(Arsenal.upgrade_level(loaded, "rifle", "damage"), 1, "Stufe gespeichert")


func test_old_save_gets_starter_parts() -> void:
	var old := SaveService.migrate({"version": 1, "coins": 3, "stats": {}, "levels": {}})
	check(Arsenal.is_owned(old, "chassis", "rifle"), "Startteile")
	check(old.has("upgrades"), "Upgrades ergänzt")
