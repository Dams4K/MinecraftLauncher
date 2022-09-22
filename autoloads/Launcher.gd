extends Node

@onready var versionManifest: Node = $VersionManifest
@onready var libraries: Node = $Libraries

func _ready() -> void:
	return
	
	await versionManifest.get_all_versions()
	var version_file = await versionManifest.download_version_file("1.19.2")
	if not version_file.is_empty():
		libraries.libraries = version_file["libraries"]
		
		await libraries.download_natives()
		await libraries.download_libraries()
