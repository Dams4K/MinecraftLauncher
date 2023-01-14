extends Node
class_name Downloading

var downloader: HTTPRequest

func _ready() -> void:
	downloader = HTTPRequest.new()
	add_child(downloader)

func download_file(url: String, path: String, sha1: String):
	DirAccess.make_dir_recursive_absolute(path.replace(path.get_file(), "")) # TODO: check err
	# if something is missing, don't do it
	if url == "" || path == "": return
	
	if not FileAccess.file_exists(path) or not Utils.check_sha1(path, sha1):
		downloader.download_file = path
		downloader.request(url)
		await downloader.request_completed
	
	# check if file is correct
	if not Utils.check_sha1(path, sha1):
		DirAccess.remove_absolute(path)
