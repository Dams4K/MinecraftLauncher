extends Resource
class_name MCGameArgs

@export var client_id: String = ""
@export var xuid: String = ""

@export var username: String
@export var version: String

@export var game_dir: String
@export var assets_dir: String
@export var asset_index: String

@export var uuid: String = "null"
@export var access_token: String = "null"
@export var user_type := USER_TYPE.MOJANG

@export var version_type := VERSION_TYPE.RELEASE
@export var demo: bool = false
@export var width: int = -1
@export var height: int = -1

var USER_TYPE_NAMES: Array[String] = ["msa", "legacy", "mojang"]
var VERSION_TYPE_NAMES: Array[String] = ["release", "snapshot"]

enum USER_TYPE {
	MSA,
	LEGACY,
	MOJANG
}

enum VERSION_TYPE {
	RELEASE,
	SNAPSHOT
}

func to_array() -> Array[String]:
	var array: Array[String] = []
	
	append_if_can(array, "--clientId", client_id)
	append_if_can(array, "--xuid", xuid)
	append_if_can(array, "--username", username)
	append_if_can(array, "--version", version)
	append_if_can(array, "--gameDir", game_dir)
	append_if_can(array, "--assetsDir", assets_dir)
	append_if_can(array, "--assetIndex", asset_index)
	append_if_can(array, "--uuid", uuid)
	append_if_can(array, "--accessToken", access_token)
	append_if_can(array, "--userType", USER_TYPE_NAMES[user_type])
	append_if_can(array, "--versionType", VERSION_TYPE_NAMES[version_type])
	if demo:
		array.append("--demo")
	if width > -1:
		array.append_array(["--width", width])
	if height > -1:
		array.append_array(["--height", height])
		
	return array

func append_if_can(array: Array[String], arg: String, value: String):
	if value.is_empty():
		return
	
	array.append_array([arg, value])
