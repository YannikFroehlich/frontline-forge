extends RefCounted
## Base for test files in tests/unit/. Each test_* method runs on a fresh instance.

var errors: PackedStringArray = []
## Number of checks run. A test that ran none was aborted by a script error.
var checks := 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		errors.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	checks += 1
	if actual != expected:
		errors.append("%s erwartet %s, erhalten %s" % [message, str(expected), str(actual)])
