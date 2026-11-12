extends Node
## Autoload "Updates": checks GitHub Releases for a newer version, downloads the APK,
## verifies its SHA-256 and hands it to the Android installer.
## Installation uses Godot's built-in FileProvider via OS.shell_open, so no Android plugin is needed.
## Android itself rejects an APK signed with a different key.
# ponytail: checks on every app start, no 24 h throttle or Wi-Fi-only option yet. Add both with the settings screen.

signal update_available(info: Dictionary)
signal install_started
signal failed(message: String)

const LATEST_URL := "https://api.github.com/repos/YannikFroehlich/frontline-forge/releases/latest"
const APK_PATH := "user://update.apk"
const STATE_PATH := "user://update.cfg"
const USER_AGENT := "User-Agent: FrontlineForge-Updater"

var info: Dictionary = {}
var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 60.0
	add_child(_http)
	# Left over from a finished or aborted update.
	if FileAccess.file_exists(APK_PATH):
		DirAccess.remove_absolute(APK_PATH)


## Silent on any failure (offline, rate limit, no release): the game must not depend on it.
func check() -> void:
	var response := await _fetch(LATEST_URL, ["Accept: application/vnd.github+json"])
	if not response["ok"]:
		return
	var data: Variant = JSON.parse_string((response["body"] as PackedByteArray).get_string_from_utf8())
	if not data is Dictionary:
		return
	var found := parse_release(data, AppVersion.current())
	if found.is_empty() or found["version"] == _skipped_version():
		return
	info = found
	update_available.emit(info)


func install() -> void:
	var sha := await _fetch(info["sha256_url"])
	if not sha["ok"]:
		failed.emit("Prüfsumme konnte nicht geladen werden.")
		return
	var expected := parse_sha256((sha["body"] as PackedByteArray).get_string_from_utf8())
	var download := await _fetch(info["apk_url"], [], APK_PATH)
	if not download["ok"]:
		failed.emit("Download fehlgeschlagen. Bitte Verbindung prüfen.")
		return
	if expected == "" or FileAccess.get_sha256(APK_PATH) != expected:
		DirAccess.remove_absolute(APK_PATH)
		failed.emit("Die Datei ist beschädigt (Prüfsumme falsch).")
		return
	if OS.get_name() != "Android":
		open_release_page()
		return
	if OS.shell_open(ProjectSettings.globalize_path(APK_PATH)) != OK:
		failed.emit("Installation konnte nicht gestartet werden.")
		return
	install_started.emit()


## 0..1 while the APK downloads, otherwise 0.
func get_progress() -> float:
	var total := _http.get_body_size()
	if _http.download_file == "" or total <= 0:
		return 0.0
	return float(_http.get_downloaded_bytes()) / total


func skip() -> void:
	var state := ConfigFile.new()
	state.load(STATE_PATH)
	state.set_value("update", "skipped_version", info.get("version", ""))
	state.save(STATE_PATH)


func open_release_page() -> void:
	OS.shell_open(info.get("page_url", "https://github.com/YannikFroehlich/frontline-forge/releases/latest"))


## Release JSON from the GitHub API to update info, or {} if it is not a usable newer release.
static func parse_release(data: Dictionary, current_version: String) -> Dictionary:
	var tag: String = data.get("tag_name", "")
	if tag == "" or data.get("draft", false) or data.get("prerelease", false):
		return {}
	if not AppVersion.is_newer(tag, current_version):
		return {}
	var result := {
		"version": tag.trim_prefix("v"),
		"notes": clean_notes(data.get("body", "")),
		"page_url": data.get("html_url", ""),
	}
	for asset: Dictionary in data.get("assets", []):
		var asset_name: String = asset.get("name", "")
		if asset_name.ends_with(".apk"):
			result["apk_url"] = asset.get("browser_download_url", "")
			result["size"] = asset.get("size", 0)
		elif asset_name.ends_with(".apk.sha256"):
			result["sha256_url"] = asset.get("browser_download_url", "")
	if not (result.has("apk_url") and result.has("sha256_url")):
		return {}
	return result


## GitHub's generated release notes as plain text: no headings, links, authors or changelog line.
static func clean_notes(markdown: String) -> String:
	var by_author := RegEx.create_from_string(" by @\\S+ in https?://\\S+$")
	var lines: PackedStringArray = []
	for raw: String in markdown.replace("\r", "").split("\n"):
		var line := raw.strip_edges()
		if line == "" or line.begins_with("#") or line.contains("Full Changelog"):
			continue
		line = by_author.sub(line, "")
		if line.begins_with("* ") or line.begins_with("- "):
			line = "• " + line.substr(2)
		lines.append(line)
	return "\n".join(lines)


## First token of a sha256sum line ("<hash>  <file>"), lower case, or "" if malformed.
static func parse_sha256(text: String) -> String:
	var parts := text.strip_edges().split(" ", false)
	if parts.is_empty() or parts[0].length() != 64:
		return ""
	return parts[0].to_lower()


func _skipped_version() -> String:
	var state := ConfigFile.new()
	state.load(STATE_PATH)
	return state.get_value("update", "skipped_version", "")


func _fetch(url: String, headers: Array[String] = [], to_file: String = "") -> Dictionary:
	_http.download_file = to_file
	var all_headers: PackedStringArray = [USER_AGENT]
	all_headers.append_array(headers)
	if _http.request(url, all_headers) != OK:
		_http.download_file = ""
		return {"ok": false}
	var response: Array = await _http.request_completed
	_http.download_file = ""
	var ok: bool = response[0] == HTTPRequest.RESULT_SUCCESS and response[1] == 200
	return {"ok": ok, "body": response[3]}
