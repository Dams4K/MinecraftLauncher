extends VBoxContainer

signal _switch_to_play_container


func _on_back_button_pressed() -> void:
	emit_signal("_switch_to_play_container")
