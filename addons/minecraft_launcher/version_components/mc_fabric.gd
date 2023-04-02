extends Node
class_name MCFabric

const API_URL = "https://meta.fabricmc.net/"
const LOADER_PATH = "v2/versions/loader/%s/%s"

const LIBRARIES_URL = "https://maven.fabricmc.net/"

func get_loader(downloader: Requests, mc_id: String, loader_version: String):
	var url = API_URL.path_join(LOADER_PATH % [mc_id, loader_version])
	return (await downloader.do_get(url)).json()

func download_libraries(downloader: Requests, mc_id: String, loader_version: String, folder: String) -> int:
	var fabric_loader = await get_loader(downloader, mc_id, loader_version)

	if fabric_loader == null:
		return FAILED

	var libraries = []
	libraries.append_array(fabric_loader["launcherMeta"]["libraries"]["common"])
	libraries.append_array(fabric_loader["launcherMeta"]["libraries"]["client"])
	for librarie in libraries:
		var base_url = librarie["url"]
		var lib_filename = "-".join(librarie["name"].split(":").slice(1)) + ".jar"
		
		var lib_name_splitted: Array = librarie["name"].split(":") as Array
		lib_name_splitted.insert(0, lib_name_splitted.pop_front().replace(".", "/"))
		
		var lib_path = ("/".join(lib_name_splitted)).path_join(lib_filename)
		var url = LIBRARIES_URL.path_join(lib_path)
		var dst_path = folder.path_join(MCLibraries.LIBRARIES_FOLDER.path_join(lib_path))
		
		Utils.download_file(downloader, url, dst_path)
	
	return OK
