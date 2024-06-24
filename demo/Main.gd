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
	modulate.a = 0.0
	
	player_name_line_edit.text = ProfileManager.get_player_name()
	mc_installation.install_overrides()

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
