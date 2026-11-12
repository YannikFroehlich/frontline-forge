extends "res://tests/test_case.gd"


func test_newer_patch_minor_major() -> void:
	check(AppVersion.is_newer("0.0.2", "0.0.1"), "Patch")
	check(AppVersion.is_newer("0.1.0", "0.0.9"), "Minor schlaegt Patch")
	check(AppVersion.is_newer("1.0.0", "0.99.99"), "Major schlaegt Minor")


func test_numeric_not_alphabetic() -> void:
	check(AppVersion.is_newer("0.10.0", "0.9.0"), "10 > 9 numerisch")


func test_equal_and_older_are_not_newer() -> void:
	check(not AppVersion.is_newer("0.1.0", "0.1.0"), "Gleich")
	check(not AppVersion.is_newer("0.0.9", "0.1.0"), "Aelter")


func test_tag_prefix_and_whitespace() -> void:
	check(AppVersion.is_newer("v0.2.0", "0.1.0"), "v-Praefix")
	check(not AppVersion.is_newer("v0.1.0\n", "0.1.0"), "Zeilenumbruch")


func test_current_reads_version_file() -> void:
	var current := AppVersion.current()
	check(current.split(".").size() == 3, "version.txt hat Format MAJOR.MINOR.PATCH: '%s'" % current)
