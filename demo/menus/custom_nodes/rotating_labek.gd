extends Label
class_name RotatingLabel

@export var args: Array[Variant]

@onready var base_text = text

func _process(delta: float) -> void:
	text = base_text % args
	pivot_offset = size / 2
