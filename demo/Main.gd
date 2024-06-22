extends Control

const MINECRAFT_UUID = "https://api.mojang.com/users/profiles/minecraft/%s"
const MINECRAFT_PROFILE = "https://sessionserver.mojang.com/session/minecraft/profile/%s"

const UNKOWN_SKIN = preload("res://demo/assets/textures/skins/unkown.png")

var player_mat: StandardMaterial3D = preload("res://demo/assets/materials/player_godot.tres")
var cape_mat: StandardMaterial3D = preload("res://demo/assets/materials/cape.tres")

@onready var mc_installation: MCInstallation = $MCInstallation

@onready var skin_file_dialog: FileDialog = $SkinFileDialog
@onready var cape_selector_window: Window = $CapesSelectorWindow

@onready var player_name_line_edit: LineEdit = $CenterContainer/PanelContainer/HBoxContainer/PlayContainer/Control/VBoxContainer/PlayerNameLineEdit



@onready var skin_download_timer: Timer = $SkinDownloadTimer
@onready var requests: Requests = $Requests

@onready var player_viewport_container: SubViewportContainer = $CenterContainer/PanelContainer/HBoxContainer/SkinContainer/PlayerViewportContainer

func _ready() -> void:
	print(ProjectSettings.globalize_path("user://"))
	modulate.a = 0.0
	
	player_name_line_edit.text = ProfileManager.get_player_name()
	#if not load_local_skin(profile.player_name):
		#skin_download_timer.start()
	#load_local_cape(profile.player_name)
	setup_custom_skin_loader()
	

func setup_custom_skin_loader():
	var m = mc_installation.minecraft_folder.path_join("CustomSkinLoader")
	DirAccess.make_dir_recursive_absolute(m)
	var d = DirAccess.open("res://")
	d.copy("res://demo/copy_dir/CustomSkinLoader.json", m.path_join("CustomSkinLoader.json"))


#func load_local_skin(player_name):
	#var path = skin_path % player_name
	#if not FileAccess.file_exists(path):
		#player_mat.albedo_texture = UNKOWN_SKIN
		#return false
	#
	#var image = Image.new()
	#image.load(path)
	#var t = ImageTexture.create_from_image(image)
	#player_mat.albedo_texture = t
	#return true


#func load_local_cape(player_name):
	#var path = cape_path % player_name
	#if not FileAccess.file_exists(path):
		#cape_mat.albedo_texture = null
		#return false
	#
	#var image = Image.new()
	#image.load(path)
	#var t = ImageTexture.create_from_image(image)
	#cape_mat.albedo_texture = t
	#return true

func get_playername():
	var username = player_name_line_edit.text
	if username == "":
		username = "ANobody"
	return username

func _on_button_pressed() -> void:
	skin_file_dialog.popup_centered()

func _on_play_button_pressed() -> void:
	mc_installation.run(ProfileManager.get_player_name())


func _on_player_name_line_edit_text_changed(new_text: String) -> void:
	ProfileManager.set_player_name(new_text)


func _on_player_viewport_container_change_cape_request() -> void:
	cape_selector_window.popup_centered()


func _on_capes_selector_window_cape_selected(path: String) -> void:
	ProfileManager.set_cape(path)
	player_viewport_container.player.can_animate = true # spagetti code go brrr


func _on_skin_file_dialog_file_selected(path: String) -> void:
	ProfileManager.set_skin(path)
