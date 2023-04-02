extends LauncherLibrary
class_name FBLibrary

var name: String
var url: String

static func from_dict(library_data: Dictionary) -> FBLibrary:
	return FBLibrary.new(library_data["name"], library_data["url"])

func _init(librarie_name: String, librarie_url: String) -> void:
	self.name = librarie_name
	self.url = librarie_url

func get_path() -> String:
	var splitted_lib_name = name.split(":")
	var file_name = "-".join(splitted_lib_name.slice(1)) + ".jar"
	var dir_path = "/".join(splitted_lib_name[0].split(".") + splitted_lib_name.slice(1))
	return dir_path.path_join(file_name)

func get_url() -> String:
	return url.path_join(self.get_path())
