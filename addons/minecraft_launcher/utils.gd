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
	if sha1.is_empty():
		return false
	
	var ctx = HashingContext.new()
	ctx.start(context)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null or file.get_error() != OK:
		return false
	
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	
	var res = ctx.finish()
	return res.hex_encode() == sha1

static func download_file(request: Requests, url: String, path: String, sha1: String = "", overwrite: bool = false) -> void:
	DirAccess.make_dir_recursive_absolute(path.replace(path.get_file(), "")) # TODO: check err
	# if something is missing, don't do it
	if url == "" || path == "": return
	
	if not FileAccess.file_exists(path) or (Utils.check_sha1(path, sha1) and overwrite):
		var response := await request.do_file(url, path)
		if response.result != Requests.Result.SUCCESS:
			print("Error of type %s: code %s" % [response.result, response.code])
			
	# check if file is correct
	if sha1 != "" and not Utils.check_sha1(path, sha1):
		DirAccess.remove_absolute(path)

static func unzip_file(path: String, exclude_files: Array[String], delete_archive: bool) -> void:
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		return
	reader.extract_files(path.get_base_dir())
	reader.close()
	
	if delete_archive:
		DirAccess.remove_absolute(path)


static func get_os_type() -> OS_TYPE:
	var os_name = OS.get_name()
	var os_type := OS_TYPE.UNKNOWN
	if os_name in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]: os_type = OS_TYPE.LINUX
	elif os_name in ["Windows", "UWP"]: os_type = OS_TYPE.WINDOWS
	elif os_name in ["macOS"]: os_type = OS_TYPE.MACOS
	
	return os_type
