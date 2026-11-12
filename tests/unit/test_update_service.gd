extends "res://tests/test_case.gd"

const UpdateService := preload("res://src/services/update_service.gd")
const HASH := "f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011"


func _release(tag: String) -> Dictionary:
	return {
		"tag_name": tag,
		"body": "Neu: Updates",
		"html_url": "https://example.test/release",
		"assets": [
			{"name": "frontline-forge-%s.apk" % tag.trim_prefix("v"), "browser_download_url": "https://example.test/a.apk", "size": 1234},
			{"name": "frontline-forge-%s.apk.sha256" % tag.trim_prefix("v"), "browser_download_url": "https://example.test/a.apk.sha256", "size": 90},
		],
	}


func test_newer_release_is_found() -> void:
	var info := UpdateService.parse_release(_release("v0.0.2"), "0.0.1")
	check_eq(info.get("version"), "0.0.2", "Version")
	check_eq(info.get("apk_url"), "https://example.test/a.apk", "APK-Adresse")
	check_eq(info.get("sha256_url"), "https://example.test/a.apk.sha256", "Pruefsummen-Adresse")
	check_eq(info.get("size"), 1234, "Groesse")


func test_same_or_older_release_is_ignored() -> void:
	check(UpdateService.parse_release(_release("v0.0.1"), "0.0.1").is_empty(), "Gleiche Version")
	check(UpdateService.parse_release(_release("v0.0.1"), "0.1.0").is_empty(), "Aeltere Version")


func test_release_without_assets_is_ignored() -> void:
	var data := _release("v0.0.2")
	data["assets"] = []
	check(UpdateService.parse_release(data, "0.0.1").is_empty(), "Ohne APK")


func test_prerelease_and_draft_are_ignored() -> void:
	var data := _release("v0.0.2")
	data["prerelease"] = true
	check(UpdateService.parse_release(data, "0.0.1").is_empty(), "Vorabversion")
	data = _release("v0.0.2")
	data["draft"] = true
	check(UpdateService.parse_release(data, "0.0.1").is_empty(), "Entwurf")


func test_generated_notes_become_plain_text() -> void:
	var body := "## What's Changed\r\n* feat: Update aus der App by @someone in https://github.com/x/y/pull/5\r\n* fix: Absturz behoben by @someone in https://github.com/x/y/pull/6\r\n\r\n## New Contributors\r\n* @someone made their first contribution in https://github.com/x/y/pull/1\r\n\r\n**Full Changelog**: https://github.com/x/y/compare/v0.0.1...v0.0.2"
	check_eq(UpdateService.clean_notes(body), "• feat: Update aus der App\n• fix: Absturz behoben", "Bereinigt")


func test_sha256_file_is_parsed() -> void:
	check_eq(UpdateService.parse_sha256("%s  frontline-forge-0.0.2.apk\n" % HASH.to_upper()), HASH, "sha256sum-Zeile")
	check_eq(UpdateService.parse_sha256(""), "", "Leer")
	check_eq(UpdateService.parse_sha256("abc  datei.apk"), "", "Zu kurz")
