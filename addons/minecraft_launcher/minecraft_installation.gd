@tool
extends Resource
class_name MinecraftInstallation

@export_group("Folders")
@export var minecraft_folder = "user://"
@export var game_folder = "user://"

@export_group("Modifications")
@export var mod_loader := MINECRAFT_MOD_LOADER.VANILLA
@export var mod_list: Array[MinecraftMod] = []

@export_group("Mc Version")
@export var minecraft_version_type := MINECRAFT_VERSION_TYPE.OFFICIAL:
	set(value):
		minecraft_version_type = value
		notify_property_list_changed()
var mc_version_id: String = ""
var mc_version_file: String = ""

enum MINECRAFT_MOD_LOADER {
	VANILLA,
	FORGE,
	FABRIC
}

enum MINECRAFT_VERSION_TYPE {
	OFFICIAL,
	PERSONAL
}

func _get_property_list():
	var properties = []
	var version_file_usage = PROPERTY_USAGE_NO_EDITOR
	var mc_version_id_usage = PROPERTY_USAGE_NO_EDITOR
	
	if minecraft_version_type == MINECRAFT_VERSION_TYPE.OFFICIAL:
		mc_version_id_usage = PROPERTY_USAGE_DEFAULT
	elif minecraft_version_type == MINECRAFT_VERSION_TYPE.PERSONAL:
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


func get_data():
	var file = FileAccess.open(mc_version_file, FileAccess.READ)
	if file.get_error() != OK:
		print("error opening version_file")
		return
	
	var content = file.get_as_text()
	return JSON.parse_string(content)


func get_minecraft_assets():
	var version_data = get_data()
	return MinecraftAssets.new(version_data["assetIndex"])

func get_minecraft_libraries():
	var version_data = get_data()
	return MinecraftLibraries.new(version_data["libraries"])

func run(minecraft_libraries: MinecraftLibraries, minecraft_assets: MinecraftAssets):
	var libs_abs_path: Array[String] = []
	for lib in minecraft_libraries.get_libs(minecraft_libraries.LibrariesType.LIBRARIES):
		libs_abs_path.append(ProjectSettings.globalize_path(minecraft_libraries.LIBRARIES_PATH.path_join(lib.get("path", ""))))
	libs_abs_path.append("/home/damien/.local/share/godot/app_userdata/MinecraftLauncher/versions/1.8.9/1.8.9.jar")
	var args: Array[String] = [
		"-Djava.library.path=%s" % ProjectSettings.globalize_path(minecraft_libraries.NATIVES_PATH),
		"-Dminecraft.launcher.brand=%s" % "GodotLauncher",
		"-Dminecraft.launcher.version=%s" % ProjectSettings.get("application/config/version"),
		"-cp", ":".join(libs_abs_path),
		"-Xss%sM" % 1,
		"net.minecraft.client.main.Main",
		"--gameDir", ProjectSettings.globalize_path(game_folder),
		"--version", "1.8.9",
		"--username", "Dams4LT",
		"--uuid", "0",
		"--accessToken", "null",
		"--assetIndex", str(minecraft_assets.get_id()),
		"--assetsDir", ProjectSettings.globalize_path(minecraft_assets.ASSETS_FOLDER)
	]
	OS.create_process("/usr/lib/jvm/jdk-8/bin/java", args, false)
