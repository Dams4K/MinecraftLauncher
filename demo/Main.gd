extends Control

const base_backgrounds_path = "res://demo/assets/textures/backgrounds/"

@onready var canvas_background: CanvasLayer = $CanvasBackground

@onready var play_container: VBoxContainer = %PlayContainer
@onready var accounts_container: VBoxContainer = %AccountsContainer


func _ready() -> void:
	if !Engine.is_editor_hint():
		await load_backgrounds()
		canvas_background.change_background()
		
		play_container.visible = true
		accounts_container.visible = false


var has_already_tried = false
func load_backgrounds():
	canvas_background.backgrounds = []

	var dir = Directory.new()
	var dir_path = ProjectSettings.get("Launcher/Paths/Backgrounds")

	if dir.open(dir_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var image = Image.load_from_file(dir_path.path_join(file_name))
				var texture = ImageTexture.create_from_image(image)
				canvas_background.backgrounds.append(texture)
			file_name = dir.get_next()
	elif dir.open(base_backgrounds_path) == OK && !has_already_tried:
		has_already_tried = true
		dir.make_dir(dir_path)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.get_extension() in ["jpg", "png", "jpeg"]:
				dir.copy(base_backgrounds_path.path_join(file_name), dir_path.path_join(file_name))
			file_name = dir.get_next()
		load_backgrounds()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("debug_change_background"):
		canvas_background.change_background()


func _on_play_container__switch_to_accounts_container() -> void:
	play_container.visible = false
	accounts_container.visible = true


func _on_accounts_container__switch_to_play_container() -> void:
	play_container.visible = true
	accounts_container.visible = false
