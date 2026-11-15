extends "res://tests/test_case.gd"

const SettingsService := preload("res://src/services/settings_service.gd")
const PATH := "user://test_settings.cfg"


func test_defaults_when_file_is_missing() -> void:
	DirAccess.remove_absolute(PATH)
	var values := SettingsService.load_from(PATH)
	for key: String in SettingsService.DEFAULTS:
		check_eq(values[key], SettingsService.DEFAULTS[key], key)


func test_roundtrip() -> void:
	var values := SettingsService.DEFAULTS.duplicate()
	values["music"] = 0.35
	values["quality"] = 0
	values["left_handed"] = true
	check(SettingsService.save_to(PATH, values), "Speichern")
	var loaded := SettingsService.load_from(PATH)
	check(is_equal_approx(loaded["music"], 0.35), "Musik")
	check_eq(loaded["quality"], 0, "Grafikstufe")
	check_eq(loaded["left_handed"], true, "Linkshänder")
	DirAccess.remove_absolute(PATH)


func test_broken_values_are_repaired() -> void:
	check_eq(SettingsService.sanitize("music", 7.0), 1.0, "Lautstärke höchstens 100 %")
	check_eq(SettingsService.sanitize("music", -1.0), 0.0, "Lautstärke mindestens 0 %")
	check_eq(SettingsService.sanitize("music", "laut"), SettingsService.DEFAULTS["music"], "Falscher Typ")
	check_eq(SettingsService.sanitize("quality", 9), 2, "Grafikstufe begrenzt")
	check_eq(SettingsService.sanitize("sensitivity", 0.1), 0.5, "Empfindlichkeit begrenzt")
	check_eq(SettingsService.sanitize("screen_shake", 1), true, "Kein bool: Standard")
	check_eq(SettingsService.sanitize("gibt_es_nicht", 1), null, "Unbekannter Schlüssel")


func test_damaged_file_gives_defaults() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("[settings\nmusic=kaputt")
	file.close()
	var values := SettingsService.load_from(PATH)
	check_eq(values["music"], SettingsService.DEFAULTS["music"], "Defekte Datei")
	DirAccess.remove_absolute(PATH)


func test_settings_are_separate_from_save() -> void:
	check(SettingsService.PATH != "user://save.json", "Eigene Datei (Plan 15.2)")
