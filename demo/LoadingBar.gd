@tool
extends ProgressBar

@export var text := "{value}%"

@onready var label: Label = $Label

func _on_value_changed(new_value: float) -> void:
	var percentage = int(new_value/max_value*100)
	label.text = text.format({"value": percentage})
