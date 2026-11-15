extends SceneTree
## Minimal test runner, no framework needed:
##   godot --headless --path . -s tests/run_tests.gd
## Runs every test_* method of tests/unit/test_*.gd. Exit code 1 on any failure.
# ponytail: own runner instead of GUT. A test that aborts before its first check counts as failed;
# an abort after some checks is only logged. Switch to GUT if fixtures, mocks or that gap matter.

const UNIT_DIR := "res://tests/unit/"


func _init() -> void:
	var passed := 0
	var failed := 0
	for file: String in DirAccess.get_files_at(UNIT_DIR):
		if not (file.begins_with("test_") and file.ends_with(".gd")):
			continue
		var script: GDScript = load(UNIT_DIR + file)
		if script == null or not script.can_instantiate():
			failed += 1
			printerr("FAIL %s :: kompiliert nicht" % file)
			continue
		for method: Dictionary in script.get_script_method_list():
			var test_name: String = method["name"]
			if not test_name.begins_with("test_"):
				continue
			var suite: RefCounted = script.new()
			suite.call(test_name)
			var errors: PackedStringArray = suite.get("errors")
			if int(suite.get("checks")) == 0:
				errors.append("keine Prüfung ausgeführt, Test vermutlich durch Skriptfehler abgebrochen")
			if errors.is_empty():
				passed += 1
			else:
				failed += 1
				for message in errors:
					printerr("FAIL %s :: %s  %s" % [file, test_name, message])
	print("Tests: %d bestanden, %d fehlgeschlagen" % [passed, failed])
	quit(1 if failed > 0 or passed == 0 else 0)
