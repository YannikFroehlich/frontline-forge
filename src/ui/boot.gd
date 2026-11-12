extends Control

@onready var _version_label: Label = %VersionLabel
@onready var _update_panel: PanelContainer = %UpdatePanel
@onready var _update_title: Label = %UpdateTitle
@onready var _update_notes: Label = %UpdateNotes
@onready var _update_status: Label = %UpdateStatus
@onready var _progress: ProgressBar = %UpdateProgress
@onready var _update_button: Button = %UpdateButton
@onready var _later_button: Button = %LaterButton
@onready var _browser_button: Button = %BrowserButton
@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	_version_label.text = "v%s" % AppVersion.current()
	_update_panel.hide()
	Updates.update_available.connect(_on_update_available)
	Updates.install_started.connect(_on_install_started)
	Updates.failed.connect(_on_failed)
	_update_button.pressed.connect(_on_update_pressed)
	_later_button.pressed.connect(_on_later_pressed)
	_browser_button.pressed.connect(Updates.open_release_page)
	_play_button.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/run.tscn"))
	Updates.check()


func _process(_delta: float) -> void:
	if _progress.visible:
		_progress.value = Updates.get_progress()


func _on_update_available(info: Dictionary) -> void:
	var size_mb := float(info.get("size", 0)) / 1048576.0
	_update_title.text = "Version %s verfügbar (%.0f MB)" % [info["version"], size_mb]
	_update_notes.text = String(info["notes"]).strip_edges()
	_update_notes.visible = _update_notes.text != ""
	_set_state("", false)
	_update_panel.show()


func _on_update_pressed() -> void:
	_set_state("Wird geladen …", true)
	_update_button.disabled = true
	_later_button.disabled = true
	Updates.install()


func _on_later_pressed() -> void:
	Updates.skip()
	_update_panel.hide()


func _on_install_started() -> void:
	_set_state("Bitte die Installation im Android-Dialog bestätigen.", false)
	_update_button.disabled = false
	_update_button.text = "Erneut installieren"
	_later_button.disabled = false


func _on_failed(message: String) -> void:
	_set_state(message, false)
	_update_button.disabled = false
	_update_button.text = "Erneut versuchen"
	_later_button.disabled = false
	_browser_button.show()


func _set_state(status: String, downloading: bool) -> void:
	_update_status.text = status
	_update_status.visible = status != ""
	_progress.visible = downloading
	_browser_button.hide()
