@tool
extends ProgressBar

@export var text := "{value}%":
	set(v):
		text = v
		if is_inside_tree() and label != null:
			_on_value_changed(value)

@onready var label: Label = $Label

func _on_value_changed(new_value: float) -> void:
	var percentage = int(new_value/max_value*100)
	label.text = text.format({"value": percentage})
