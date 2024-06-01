extends Node

var curseforge_api_key: String

func _ready() -> void:
	var file = FileAccess.open(ProjectSettings.get("Launcher/Paths/CurseForgeApiKeyPath"), FileAccess.READ)
	curseforge_api_key = file.get_as_text().split("\n")[0]

func _input(event):
	if Input.is_action_just_pressed("fullscreen_shortcut"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
