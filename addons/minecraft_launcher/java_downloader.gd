extends Resource
class_name JavaDownloader

@export_placeholder("19") var java_major_version: String
@export_placeholder("https://example.com") var url: String
@export_placeholder("xx/bin/java") var exe_path: String

func download_java(downloader: Requests, folder: String) -> String:
	var path = folder.path_join("java" + java_major_version + ".zip")
	await Utils.download_file(downloader, url, path)
	await Utils.unzip_file(path, [], false)
	return path
