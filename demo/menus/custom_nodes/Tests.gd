extends Control


func _on_double_slider_drag_started() -> void:
	print("drag started")


func _on_double_slider_drag_ended(value_changed) -> void:
	printt("drag ended", value_changed)


func _on_double_slider_max_cursor_value_changed(value) -> void:
	print("max:", value)


func _on_double_slider_min_cursor_value_changed(value) -> void:
	print("min:", value)
