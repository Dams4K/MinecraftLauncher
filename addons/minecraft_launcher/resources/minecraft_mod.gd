@tool
extends Resource
class_name MinecraftMod

@export var download_method := DOWNLOAD_METHOD.URL:
	set(v):
		download_method = v
		notify_property_list_changed()

var mod_url: String
var mod_path: String

enum DOWNLOAD_METHOD {
	URL,
	PATH
}

func _get_property_list() -> Array:
	var properties = []
	var mod_url_usage = PROPERTY_USAGE_NO_EDITOR
	var mod_path_usage = PROPERTY_USAGE_NO_EDITOR
	
	if download_method == DOWNLOAD_METHOD.URL:
		mod_url_usage = PROPERTY_USAGE_DEFAULT
	elif download_method == DOWNLOAD_METHOD.PATH:
		mod_path_usage = PROPERTY_USAGE_DEFAULT
	
	properties.append({
		"name": "mod_path",
		"type": TYPE_STRING,
		"usage": mod_path_usage,
		"hint": PROPERTY_HINT_FILE,
		"hint_text": "res://"
	})
	properties.append({
		"name": "mod_url",
		"type": TYPE_STRING,
		"usage": mod_url_usage,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_text": "https://w.x.z"
	})
	
	return properties
