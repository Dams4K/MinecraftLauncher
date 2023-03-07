extends Node
class_name Launcher

signal assets_downloaded
signal natives_downloaded
signal libraries_downloaded

@export var default_installation: MinecraftInstallation

var downloader: Requests

func _ready() -> void:
	downloader = Requests.new()
	add_child(downloader)

func launch(installation: MinecraftInstallation = null):
	if installation == null:
		installation = default_installation
	
	var assets: MinecraftAssets = installation.get_minecraft_assets()
	await assets.download_assets(downloader)
	emit_signal("assets_downloaded")
	
	var libraries: MinecraftLibraries = installation.get_minecraft_libraries()
	await libraries.download_natives(downloader)
	emit_signal("natives_downloaded")
	await libraries.download_libraries(downloader)
	emit_signal("libraries_downloaded")
