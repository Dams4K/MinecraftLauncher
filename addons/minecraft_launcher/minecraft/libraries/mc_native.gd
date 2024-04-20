extends MCArtifact
class_name MCNative

func download(downloader: Requests, target_folder: String) -> String:
	var path = target_folder.path_join(self.get_path())
	await Utils.download_file(downloader, self.get_url(), path, self.get_sha1())
	await Utils.unzip_file(path, [], true)
	return path

func get_path() -> String:
	return data.get("path").get_file()
