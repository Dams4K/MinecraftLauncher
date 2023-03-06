extends Node
class_name MinecraftAssets

const RESOURCES_URL = "https://resources.download.minecraft.net/"

var data: Dictionary = {}

func _init(data: Dictionary) -> void:
	self.data = data

func get_id():
	return data.get("id", -1)
func get_sha1():
	return data.get("sha1", "")
func get_size():
	return data.get("size", -1)
func get_total_size():
	return data.get("totalSize", -1)
func get_url():
	return data.get("url", "")

func download_assets(downloader: HTTPRequest):
	var folder = "user://assets/"
	var file_path = folder.path_join("%s.json" % get_id())
	await Utils.download_file(downloader, get_url(), file_path, get_sha1())
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file.get_error() != OK:
		print("error opening version_file")
		return
	var content: Dictionary = JSON.parse_string(file.get_as_text())
	var objects = content.get("objects", {})
	
	for object in objects.values():
		var hash: String = object.get("hash")
		var url = hash.substr(0, 2) + "/" + hash
		var object_path = folder.path_join("assets/objects").path_join(url)
		
		if not FileAccess.file_exists(object_path):
			await Utils.download_file(downloader, RESOURCES_URL.path_join(url), object_path)
	
	print("finish")
