class_name AppVersion
## Version of the running build. version.txt is the single source of truth.


static func current() -> String:
	return FileAccess.get_file_as_string("res://version.txt").strip_edges()


## True if version [param a] is newer than [param b]. Accepts a leading "v" (git tags).
static func is_newer(a: String, b: String) -> bool:
	var pa := _parts(a)
	var pb := _parts(b)
	for i in 3:
		if pa[i] != pb[i]:
			return pa[i] > pb[i]
	return false


static func _parts(version: String) -> PackedInt32Array:
	var parts := version.strip_edges().trim_prefix("v").split(".")
	var out := PackedInt32Array([0, 0, 0])
	for i in mini(parts.size(), 3):
		out[i] = parts[i].to_int()
	return out
