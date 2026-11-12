extends "res://tests/test_case.gd"


func test_add_and_multiply() -> void:
	var stats := WeaponStats.new()
	stats.apply(["damage", "add", 5.0])
	check_eq(stats.damage, 15.0, "Schaden +5")
	stats.apply(["fire_rate", "mul", 1.5])
	check_eq(stats.fire_rate, 6.0, "Feuerrate x1,5")
	stats.apply(["projectiles", "add", 2.0])
	check_eq(stats.projectiles, 3, "Projektile +2")


func test_values_never_below_one() -> void:
	var stats := WeaponStats.new()
	stats.apply(["damage", "add", -50.0])
	stats.apply(["fire_rate", "mul", 0.0])
	stats.apply(["projectiles", "add", -3.0])
	check_eq(stats.damage, 1.0, "Schaden")
	check_eq(stats.fire_rate, 1.0, "Feuerrate")
	check_eq(stats.projectiles, 1, "Projektile")


func test_projectile_cap_converts_to_damage() -> void:
	var stats := WeaponStats.new()
	stats.apply(["projectiles", "add", 13.0])
	check_eq(stats.projectiles, WeaponStats.MAX_PROJECTILES, "Deckel")
	check_eq(stats.damage, 20.0, "14 statt 7 Projektile = doppelter Schaden")


func test_fire_rate_cap_converts_to_damage() -> void:
	var stats := WeaponStats.new()
	stats.apply(["fire_rate", "mul", 7.5])
	check_eq(stats.fire_rate, WeaponStats.MAX_FIRE_RATE, "Deckel")
	check_eq(stats.damage, 20.0, "30 statt 15 Schuss/s = doppelter Schaden")


func test_cap_keeps_dps() -> void:
	var stats := WeaponStats.new()
	var before := stats.dps()
	stats.apply(["projectiles", "mul", 20.0])
	check(is_equal_approx(stats.dps(), before * 20.0), "DPS bleibt trotz Deckel erhalten: %s" % stats.dps())


func test_describe() -> void:
	check_eq(WeaponStats.describe(["damage", "add", 5.0]), "SCHADEN +5")
	check_eq(WeaponStats.describe(["fire_rate", "mul", 1.5]), "FEUERRATE ×1,5")
	check_eq(WeaponStats.describe(["damage", "add", -3.0]), "SCHADEN −3")


func test_is_good() -> void:
	check(WeaponStats.is_good(["damage", "add", 1.0]), "+1 gut")
	check(not WeaponStats.is_good(["damage", "add", 0.0]), "+0 nicht gut")
	check(not WeaponStats.is_good(["fire_rate", "mul", 0.6]), "x0,6 schlecht")


func test_format_number_hides_float_noise() -> void:
	check_eq(WeaponStats.format_number(10.0 * 0.7 * 1.6 * 1.428571), "16", "Rundungsrest")
	check_eq(WeaponStats.format_number(5.6), "5,6", "Eine Nachkommastelle")
