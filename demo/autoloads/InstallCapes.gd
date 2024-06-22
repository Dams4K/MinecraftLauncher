extends Node

const CAPES_FOLDER = "user://capes"
var internal_capes_folder = "res://demo/assets/textures/capes/"

func _ready() -> void:
	var dir = DirAccess.open(internal_capes_folder)
	DirAccess.make_dir_recursive_absolute(CAPES_FOLDER)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "png":
				dir.copy(internal_capes_folder.path_join(file_name), CAPES_FOLDER.path_join(file_name))
			file_name = dir.get_next()
