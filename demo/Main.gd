extends Control

var player_mat: StandardMaterial3D = preload("res://demo/assets/materials/player_godot.tres")

@onready var mc_installation: MCInstallation = $MCInstallation

@onready var file_dialog: FileDialog = $FileDialog


func _on_button_pressed() -> void:
	file_dialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	var t = ImageTexture.create_from_image(image)
	player_mat.albedo_texture = t
