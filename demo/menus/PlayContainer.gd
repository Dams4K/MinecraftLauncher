extends VBoxContainer

signal _switch_to_accounts_container

@onready var ram_label: Label = %RAMLabel
@onready var ram_slider: HSlider = %RamSlider
@onready var x_line_edit: LineEdit = %XLineEdit
@onready var y_line_edit: LineEdit = %YLineEdit

func _ready() -> void:
	ram_slider.max_value = OSInformation.get_total_system_memory().to_int() / 1024 / 1024 / 1024 + 1
	
	ram_slider.value = Config.ram
	ram_label.text = str(Config.ram) + "Go"
	
	x_line_edit.text = str(Config.x_resolution)
	y_line_edit.text = str(Config.y_resolution)


func _on_minecraft_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_ram_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ram_label.text = str(ram_slider.value) + "Go"
		Config.ram = ram_slider.value

func _on_resolution_line_edit_text_changed(new_text: String) -> void:
	Config.x_resolution = x_line_edit.text.to_int()
	Config.y_resolution = y_line_edit.text.to_int()


func _on_account_button_pressed() -> void:
	emit_signal("_switch_to_accounts_container")
