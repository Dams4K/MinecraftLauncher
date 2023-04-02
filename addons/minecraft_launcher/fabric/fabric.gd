extends Node
class_name Fabric

const API_URL = "https://meta.fabricmc.net/"
const LOADER_PATH = "v2/versions/loader/%s/%s"

var loader_data: Dictionary = {}

static func get_specific_loader(downloader: Requests, mc_id: String, loader_version: String):
	var url = API_URL.path_join(LOADER_PATH % [mc_id, loader_version])
	return (await downloader.do_get(url)).json()

func _init(loader_data: Dictionary) -> void:
	self.loader_data = loader_data

func download_libraries(downloader: Requests, target_folder: String) -> int:
	if loader_data == null or loader_data.is_empty():
		return FAILED
	
	var fb_libraries := FBLibraries.new(loader_data["launcherMeta"]["libraries"])
	fb_libraries.download_client_libraries(downloader, target_folder)
	fb_libraries.download_common_libraries(downloader, target_folder)
	
	return OK

func get_main_class() -> String:
	if loader_data == null or loader_data.is_empty():
		return ""
	
	return loader_data["launcherMeta"]["mainClass"]["client"]
