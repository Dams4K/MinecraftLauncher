extends Node

@onready var versionManifest: MinecraftVersionManifest = $MinecraftVersionManifest
@onready var libraries: MinecraftLibraries = $MinecraftLibraries

func _ready() -> void:
	var version_file = await versionManifest.download_version_file("1.19.2")
	if not version_file.is_empty():
		libraries.libraries = version_file["libraries"]
		
		await libraries.download_natives(true)
		await libraries.download_libraries()
