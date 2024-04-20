extends LauncherLibrary
class_name MCArtifact

var data: Dictionary

func _init(artifact_data: Dictionary) -> void:
	self.data = artifact_data

func get_path() -> String:
	return self.data.get("path")
func get_url() -> String:
	return self.data.get("url")
func get_sha1() -> String:
	return self.data.get("sha1", "")
