extends Control

var player_mat: StandardMaterial3D = preload("res://demo/assets/materials/player_godot.tres")

@onready var mc_installation: MCInstallation = $MCInstallation

@onready var file_dialog: FileDialog = $FileDialog

@onready var player_name_line_edit: LineEdit = $CenterContainer/PanelContainer/HBoxContainer/PlayContainer/Control/VBoxContainer/PlayerNameLineEdit

var profile: MCProfile = MCProfile.load_profile()
@onready var skin_path = mc_installation.minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/skins/%s.png")

func _ready() -> void:
	player_name_line_edit.text = profile.player_name
	load_local_skin(profile.player_name)

func load_local_skin(player_name):
	var path = skin_path % player_name
	if not FileAccess.file_exists(path):
		return
	
	var image = Image.new()
	image.load(path)
	var t = ImageTexture.create_from_image(image)
	player_mat.albedo_texture = t

func get_playername():
	var username = player_name_line_edit.text
	if username == "":
		username = "ANobody"
	return username

func _on_button_pressed() -> void:
	file_dialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	DirAccess.copy_absolute(path, ProjectSettings.globalize_path(skin_path % get_playername()))
	load_local_skin(get_playername())


func _on_play_button_pressed() -> void:
	mc_installation.run(get_playername())


func _on_player_name_line_edit_text_changed(new_text: String) -> void:
	profile.player_name = new_text
	profile.save_profile()
	load_local_skin(profile.player_name)
