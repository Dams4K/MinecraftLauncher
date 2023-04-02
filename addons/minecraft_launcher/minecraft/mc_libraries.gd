extends Resource
class_name MCLibraries

var libraries_data: Array
var libraries: Array[MCLibrary] = []

func _init(libraries_data: Array) -> void:
	self.libraries_data = libraries_data
	
	for library_data in libraries_data:
		libraries.append(MCLibrary.new(library_data))

func download_artifacts(downloader: Requests, target_folder: String):
	for library in self.libraries:
		await library.download_artifact(downloader, target_folder)

func download_natives(downloader: Requests, target_folder: String):
	for library in self.libraries:
		await library.download_native(downloader, target_folder)
