extends Resource
class_name MinecraftInstallation

@export_global_file("*.json") var version_file
@export_global_dir var game_folder


func get_data():
	var file = FileAccess.open(version_file, FileAccess.READ)
	if file.get_error() != OK:
		print("error opening version_file")
		return
	
	var content = file.get_as_text()
	return JSON.parse_string(content)


func get_minecraft_assets():
	var version_data = get_data()
	return MinecraftAssets.new(version_data["assetIndex"])

#func get_libraries():
#	return version_data["libraries"]
