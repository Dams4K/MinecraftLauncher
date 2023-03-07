extends Resource
class_name MinecraftLibraries

const LIBRARIES_URL = "https://libraries.minecraft.net/"
const LIBRARIES_PATH = "user://libraries/"
const NATIVES_PATH = "user://natives/"

var data: Array = []

func _init(data: Array) -> void:
	self.data = data

func unzip_file(path: String, exclude_files: Array[String], delete_archive: bool) -> void:
	var reader = ZIPReader.new()
	reader.open(path)
	
	var files = reader.get_files()
	for filename in files:
		if filename in exclude_files or filename.ends_with("/"):
			continue
		
		var res = reader.read_file(filename)
		var filepath = path.replace(path.get_file(), filename)
		var file = FileAccess.open(filepath, FileAccess.WRITE)
		
		if file != null:
			file.store_buffer(res)
	reader.close()
	
	if delete_archive:
		DirAccess.remove_absolute(path)


func download_libraries(downloader: Requests):
	var libs = get_libs(false)
	
	for lib in libs:
		var path = lib.get("path", "")
		var sha1 = lib.get("sha1", "")
		var url = lib.get("url", "")
		
		await Utils.download_file(downloader, url, LIBRARIES_PATH.path_join(path), sha1)
	
	print("download_libraries - ended")

func download_natives(downloader: Requests, clear_folder: bool = false):
	if clear_folder:
		for filename in DirAccess.get_files_at(NATIVES_PATH):
			DirAccess.remove_absolute(NATIVES_PATH.path_join(filename))
	
	var libs = get_libs(true)
	for lib in libs:
		var file_name = lib.get("path", "").split("/")[-1]
		var sha1 = lib.get("sha1", "")
		var url = lib.get("url", "")
		
		await Utils.download_file(downloader, url, NATIVES_PATH.path_join(file_name), sha1)
		await unzip_file(NATIVES_PATH.path_join(file_name), ["MANIFEST.mf"], true)
	
	print("download_natives - ended")


func get_libs(natives: bool) -> Array:
	var libs = []
	
	for librarie in data:
		if not check_rules(librarie.get("rules", [])): continue
		
		var artifact = librarie["downloads"].get("artifact", {})
		var classifiers = librarie["downloads"].get("classifiers", {})
		
		if get_os_name() in librarie.get("natives", {}) && natives:
			var os_arch = "64" if OS.has_feature("64") else "32"
			var native = classifiers.get(librarie["natives"][get_os_name()].format({"arch": os_arch}))
			if native != null:
				libs.append(native)
		if not natives && not artifact.is_empty():
			libs.append(artifact)
	
	return libs

func check_rules(rules) -> bool:
	for rule in rules:
		var action = rule.get("action") == "allow"
		var os = rule.get("os", null)
		if os == null: return action
		
		var os_arch = "x86" if OS.has_feature("64") else "32"
		
		var r_os_name = os.get("name", null)
		var r_os_version = os.get("version", null)
		var r_os_arch = os.get("arch", null)
		
		if r_os_name == get_os_name() || r_os_arch == os_arch:
			return action
	return rules.is_empty()


func get_os_name():
	var os_name = OS.get_name()
	if os_name in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]: os_name = "linux"
	elif os_name in ["Windows", "UWP"]: os_name = "windows"
	elif os_name in ["macOS"]: os_name = "osx"
	
	return os_name
