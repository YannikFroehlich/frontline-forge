extends "res://tests/test_case.gd"

const SaveService := preload("res://src/services/save_service.gd")
const DIR := "user://test_save/"


func _fresh_dir() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	for file: String in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR + file)


func test_encode_decode_roundtrip() -> void:
	var data := SaveService.default_data()
	data["coins"] = 123
	var loaded := SaveService.decode(SaveService.encode(data))
	check_eq(int(loaded["coins"]), 123, "Münzen")


func test_damaged_text_is_rejected() -> void:
	var text := SaveService.encode(SaveService.default_data()).replace("\\\"coins\\\":0", "\\\"coins\\\":999")
	check(text.contains("999"), "Testdaten manipuliert")
	check(SaveService.decode(text).is_empty(), "Prüfsumme falsch")
	check(SaveService.decode("").is_empty(), "Leer")
	check(SaveService.decode("{kaputt").is_empty(), "Kein JSON")


func test_migrate_fills_missing_keys() -> void:
	var loaded := SaveService.migrate({"version": 1, "coins": 5, "stats": {"runs": 2}})
	check_eq(int(loaded["coins"]), 5, "Vorhandenes bleibt")
	check_eq(int(loaded["stats"]["runs"]), 2, "Vorhandene Statistik bleibt")
	check_eq(int(loaded["stats"]["wins"]), 0, "Fehlende Statistik ergänzt")
	check(loaded.has("levels"), "Fehlender Abschnitt ergänzt")


func test_write_keeps_three_backups() -> void:
	_fresh_dir()
	for coins in 5:
		var data := SaveService.default_data()
		data["coins"] = coins
		check(SaveService.write_to(DIR, data), "Schreiben %d" % coins)
	var files := DirAccess.get_files_at(DIR)
	check_eq(files.size(), 4, "save.json plus drei Sicherungen: %s" % [files])
	check_eq(int(SaveService.load_from(DIR)["data"]["coins"]), 4, "Neuester Stand")


func test_damaged_file_falls_back_to_backup() -> void:
	_fresh_dir()
	for coins: int in [10, 20]:
		var data := SaveService.default_data()
		data["coins"] = coins
		SaveService.write_to(DIR, data)
	var file := FileAccess.open(DIR + "save.json", FileAccess.WRITE)
	file.store_string("{kaputt")
	file.close()
	var loaded := SaveService.load_from(DIR)
	check(loaded["backup"], "Sicherung benutzt")
	check_eq(int(loaded["data"]["coins"]), 10, "Vorheriger Stand")


func test_missing_files_give_defaults() -> void:
	_fresh_dir()
	var loaded := SaveService.load_from(DIR)
	check(not loaded["backup"], "Keine Sicherung")
	check_eq(int(loaded["data"]["coins"]), 0, "Neuer Stand")


func test_record_run() -> void:
	var data := SaveService.default_data()
	check(not SaveService.record_run(data, "w1_l01", false, 12, 30, 50.0), "Niederlage ist keine Bestzeit")
	check_eq(int(data["coins"]), 12, "Münzen auch bei Niederlage")
	check(SaveService.record_run(data, "w1_l01", true, 200, 40, 100.0), "Erster Sieg ist Bestzeit")
	check(not SaveService.record_run(data, "w1_l01", true, 200, 40, 110.0), "Langsamer ist keine Bestzeit")
	check(SaveService.record_run(data, "w1_l01", true, 200, 40, 90.0), "Schneller ist Bestzeit")
	check_eq(int(data["coins"]), 612, "Münzen summiert")
	check_eq(int(data["stats"]["runs"]), 4, "Läufe")
	check_eq(int(data["stats"]["wins"]), 3, "Siege")
	check_eq(int(data["stats"]["kills"]), 150, "Zerstört")
	check_eq(float(data["levels"]["w1_l01"]["best_time"]), 90.0, "Bestzeit")
