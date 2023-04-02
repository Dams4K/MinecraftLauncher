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

func download_client_libraries(downloader: Requests, libs_folder) -> void:
	for librarie in client:
		librarie.download(downloader, libs_folder)

func download_common_libraries(downloader: Requests, libs_folder) -> void:
	for librarie in common:
		librarie.download(downloader, libs_folder)

func download_server_libraries(downloader: Requests, libs_folder) -> void:
	for librarie in server:
		librarie.download(downloader, libs_folder)
