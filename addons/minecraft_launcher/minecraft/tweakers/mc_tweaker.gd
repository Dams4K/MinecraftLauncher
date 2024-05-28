extends Resource
class_name MCTweaker

const VERSION_MANIFEST_V2_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

@export var minecraft_version: StringName = "1.20.6"

var data := {}
var complementary_data := {}

var libraries := {}

var mc_libraries: MCLibraries

func get_version_data(downloader: Requests, version_id: StringName) -> Dictionary:
	var versions = (await downloader.do_get(VERSION_MANIFEST_V2_URL)).json()
	
	for v in versions["versions"]:
		if v["id"] == version_id:
			return (await downloader.do_get(v["url"])).json()
	
	return {}

func get_complementary_version_data(downloader: Requests, version_id: StringName):
	return {}

func setup(downloader: Requests, minecraft_folder: String, java_path: String):
	data = await get_version_data(downloader, minecraft_version)	
	complementary_data = await get_complementary_version_data(downloader, minecraft_version)
	if data.is_empty():
		push_error("No data for minecraft")
	if complementary_data.is_empty():
		push_warning("No complementary data: no mods")
	
	var libraries_data: Array = data.get("libraries", [])
	libraries_data.append_array(complementary_data.get("libraries", []))
	
	if libraries_data.is_empty():
		push_error("No data for libraries")
	
	for library_data in libraries_data:
		var lib = MCLibrary.new(library_data)
		libraries[lib.name] = lib
	return "qsd"

func download_libraries(downloader: Requests, target_folder: String):
	for lib in libraries.values():
		await (lib as MCLibrary).download_artifact(downloader, target_folder)
func download_natives(downloader: Requests, target_folder: String):
	for lib in libraries.values():
		await (lib as MCLibrary).download_native(downloader, target_folder)


func get_libraries():
	var paths: Array[String] = []
	for lib in libraries.values():
		var lib_path = (lib as MCLibrary).artifact_path
		if lib_path != "":
			paths.append(ProjectSettings.globalize_path(lib_path))
	return paths

func get_jvm(library_folder: String) -> Array:
	return []
func get_game_args():
	return []

func get_main_class():
	return data["mainClass"]
func get_client_jar(downloader: Requests, versions_folder: String):
	var path = ProjectSettings.globalize_path(versions_folder.path_join("%s.jar") % minecraft_version)
	
	var client = data["downloads"]["client"]
	var url: String = client.get("url", "")
	var sha1: String = client.get("sha1", "")
	
	await Utils.download_file(downloader, url, path, sha1)
	
	return path
