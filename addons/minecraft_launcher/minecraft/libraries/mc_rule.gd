extends Resource
class_name MCRule

var rule: Dictionary

func _init(rule) -> void:
	self.rule = rule

func check_os(name: String) -> bool:
	return name.to_lower() == get_os_name().to_lower()
func check_arch(arch: String) -> bool:
	return arch == ("x86" if OS.has_feature("64") else "32")
func check_version(version: String) -> bool:
	var v = version.replace("^", "").replace("\\", "")
	if OS.get_version().begins_with(v):
		return true
	return false

func check_rule() -> bool:
	var rule_validate = true
	var result: bool = true if rule["action"] == "allow" else false
	
	if "os" in rule:
		if "name" in rule["os"]:
			rule_validate = check_os(rule["os"]["name"])
		if "arch" in rule["os"]:
			rule_validate = check_arch(rule["os"]["arch"])
		if "version" in rule["os"]:
			rule_validate = check_version(rule["os"]["version"])
	
	if rule_validate:
		return result
	else:
		return !result

func get_os_name() -> String:
	var os_name = OS.get_name()
	if os_name in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]: os_name = "linux"
	elif os_name in ["Windows", "UWP"]: os_name = "windows"
	elif os_name in ["macOS"]: os_name = "osx"
	
	return os_name
