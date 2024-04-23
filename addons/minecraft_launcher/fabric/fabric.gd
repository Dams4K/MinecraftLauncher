extends Resource
class_name Fabric

const MAVEN_URL = "https://maven.fabricmc.net"
const API_URL = "https://meta.fabricmc.net/"
const LOADER_PATH = "v2/versions/loader/%s/%s"

var loader_data: Dictionary = {}

static func get_specific_loader(downloader: Requests, mc_id: String, loader_version: String):
	var url = API_URL.path_join(LOADER_PATH % [mc_id, loader_version])
	return (await downloader.do_get(url)).json()

func _init(loader_data: Dictionary) -> void:
	self.loader_data = loader_data

func download_loader(downloader: Requests, target_folder: String):
	var maven: String = loader_data["loader"].get("maven", "")
	var base_url = MAVEN_URL.path_join(maven.replace(":", "/").replace("net.", "net/"))
	var filename = maven.split(":", true, 1)[1].replace(":", "-") + ".jar"
	var url = base_url.path_join(filename)
	
	var splitted_lib_name = maven.split(":")
	var file_name = "-".join(splitted_lib_name.slice(1)) + ".jar"
	var dir_path = "/".join(splitted_lib_name[0].split(".") + splitted_lib_name.slice(1))
	var path = dir_path.path_join(file_name)
	
	var target_path = target_folder.path_join(path)
	await Utils.download_file(downloader, url, target_path, "")
	return target_path

func download_libraries(downloader: Requests, target_folder: String):
	if loader_data == null or loader_data.is_empty():
		return []
	
	var fb_libraries := FBLibraries.new(loader_data["launcherMeta"]["libraries"])
	var libs = []
	libs.append_array(await fb_libraries.download_client_libraries(downloader, target_folder))
	libs.append_array(await fb_libraries.download_common_libraries(downloader, target_folder))
	
	var loader_path = await download_loader(downloader, target_folder)
	libs.append(loader_path)
	
	return libs

func get_main_class() -> String:
	if loader_data == null or loader_data.is_empty():
		return ""
	
	return loader_data["launcherMeta"]["mainClass"]["client"]
