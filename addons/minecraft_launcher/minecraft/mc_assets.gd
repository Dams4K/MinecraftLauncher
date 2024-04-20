extends Resource
class_name MCAssets

signal new_asset_downloaded(assets_downloaded: int, total_assets: int)

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

func get_assets_list(downloader: Requests, folder: String) -> Dictionary:
	var file_path = folder.path_join("indexes/%s.json" % get_id())
	await Utils.download_file(downloader, get_url(), file_path, get_sha1())
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file.get_error() != OK:
		push_error("Error opening file %s" % file_path)
		return {}
	var content: Dictionary = JSON.parse_string(file.get_as_text())
	var objects: Dictionary = content.get("objects", {})
	
	return objects

func download_assets(downloader: Requests, folder: String):
	var objects = await get_assets_list(downloader, folder)
	
	var assets_count = len(objects.values())
	for i in range(assets_count):
		var object = objects.values()[i]
		
		var hash: String = object.get("hash")
		var url = hash.substr(0, 2) + "/" + hash
		var object_path = folder.path_join("objects").path_join(url)
		
		if not FileAccess.file_exists(object_path):
			print_debug("Downloading assets.... %s/%s" % [i,assets_count])
			await Utils.download_file(downloader, RESOURCES_URL.path_join(url), object_path)
		emit_signal("new_asset_downloaded", i+1, assets_count)
	
	print_debug("Assets downloaded")
