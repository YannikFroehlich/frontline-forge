extends RefCounted
## Base for test files in tests/unit/. Each test_* method runs on a fresh instance.

var errors: PackedStringArray = []


func check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		errors.append("%s erwartet %s, erhalten %s" % [message, str(expected), str(actual)])
