extends VBoxContainer

signal _switch_to_accounts_container
signal _play_button_pressed

@onready var ram_label: Label = %RAMLabel
@onready var ram_slider: HSlider = %RamSlider
@onready var x_line_edit: LineEdit = %XLineEdit
@onready var y_line_edit: LineEdit = %YLineEdit

func _ready() -> void:
	#TODO: recreate get_total_system_memory
	#ram_slider.max_value = ceil(OS.get_total_system_memory() / 1024.0 / 1024.0 / 1024.0)
	
	ram_slider.value = Config.max_ram
	ram_label.text = str(Config.max_ram) + "Go"
	
	x_line_edit.text = str(Config.x_resolution)
	y_line_edit.text = str(Config.y_resolution)


func _on_minecraft_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_resolution_line_edit_text_changed(new_text: String) -> void:
	Config.x_resolution = x_line_edit.text.to_int()
	Config.y_resolution = y_line_edit.text.to_int()


func _on_account_button_pressed() -> void:
	emit_signal("_switch_to_accounts_container")


func _on_ram_slider_value_changed(value: float) -> void:
	ram_label.text = str(value) + "Go"


func _on_ram_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Config.max_ram = ram_slider.value


func _on_play_button_pressed() -> void:
	print("play")
	emit_signal("_play_button_pressed")
