#@tool
extends Control

const base_backgrounds_path = "res://demo/assets/textures/backgrounds/"

@onready var canvas_background: CanvasLayer = $CanvasBackground
@onready var ram_label: Label = %RAMLabel
@onready var ram_slider: HSlider = %RamSlider
@onready var x_line_edit: LineEdit = %XLineEdit
@onready var y_line_edit: LineEdit = %YLineEdit

var has_already_tried = false

#-- CONFIG
func load_config():
	var config = ConfigFile.new()
	if config.load(ProjectSettings.get("Launcher/Paths/Config")) == OK:
		ram_slider.value = int(config.get_value("Global", "ram", 4))
		x_line_edit.text = str(config.get_value("Resolution", "x", ""))
		y_line_edit.text = str(config.get_value("Resolution", "y", ""))
func save_config():
	var config = ConfigFile.new()
	
	config.set_value("Global", "ram", int(ram_slider.value))
	config.set_value("Resolution", "x", str(x_line_edit.text))
	config.set_value("Resolution", "y", str(y_line_edit.text))
	
	config.save(ProjectSettings.get("Launcher/Paths/Config"))


func _ready() -> void:
	if !Engine.is_editor_hint():
		load_config()
		await load_backgrounds()
		canvas_background.change_background()
		
		ram_slider.max_value = OSInformation.get_total_system_memory().to_int() / 1024 / 1024 / 1024 + 1


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


#func _input(event: InputEvent) -> void:
#	if Engine.is_editor_hint(): return
#	if Input.is_action_just_pressed("debug_change_background"):
#		canvas_background.change_background()


func _on_minecraft_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_h_slider_value_changed(value: float) -> void:
	ram_label.text = str(value) + "Go"
	save_config()


func _on_resolution_line_edit_text_changed(new_text: String) -> void:
	print(new_text)
	save_config()
