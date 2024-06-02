extends Control

signal add_cape_pressed

@export var TWEEN_DURATION = 0.15

@onready var color_rect: ColorRect = $ColorRect

func _on_mouse_entered() -> void:
	var t = create_tween()
	t.tween_property(color_rect, "color:a", 0.15, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)


func _on_mouse_exited() -> void:
	var t = create_tween()
	t.tween_property(color_rect, "color:a", 0.0, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_released("click_cape"):
		add_cape_pressed.emit()
