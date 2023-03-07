extends Control

const base_backgrounds_path = "res://demo/assets/textures/backgrounds/"

@onready var canvas_background: CanvasLayer = $CanvasBackground

@onready var play_container: VBoxContainer = %PlayContainer
@onready var accounts_container: VBoxContainer = %AccountsContainer

@onready var minecraft_launcher: Launcher = $MinecraftLauncher

@onready var loading_panel: Panel = %LoadingPanel
@onready var loading_bar: ProgressBar = %LoadingBar
@onready var informative_labels: HBoxContainer = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels

@onready var assets_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/AssetsLabel
@onready var natives_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/NativesLabel
@onready var libraries_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/LibrariesLabel

func _ready() -> void:
	loading_panel.modulate.a = 0.0;
	loading_panel.material.set("shader_parameter/y_pos", -4.0 - loading_panel.custom_minimum_size.y)
	
	if !Engine.is_editor_hint():
		await load_backgrounds()
		canvas_background.change_background()
		
		play_container.visible = true
		accounts_container.visible = false


var has_already_tried = false
func load_backgrounds():
	canvas_background.backgrounds = [] as Array[Texture2D]

	var dir_path = ProjectSettings.get("Launcher/Paths/Backgrounds")
	var dir_local = DirAccess.open(dir_path)
	var dir_local_ok = DirAccess.get_open_error()
	var dir_perma = DirAccess.open(base_backgrounds_path)
	var dir_perma_ok = DirAccess.get_open_error()
	
	if dir_local_ok == OK:
		dir_local.list_dir_begin()
		var file_name = dir_local.get_next()
		while file_name != "":
			if !dir_local.current_is_dir():
				var image = Image.load_from_file(dir_path.path_join(file_name))
				var texture = ImageTexture.create_from_image(image)
				canvas_background.backgrounds.append(texture)
			file_name = dir_local.get_next()
	elif dir_perma_ok == OK && !has_already_tried:
		has_already_tried = true
		
		if DirAccess.make_dir_absolute(dir_path) == OK:
			dir_perma.list_dir_begin()
			var file_name = dir_perma.get_next()
			
			while file_name != "":
				if !dir_perma.current_is_dir() && file_name.get_extension() in ["jpg", "png", "jpeg"]:
					dir_perma.copy(base_backgrounds_path.path_join(file_name), dir_path.path_join(file_name))
				file_name = dir_perma.get_next()
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


func _on_play_button_pressed() -> void:
	for child in informative_labels.get_children():
		if child is Label:
			child.theme_type_variation = "LabelProcess"
	
	var tween = create_tween().set_parallel()
	tween.tween_property(loading_panel, "modulate:a", 1.0, .5)
	tween.tween_property(loading_panel.material, "shader_parameter/y_pos", 0.0, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.play()
	minecraft_launcher.launch()


func _on_minecraft_launcher_assets_downloaded() -> void:
	assets_label.theme_type_variation = "LabelSuccess"


func _on_minecraft_launcher_libraries_downloaded() -> void:
	libraries_label.theme_type_variation = "LabelSuccess"


func _on_minecraft_launcher_natives_downloaded() -> void:
	natives_label.theme_type_variation = "LabelSuccess"
