@tool
extends HBoxContainer

@export var selected: bool = false:
	set(v):
		selected = v
		if select_button != null:
			update_selected()

@onready var icon_button: Button = %IconButton
@onready var select_button: Button = %SelectButton
@onready var edit_button: Button = %EditButton


func _ready() -> void:
	_on_account_button_resized()
	update_selected()


func _on_account_button_resized() -> void:
	if icon_button != null && icon_button.icon != null:
		icon_button.custom_minimum_size = Vector2(icon_button.icon.get_size().x * size.y / icon_button.icon.get_size().y, size.y)
		edit_button.custom_minimum_size = icon_button.custom_minimum_size


func update_selected():
	select_button.theme_type_variation = "ButtonSelected" if selected else ""
