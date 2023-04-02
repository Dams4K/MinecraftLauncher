extends Control

const base_backgrounds_path = "res://demo/assets/textures/backgrounds/"

@onready var canvas_background: CanvasLayer = $CanvasBackground

@onready var play_container: VBoxContainer = %PlayContainer
@onready var accounts_container: VBoxContainer = %AccountsContainer

@onready var mc_installation: MCInstallation = $MCInstallation

@onready var loading_panel: Panel = %LoadingPanel
@onready var loading_bar: ProgressBar = %LoadingBar
@onready var informative_labels: HBoxContainer = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels

@onready var assets_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/AssetsLabel
@onready var natives_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/NativesLabel
@onready var libraries_label: Label = $CenterContainer/VBoxContainer/LoadingPanel/VBoxContainer/InformativeLabels/LibrariesLabel

func _ready() -> void:
	loading_bar.value = 0
	loading_panel.modulate.a = 0.0;
	loading_panel.material.set("shader_parameter/y_pos", -4.0 - loading_panel.custom_minimum_size.y)
	
	if !Engine.is_editor_hint():
		canvas_background.change_background()
		
		play_container.visible = true
		accounts_container.visible = false

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
	
#	var thread = Thread.new()
#	thread.start(mc_installation.run)
	mc_installation.run()


func _on_minecraft_launcher_launching() -> void:
	loading_bar.text = "Launching..."


func _on_mc_installation_assets_downloaded() -> void:
	assets_label.theme_type_variation = "LabelSuccess"


func _on_mc_installation_libraries_downloaded() -> void:
	libraries_label.theme_type_variation = "LabelSuccess"


func _on_mc_installation_natives_downloaded() -> void:
	natives_label.theme_type_variation = "LabelSuccess"


func _on_mc_installation_new_file_downloaded(files_downloaded, files_to_download) -> void:
	loading_bar.max_value = files_to_download
	loading_bar.value = files_downloaded
