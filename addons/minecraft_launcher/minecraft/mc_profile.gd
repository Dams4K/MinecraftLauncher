extends Resource
class_name MCProfile

const FILE_PATH = "user://profile.tres"

@export var player_name: String = ""

static func load_profile():
	if FileAccess.file_exists(FILE_PATH):
		return ResourceLoader.load(FILE_PATH)
	return MCProfile.new()
func save_profile():
	ResourceSaver.save(self, FILE_PATH)
