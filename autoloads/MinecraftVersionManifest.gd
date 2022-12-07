extends Node
class_name MinecraftVersionManifest

const URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

@onready var getHTTPRequest: HTTPRequest = $GetHTTPRequest
@onready var downloadVersionFileHTTPRequest: HTTPRequest = $DownloadVersionFileHTTPRequest

var versions: Dictionary

func get_all_versions() -> void:
	getHTTPRequest.request(URL)
	await getHTTPRequest.request_completed


func download_version_file(version: String, versions_folder: String = "user://versions") -> Dictionary:
	if versions.is_empty(): await get_all_versions()
	for v in versions["versions"]:
		if v["id"] == version:
			var folder_path = versions_folder.path_join(version)
			DirAccess.make_dir_recursive_absolute(folder_path)
			
			var file_path = folder_path.path_join(version + ".json")
			downloadVersionFileHTTPRequest.download_file = file_path
			downloadVersionFileHTTPRequest.request(v["url"])
			await downloadVersionFileHTTPRequest.request_completed
			
			if not Utils.check_sha1(file_path, v["sha1"]):
				var dir = DirAccess.new()
				dir.remove(file_path)
			else:
				var file = FileAccess.open(file_path, FileAccess.READ)
				var json = JSON.new()
				json.parse(file.get_as_text())
				
				return json.get_data()
	return {}


func _on_get_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	versions = json.get_data()