@tool
extends Node
class_name MCInstallation

signal new_file_downloaded(files_downloaded: int, files_to_download: int)

signal libraries_downloaded
signal assets_downloaded
signal client_downloaded
signal java_downloaded

@export var java_manager: JavaManager

@export_category("Folders")
@export var minecraft_folder = "user://"
@export var game_folder = "user://"

@export_category("Modifications")
@export var mod_loader := MINECRAFT_MOD_LOADER.VANILLA
@export_placeholder("0.14.19") var fabric_loader_version: String
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
#var mc_libraries: MCLibraries
var mc_client: MCClient
var mc_runner: MCRunner
#
#var mc_fabric: MCFabric
var fabric: Fabric

var files_downloaded: int = 0
var files_to_download: int = 1000

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
	if mod_loader == MINECRAFT_MOD_LOADER.FABRIC:
		fabric = Fabric.new(await Fabric.get_specific_loader(downloader, mc_version_id, fabric_loader_version))
		add_child(fabric)
	
	mc_assets = MCAssets.new(version_data.get("assetIndex", {}))
	add_child(mc_assets)
#	mc_libraries = MCLibraries.new(version_data.get("libraries", []))
#	add_child(mc_libraries)
	mc_client = MCClient.new(version_data.get("downloads", {}))
	add_child(mc_client)
	mc_runner = MCRunner.new()
	add_child(mc_runner)
#
#	mc_fabric = MCFabric.new()
#	add_child(mc_fabric)
#
##	mc_assets.new_asset_downloaded.connect(func(a, b): print("assets: ", a, "/", b))
##	mc_libraries.new_lib_downloaded.connect(func(a, b): print("libs: ", a, "/", b))
#	mc_assets.new_asset_downloaded.connect(_on_new_file_downloaded)
#	mc_libraries.new_lib_downloaded.connect(_on_new_file_downloaded)
#
#	files_to_download = len(mc_libraries.get_libs(MCLibraries.LIBRARIES_TYPE.BOTH)) + len(await mc_assets.get_assets_list(downloader, minecraft_folder))

func _on_new_file_downloaded(a, b):
	files_downloaded += 1
	new_file_downloaded.emit(files_downloaded, files_to_download)

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
	#-- DOWNLOAD LIBRARIES
	var libraries_data: Array = version_data.get("libraries", [])
	var mc_libraries: MCLibraries = MCLibraries.new(libraries_data)
	await mc_libraries.download_artifacts(downloader, minecraft_folder.path_join("libraries"))
	await mc_libraries.download_natives(downloader, minecraft_folder.path_join("natives"))
	
	if mod_loader == MINECRAFT_MOD_LOADER.FABRIC:
		await fabric.download_libraries(downloader, minecraft_folder.path_join("libraries"))
	libraries_downloaded.emit()
	
	#-- DOWNLOAD ASSETS
	await mc_assets.download_assets(downloader, minecraft_folder)
	assets_downloaded.emit()
	
	#-- DOWNLOAD CLIENT
	var client_jar_path: String = minecraft_folder.path_join("versions/%s.jar" % mc_version_id)
	await mc_client.download_client(downloader, client_jar_path)
	client_downloaded.emit()
	
	#-- DOWNLOAD JAVA
	var java_major_version = version_data["javaVersion"]["majorVersion"]
	var java_downloader: JavaDownloader = null
	if Utils.get_os_type() == Utils.OS_TYPE.LINUX:
		for linux_java_downloader in java_manager.linux_javas:
			if linux_java_downloader.java_major_version == str(java_major_version):
				java_downloader = linux_java_downloader
				break
	elif Utils.get_os_type() == Utils.OS_TYPE.WINDOWS:
		for windows_java_downloader in java_manager.windows_javas:
			if windows_java_downloader.java_major_version == str(java_major_version):
				java_downloader = windows_java_downloader
				break
	
	var java_folder_path = await java_downloader.download_java(downloader, minecraft_folder.path_join("runtime"))
	var java_exe_path = ProjectSettings.globalize_path(java_folder_path.get_base_dir().path_join(java_downloader.exe_path))
	java_downloaded.emit()

#	var jvm_args := MCJVMArgs.new()
#	jvm_args.natives_directory = ProjectSettings.globalize_path(minecraft_folder.path_join(mc_libraries.NATIVES_FOLDER))
#	jvm_args.launcher_name = "GoCraft"
#	jvm_args.launcher_version = ProjectSettings.get("application/config/version")
#	jvm_args.xmx = "%sG" % Config.max_ram
#
#	var libs_abs_path: Array[String] = []
#	for lib in mc_libraries.get_libs(mc_libraries.LIBRARIES_TYPE.LIBRARIES):
#		libs_abs_path.append(ProjectSettings.globalize_path(minecraft_folder.path_join(mc_libraries.LIBRARIES_FOLDER.path_join(lib.get("path", "")))))
#	libs_abs_path.append(ProjectSettings.globalize_path(client_jar_path))
#	jvm_args.libraries_path = libs_abs_path
#
#	var game_args := MCGameArgs.new()
#	game_args.username = "Dams4LT"
#	game_args.version = mc_version_id
#	game_args.game_dir = ProjectSettings.globalize_path(game_folder)
#	game_args.assets_dir = ProjectSettings.globalize_path(minecraft_folder.path_join(mc_assets.ASSETS_FOLDER))
#	game_args.asset_index = mc_assets.get_id()
#	game_args.width = Config.x_resolution
#	game_args.height = Config.y_resolution
#
#	mc_runner.jvm_args = jvm_args
#	mc_runner.game_args = game_args
#	mc_runner.main_class = version_data["mainClass"]
#	mc_runner.java_path = java_exe_path
#	
#	mc_runner.run()
