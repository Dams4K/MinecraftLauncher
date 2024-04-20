extends Resource
class_name LauncherLibrary

func download(downloader: Requests, target_folder: String) -> String:
	var target_path = target_folder.path_join(self.get_path())
	await Utils.download_file(downloader, self.get_url(), target_path, self.get_sha1())
	return target_path

func get_path() -> String:
	return ""
func get_url() -> String:
	return ""
func get_sha1() -> String:
	return ""
