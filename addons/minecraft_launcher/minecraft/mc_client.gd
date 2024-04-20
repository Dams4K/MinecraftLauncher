extends Resource
class_name MCClient

var downloads: Dictionary = {}

func _init(data: Dictionary) -> void:
	self.downloads = data

func download_client(downloader: Requests, path: String) -> void:
	var client = downloads.get("client", {})
	
	var url: String = client.get("url", "")
	var sha1: String = client.get("sha1", "")
	
	await Utils.download_file(downloader, url, path, sha1)

func download_server() -> void:
	pass
