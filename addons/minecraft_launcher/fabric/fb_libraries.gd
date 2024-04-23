extends Resource
class_name FBLibraries

var client: Array[FBLibrary] = []
var common: Array[FBLibrary] = []
var server: Array[FBLibrary] = []

func _init(libraries: Dictionary) -> void:
	for librarie_data in libraries.get("client", []):
		client.append(FBLibrary.from_dict(librarie_data))
	for librarie_data in libraries.get("common", []):
		common.append(FBLibrary.from_dict(librarie_data))
	for librarie_data in libraries.get("server", []):
		server.append(FBLibrary.from_dict(librarie_data))

func download_client_libraries(downloader: Requests, libs_folder) -> Array[String]:
	var libs: Array[String] = []
	for library in client:
		var path = await library.download(downloader, libs_folder)
		libs.append(path)
	return libs

func download_common_libraries(downloader: Requests, libs_folder) -> Array[String]:
	var libs: Array[String] = []
	for library in common:
		var path = await library.download(downloader, libs_folder)
		libs.append(path)
	return libs

func download_server_libraries(downloader: Requests, libs_folder) -> Array[String]:
	var libs: Array[String] = []
	for library in server:
		var path = await library.download(downloader, libs_folder)
		libs.append(path)
	return libs
