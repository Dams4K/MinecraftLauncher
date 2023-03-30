extends Node
class_name Utils

const CHUNK_SIZE = 1024

enum OS_TYPE {
	LINUX,
	WINDOWS,
	MACOS,
	UNKNOWN
}

static func check_sha1(file_path: String, sha1: String, context: int = HashingContext.HASH_SHA1):
	var ctx = HashingContext.new()
	ctx.start(context)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file.get_error() != OK:
		return false
	
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	
	var res = ctx.finish()
	return res.hex_encode() == sha1

static func download_file(request: Requests, url: String, path: String, sha1: String = "") -> void:
	DirAccess.make_dir_recursive_absolute(path.replace(path.get_file(), "")) # TODO: check err
	# if something is missing, don't do it
	if url == "" || path == "": return
	
	if not FileAccess.file_exists(path) or not Utils.check_sha1(path, sha1):
		var response := await request.do_file(url, path)
		if response.result != Requests.Result.SUCCESS:
			print("Error of type %s: code %s" % [response.result, response.code])
			
	# check if file is correct
	if sha1 != "" and not Utils.check_sha1(path, sha1):
		DirAccess.remove_absolute(path)

static func download_content_file(http_request: HTTPRequest) -> Variant:
	return

static func get_os_type() -> OS_TYPE:
	var os_name = OS.get_name()
	var os_type := OS_TYPE.UNKNOWN
	if os_name in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]: os_type = OS_TYPE.LINUX
	elif os_name in ["Windows", "UWP"]: os_type = OS_TYPE.WINDOWS
	elif os_name in ["macOS"]: os_type = OS_TYPE.MACOS
	
	return os_type
