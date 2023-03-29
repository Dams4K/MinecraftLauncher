@tool
extends Node
class_name MCInstallation

signal natives_downloaded
signal libraries_downloaded
signal assets_downloaded

@export_category("Folders")
@export var minecraft_folder = "user://"
@export var game_folder = "user://"

@export_category("Modifications")
@export var mod_loader := MINECRAFT_MOD_LOADER.VANILLA
@export var mod_list: Array[MinecraftMod] = []

@export_category("MC Version")
@export var mc_version_type := MINECRAFT_VERSION_TYPE.OFFICIAL:
	set(v):
		mc_version_type = v
		notify_property_list_changed()
var mc_version_id: String = ""
var mc_version_file: String = ""

var version_data: Dictionary = {}

enum MINECRAFT_MOD_LOADER {
	VANILLA,
	FORGE,
	FABRIC
}

enum MINECRAFT_VERSION_TYPE {
	OFFICIAL,
	PERSONAL
}

var downloader: Requests
var mc_assets: MCAssets
var mc_libraries: MCLibraries

func _get_property_list():
	var properties = []
	var version_file_usage = PROPERTY_USAGE_NO_EDITOR
	var mc_version_id_usage = PROPERTY_USAGE_NO_EDITOR
	
	if mc_version_type == MINECRAFT_VERSION_TYPE.OFFICIAL:
		mc_version_id_usage = PROPERTY_USAGE_DEFAULT
	elif mc_version_type == MINECRAFT_VERSION_TYPE.PERSONAL:
		version_file_usage = PROPERTY_USAGE_DEFAULT
	
	properties.append({
		"name": "mc_version_file",
		"type": TYPE_STRING,
		"usage": version_file_usage,
		"hint": PROPERTY_HINT_FILE
	})
	properties.append({
		"name": "mc_version_id",
		"type": TYPE_STRING,
		"usage": mc_version_id_usage,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "1.8.9"
	})
	
	return properties


func _ready() -> void:
	downloader = Requests.new()
	add_child(downloader)
	
	await load_version_file()
	
	mc_assets = MCAssets.new(version_data.get("assetIndex", {}))
	add_child(mc_assets)
	mc_libraries = MCLibraries.new(version_data.get("libraries", []))
	add_child(mc_libraries)

func load_version_file() -> void:
	if mc_version_type == MINECRAFT_VERSION_TYPE.OFFICIAL:
		version_data = await MinecraftVersions.get_version_file(downloader, mc_version_id)
	elif mc_version_type == MINECRAFT_VERSION_TYPE.PERSONAL:
		var file = FileAccess.open(mc_version_file, FileAccess.READ)
		if file.get_error() != OK:
			print("error opening version_file")
			return
	
		var content = file.get_as_text()
		version_data = JSON.parse_string(content)



func run():
	await mc_assets.download_assets(downloader)
	emit_signal("assets_downloaded")
	
	var libs_abs_path: Array[String] = []
	for lib in mc_libraries.get_libs(mc_libraries.LibrariesType.LIBRARIES):
		libs_abs_path.append(ProjectSettings.globalize_path(mc_libraries.LIBRARIES_PATH.path_join(lib.get("path", ""))))
	libs_abs_path.append("/home/damien/.local/share/godot/app_userdata/MinecraftLauncher/versions/1.8.9/1.8.9.jar")
	var args: Array[String] = [
		"-Djava.library.path=%s" % ProjectSettings.globalize_path(mc_libraries.NATIVES_PATH),
		"-Dminecraft.launcher.brand=%s" % "GoCraft",
		"-Dminecraft.launcher.version=%s" % ProjectSettings.get("application/config/version"),
		"-cp", ":".join(libs_abs_path),
		"-Xss%sM" % 1,
		"net.minecraft.client.main.Main",
		"--gameDir", ProjectSettings.globalize_path(game_folder),
		"--version", mc_version_id,
		"--username", "Dams4LT",
		"--uuid", "0",
		"--accessToken", "null",
		"--assetIndex", str(mc_assets.get_id()),
		"--assetsDir", ProjectSettings.globalize_path(mc_assets.ASSETS_FOLDER)
	]
	OS.create_process("/usr/lib/jvm/jdk-8/bin/java", args, false)
