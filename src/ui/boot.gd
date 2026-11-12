extends Control

@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	_version_label.text = "v%s" % AppVersion.current()
