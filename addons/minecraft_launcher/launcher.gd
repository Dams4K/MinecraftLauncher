extends Node
class_name Launcher

@export var default_installation: MinecraftInstallation

var downloader: HTTPRequest

func _ready() -> void:
	downloader = HTTPRequest.new()
	add_child(downloader)

func launch(installation: MinecraftInstallation = null):
	if installation == null:
		installation = default_installation
	
	var assets: MinecraftAssets = installation.get_minecraft_assets()
	assets.download_assets(downloader)
