extends Control

const MINECRAFT_UUID = "https://api.mojang.com/users/profiles/minecraft/%s"
const MINECRAFT_PROFILE = "https://sessionserver.mojang.com/session/minecraft/profile/%s"

const UNKOWN_SKIN = preload("res://demo/assets/textures/skins/unkown.png")

var player_mat: StandardMaterial3D = preload("res://demo/assets/materials/player_godot.tres")
var cape_mat: StandardMaterial3D = preload("res://demo/assets/materials/cape.tres")

@onready var mc_installation: MCInstallation = $MCInstallation

@onready var skin_file_dialog: FileDialog = $SkinFileDialog
@onready var cape_file_dialog: FileDialog = $CapeFileDialog

@onready var player_name_line_edit: LineEdit = $CenterContainer/PanelContainer/HBoxContainer/PlayContainer/Control/VBoxContainer/PlayerNameLineEdit

var profile: MCProfile = MCProfile.load_profile()
@onready var skin_path = mc_installation.minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/skins/%s.png")
@onready var cape_path = mc_installation.minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/capes/%s.png")

@onready var skin_download_timer: Timer = $SkinDownloadTimer
@onready var requests: Requests = $Requests

func _ready() -> void:
	player_name_line_edit.text = profile.player_name
	if not load_local_skin(profile.player_name):
		skin_download_timer.start()
	load_local_cape(profile.player_name)
	setup_custom_skin_loader()
	#cape_file_dialog.root_subfolder = 
	

func setup_custom_skin_loader():
	var m = mc_installation.minecraft_folder.path_join("CustomSkinLoader")
	DirAccess.make_dir_recursive_absolute(m)
	var d = DirAccess.open("res://")
	d.copy("res://demo/copy_dir/CustomSkinLoader.json", m.path_join("CustomSkinLoader.json"))


func load_local_skin(player_name):
	var path = skin_path % player_name
	if not FileAccess.file_exists(path):
		player_mat.albedo_texture = UNKOWN_SKIN
		return false
	
	var image = Image.new()
	image.load(path)
	var t = ImageTexture.create_from_image(image)
	player_mat.albedo_texture = t
	return true


func load_local_cape(player_name):
	var path = cape_path % player_name
	if not FileAccess.file_exists(path):
		cape_mat.albedo_texture = null
		return false
	
	var image = Image.new()
	image.load(path)
	var t = ImageTexture.create_from_image(image)
	cape_mat.albedo_texture = t
	return true

func get_playername():
	var username = player_name_line_edit.text
	if username == "":
		username = "ANobody"
	return username

func _on_button_pressed() -> void:
	skin_file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	#TODO: check image size
	DirAccess.make_dir_recursive_absolute(skin_path.get_base_dir())
	DirAccess.copy_absolute(path, ProjectSettings.globalize_path(skin_path % get_playername()))
	load_local_skin(get_playername())


func _on_play_button_pressed() -> void:
	mc_installation.run(get_playername())


func _on_player_name_line_edit_text_changed(new_text: String) -> void:
	profile.player_name = new_text
	profile.save_profile()
	if not skin_download_timer.is_stopped():
		skin_download_timer.stop()
	
	if not load_local_skin(profile.player_name):
		skin_download_timer.start()
	load_local_cape(profile.player_name)


func _on_player_viewport_container_change_cape_request() -> void:
	cape_file_dialog.popup_centered()


func _on_cape_file_dialog_file_selected(path: String) -> void:
	#TODO: check image size
	DirAccess.make_dir_recursive_absolute(cape_path.get_base_dir())
	DirAccess.copy_absolute(path, ProjectSettings.globalize_path(cape_path % get_playername()))
	load_local_cape(profile.player_name)


func _on_skin_download_timer_timeout() -> void:
	var n = get_playername()
	var player_data: Dictionary = (await requests.do_get(MINECRAFT_UUID % n)).json()
	if not player_data.has("id"):
		return
	
	var player_uuid = player_data["id"]
	var encoded_skin_data = (await requests.do_get(MINECRAFT_PROFILE % player_uuid)).json()
	if not encoded_skin_data.has("properties"):
		return
	
	var skin_data: Dictionary = {}
	for d in encoded_skin_data["properties"]:
		if d["name"] == "textures":
			var s_d = Marshalls.base64_to_utf8(d["value"])
			var json = JSON.new()
			json.parse(s_d)
			skin_data = json.data
			break
	
	if skin_data:
		var path = ProjectSettings.globalize_path(skin_path % n)
		await requests.do_file(skin_data["textures"]["SKIN"]["url"], path)
		load_local_skin(n)
