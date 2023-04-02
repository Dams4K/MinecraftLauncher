extends Resource
class_name MCLibrary

var artifact: MCArtifact
var native: MCNative
var rules: Array[MCRule]

func _init(library_data: Dictionary) -> void:
	var artifact_dict: Dictionary = library_data["downloads"].get("artifact", {})
	var classifiers_list: Dictionary = library_data.get("natives", {})

	if not artifact_dict.is_empty():
		self.artifact = MCArtifact.new(artifact_dict)
#	print(classifiers_list)
	if get_os_name() in classifiers_list:
		var classifier_name = classifiers_list[get_os_name()]
		var arch = "64" if OS.has_feature("64") else "32"
		var classifier_data = library_data["downloads"]["classifiers"].get(classifier_name.replace("${arch}", arch), {})
		if not classifier_data.is_empty():
			native = MCNative.new(classifier_data)

	for rule_data in library_data.get("rules", []):
		self.rules.append(MCRule.new(rule_data))

#	print(artifact)
#	print(native)

func download_artifact(downloader: Requests, target_folder: String):
	if not check_rules() or artifact == null:
		return
	
	await artifact.download(downloader, target_folder)

func download_native(downloader: Requests, target_folder: String):
	if not check_rules() or native == null:
		return
	
	await native.download(downloader, target_folder)

func check_rules():
	var result = true
	for rule in rules:
		result = rule.check_rule()
	return result

func get_os_name():
	var os_name = OS.get_name()
	if os_name in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]: os_name = "linux"
	elif os_name in ["Windows", "UWP"]: os_name = "windows"
	elif os_name in ["macOS"]: os_name = "osx"
	
	return os_name
