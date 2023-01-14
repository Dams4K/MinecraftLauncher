extends Node
class_name MinecraftAssets

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
	await Utils.download_file(downloader, get_url(), "user://assets/%s.json" % get_id(), get_sha1())
