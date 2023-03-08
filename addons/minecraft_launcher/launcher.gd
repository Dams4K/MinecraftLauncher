extends Node
class_name Launcher

signal assets_downloaded
signal natives_downloaded
signal libraries_downloaded

signal file_downloaded(files_downloaded: int, total_files: int)

signal launching

@export var installation: MinecraftInstallation

var downloader: Requests
var total_files := 0
var files_downloaded := 0

func _ready() -> void:
	downloader = Requests.new()
	add_child(downloader)

func launch():
	var assets: MinecraftAssets = installation.get_minecraft_assets()
	var libraries: MinecraftLibraries = installation.get_minecraft_libraries()
	assets.new_asset_downloaded.connect(new_file_downloaded)
	libraries.new_lib_downloaded.connect(new_file_downloaded)
	
	total_files = len((await assets.get_assets_list(downloader)).values()) + len(libraries.get_libs())
	emit_signal("file_downloaded", 0, total_files)
	
	var runners := [
		func():
			await assets.download_assets(downloader)
			emit_signal("assets_downloaded"),
		func():
			await libraries.download_natives(downloader)
			emit_signal("natives_downloaded"),
		func():
			await libraries.download_libraries(downloader)
			emit_signal("libraries_downloaded")
	]

	var threads: Array[Thread] = []
	for runner in runners:
		var new_thread = Thread.new()
		new_thread.start(runner)
		threads.append(new_thread)


func new_file_downloaded(file_downloaded: int, total_files: int) -> void:
	files_downloaded += 1
	emit_signal("file_downloaded", files_downloaded, self.total_files)
	
	if files_downloaded == self.total_files:
		emit_signal("launching")
		installation.run()
