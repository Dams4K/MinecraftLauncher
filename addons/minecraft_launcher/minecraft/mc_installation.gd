@tool
extends Node
class_name MCInstallation

signal version_file_loaded

signal new_file_downloaded(files_downloaded: int, files_to_download: int)

signal libraries_downloaded
signal assets_downloaded
signal client_downloaded
signal java_downloaded

const LIBRARIES_FOLDER = "libraries"
const NATIVES_FOLDER = "natives"
const ASSETS_FOLDER = "assets"
const VERSIONS_FOLDER = "versions"
const RUNTIME_FOLDER = "runtime"

@export var java_manager: JavaManager
@export var launcher_name := "GoCraft"
@export var launcher_version := "1.0.0"

@export_dir var copy_dir

@export var tweaker: MCTweaker
@export var mods: Array[MCMod] = []

@export_category("Folders")
@export var minecraft_folder = "user://"
@export var game_folder = "user://"

@export_category("Modifications")
@export var mod_loader := MINECRAFT_MOD_LOADER.VANILLA
@export_placeholder("x.x.x") var fabric_loader_version: String
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

var files_downloaded: int = 0
var files_to_download: int = 1000

func _get_property_list():
	var properties = []
	var version_file_usage = PROPERTY_USAGE_NO_EDITOR
	var mc_version_id_usage = PROPERTY_USAGE_NO_EDITOR
	var mod_list_usage = PROPERTY_USAGE_NO_EDITOR
	
	if mc_version_type == MINECRAFT_VERSION_TYPE.OFFICIAL:
		mc_version_id_usage = PROPERTY_USAGE_DEFAULT
	elif mc_version_type == MINECRAFT_VERSION_TYPE.PERSONAL:
		version_file_usage = PROPERTY_USAGE_DEFAULT
	
	if mod_loader in [MINECRAFT_MOD_LOADER.FORGE, MINECRAFT_MOD_LOADER.FABRIC]:
		mod_list_usage = PROPERTY_USAGE_DEFAULT
	
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
		"hint_string": "x.x.x"
	})
	
	return properties


func _ready() -> void:
	downloader = Requests.new()
	downloader.name = "Downloader"
	add_child(downloader)
	
	await load_version_file()


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
	
	version_file_loaded.emit()

func run(username: String):
	#-- DOWNLOAD JAVA
	var java_major_version = 17 #TODO: fix this, i'm forced to set manually 8
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
	
	var java_folder_path = await java_downloader.download_java(downloader, minecraft_folder.path_join(RUNTIME_FOLDER))
	var java_exe_path = ProjectSettings.globalize_path(java_folder_path.get_base_dir().path_join(java_downloader.exe_path))
	print("Java downloaded")
	java_downloaded.emit()
	
	await tweaker.setup(downloader, minecraft_folder, java_exe_path)
	print("Libs")
	
	await tweaker.download_libraries(downloader, minecraft_folder.path_join(LIBRARIES_FOLDER))
	print("Natives")
	await tweaker.download_natives(downloader, minecraft_folder.path_join(NATIVES_FOLDER))
	var artifacts = tweaker.get_libraries()
	print("%s artifacts" % len(artifacts))
	
	libraries_downloaded.emit()
	
	var mc_assets = tweaker.get_assets()
	await mc_assets.download_assets(downloader, minecraft_folder.path_join(ASSETS_FOLDER))
	assets_downloaded.emit()
	
	#-- Download MODS
	for mod in mods:
		(mod as CFMod).get_file(downloader, minecraft_folder.path_join("mods"))
	print("mods downloaded")
	
	#-- DOWNLOAD CLIENT
	#var client_jar_path: String = 
	await tweaker.download_client_jar(downloader, minecraft_folder.path_join(VERSIONS_FOLDER))
	client_downloaded.emit()
	
	var jvm_args := MCJVMArgs.new()
	jvm_args.natives_directory = ProjectSettings.globalize_path(minecraft_folder.path_join(NATIVES_FOLDER))
	jvm_args.launcher_name = launcher_name
	jvm_args.launcher_version = launcher_version
	jvm_args.xmx = "%sG" % Config.max_ram
	#jvm_args.complementaries = tweaker.get_jvm(minecraft_folder.path_join(LIBRARIES_FOLDER))

	var libs_abs_path: Array[String] = artifacts
	
	#if client_jar_path != "":
		#libs_abs_path.append(ProjectSettings.globalize_path(client_jar_path))
	jvm_args.libraries_path = libs_abs_path
	
	var game_args := MCGameArgs.new()
	game_args.username = username
	game_args.version = mc_version_id
	game_args.game_dir = ProjectSettings.globalize_path(game_folder)
	game_args.assets_dir = ProjectSettings.globalize_path(minecraft_folder.path_join(ASSETS_FOLDER))
	game_args.asset_index = mc_assets.get_id()
	game_args.width = Config.x_resolution
	game_args.height = Config.y_resolution
	game_args.complementaries = tweaker.get_game_args()
	
	var mc_runner = MCRunner.new()
	mc_runner.jvm_args = jvm_args
	mc_runner.game_args = game_args
	#mc_runner.main_class = tweaker.get_main_class()
	mc_runner.tweaker = tweaker
	mc_runner.java_path = java_exe_path
	
	mc_runner.run()
