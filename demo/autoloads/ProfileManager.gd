extends Node

signal skin_updated
signal cape_updated

const MINECRAFT_UUID = "https://api.mojang.com/users/profiles/minecraft/%s"
const MINECRAFT_PROFILE = "https://sessionserver.mojang.com/session/minecraft/profile/%s"
const UNKOWN_SKIN = preload("res://demo/assets/textures/skins/unkown.png")

@export var minecraft_folder: String = "user://"

var profile: MCProfile = MCProfile.load_profile(minecraft_folder)

@onready var downloader: Requests = $Requests
@onready var skin_download_timer: Timer = $SkinDownloadTimer

func _ready() -> void:
	get_skin_or_download()

func set_player_name(value: String):
	profile.player_name = value if value.replace(" ", "") != "" else "NoOne"
	profile.save_profile()
	
	if profile.get_skin_texture() == UNKOWN_SKIN:
		skin_download_timer.start()

func set_skin(path):
	profile.set_skin_path(path)
	skin_updated.emit()

func set_cape(path):
	profile.set_cape_path(path)
	cape_updated.emit()

func get_player_name():
	return profile.player_name

func get_skin() -> Texture2D:
	return profile.get_skin_texture()

func get_skin_or_download():
	var t = profile.get_skin_texture()
	if t == UNKOWN_SKIN:
		var path = await download_skin_texture()
		profile.set_skin_path(path)
		t = profile.get_skin_texture()
	skin_updated.emit()
	return t

func get_cape():
	return profile.get_cape_texture()

func download_skin_texture() -> String:
	var player_data = (await downloader.do_get(MINECRAFT_UUID % profile.player_name)).json()
	if player_data == null:
		print_debug("Can't download skin")
		return ""
	
	if not player_data.has("id"):
		print_debug("No uuid")
		return ""

	var player_uuid = player_data["id"]
	var encoded_skin_data = (await downloader.do_get(MINECRAFT_PROFILE % player_uuid)).json()
	if not encoded_skin_data.has("properties"):
		print_debug("No properties")
		return ""

	var skin_data: Dictionary = {}
	for d in encoded_skin_data["properties"]:
		if d["name"] == "textures":
			var s_d = Marshalls.base64_to_utf8(d["value"])
			var json = JSON.new()
			json.parse(s_d)
			skin_data = json.data
			break
	
	if skin_data:
		var path = ProjectSettings.globalize_path(profile.MOD_SKINS_FOLDER % profile.player_name)
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		await downloader.do_file(skin_data["textures"]["SKIN"]["url"], path)
		print_debug("Skin downloaded at %s" % path)
		return path
	print_debug("No idk")
	return ""


func _on_skin_download_timer_timeout() -> void:
	get_skin_or_download()
