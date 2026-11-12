extends Control

@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	var version := FileAccess.get_file_as_string("res://version.txt").strip_edges()
	_version_label.text = "v%s" % version
