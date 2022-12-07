@tool
class_name DoubleSlider
extends Control

signal drag_ended(value_changed: bool)
signal drag_started()
signal min_cursor_value_changed(value: float)
signal max_cursor_value_changed(value: float)

@export var normal_color: = Color("#b9b9b999")
@export var focus_color: = Color("#ffffffbf")

@export var min_value: float = 0: set = set_min_value
@export var max_value: float = 100: set = set_max_value
@export var step: float = 1
@export var min_cursor_value: float = min_value: set = set_min_cursor_value
@export var max_cursor_value: float = max_value: set = set_max_cursor_value

var _mouse_is_inside: bool = false
var _slider_is_moveable: bool = false

var _last_values: Array = []

@onready var min_cursor_panel: Panel = $MinCursorPanel
@onready var max_cursor_panel: Panel = $MaxCursorPanel

@onready var background_panel: Panel = $BackgroundPanel
@onready var foreground_panel: Panel = $ForegroundPanel
@onready var foreground_panel_style = foreground_panel.get("theme_override_styles/panel")

#-- BUILT-IN FUNCTIONS
func _ready() -> void:
	foreground_panel_style.bg_color = normal_color

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and _slider_is_moveable:
		if not _mouse_is_inside:
			_slider_is_moveable = false
		_end_dragging()
	
	if _slider_is_moveable:
		foreground_panel_style.bg_color = focus_color
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if _last_values.is_empty():
				_start_dragging()
				_last_values = [min_cursor_value, max_cursor_value]
			
			var mouse_position = get_local_mouse_position().x
			var value_selected = _position_to_value(mouse_position)
			var left_button_selected = mouse_position < (max_cursor_panel.position.x + min_cursor_panel.position.x) / 2
			
			if left_button_selected:
				set_min_cursor_value(value_selected)
			else:
				set_max_cursor_value(value_selected)
	else:
		foreground_panel_style.bg_color = normal_color


func _update_slider() -> void:
	set_min_cursor_value(min_cursor_value)
	set_max_cursor_value(max_cursor_value)
func _childs_exist() -> bool:
	return (
			foreground_panel != null and
			background_panel != null and
			min_cursor_panel != null and
			max_cursor_panel != null
	)  

func _start_dragging() -> void:
	_last_values == [min_cursor_value, max_cursor_value]
	emit_signal("drag_started")
func _end_dragging() -> void:
	var min_value_changed = _last_values[0] != min_cursor_value
	var max_value_changed = _last_values[1] != max_cursor_value
	emit_signal("drag_ended", min_value_changed or max_value_changed)
	_last_values.clear()
	
	if min_value_changed:
		emit_signal("min_cursor_value_changed", min_cursor_value)
	if max_value_changed:
		emit_signal("max_cursor_value_changed", max_cursor_value)

#-- CONVERTERS
func _position_to_value(pos: float) -> float:
	return get_slider_length() / (size.x / pos) + min_value
func _value_to_position(value: float) -> float:
	return (value-min_value) * (size.x / get_slider_length())

func _format_slider_value(value: float) -> float:
	var offset = (.5 * step)
	var formatted_value = value + offset - fmod(value + offset, step)
	if value < -step/2:
		formatted_value -= step
	return clamp(formatted_value, min_value, max_value)


#-- SETTERS & GETTERS
func set_min_cursor_value(new_value: float) -> void:
	min_cursor_value = _format_slider_value(new_value)
	move_min_cursor(min_cursor_value)
func set_max_cursor_value(new_value: float) -> void:
	max_cursor_value = _format_slider_value(new_value)
	move_max_cursor(max_cursor_value)

func set_min_value(new_value: float) -> void:
	min_value = new_value
	_update_slider()
func set_max_value(new_value: float) -> void:
	max_value = new_value
	_update_slider()


func get_slider_length() -> float:
	return max_value-min_value


#-- CURSORS MOVEMENT FUNCTIONS
func move_min_cursor(value: float) -> void:
	if is_inside_tree() and _childs_exist():
		await self.ready
	
	var pos = _value_to_position(value)
	min_cursor_panel.position.x = pos - min_cursor_panel.size.x/2
	foreground_panel.position.x = pos
	foreground_panel.size.x = max_cursor_panel.position.x - min_cursor_panel.position.x

func move_max_cursor(value: float) -> void:
	if not is_inside_tree() or not _childs_exist():
		await self.ready
	
	var pos = _value_to_position(value)
	max_cursor_panel.position.x = pos - min_cursor_panel.size.x/2
	foreground_panel.size.x = max_cursor_panel.position.x - min_cursor_panel.position.x


#-- SIGNALS FUNCTIONS
func _on_background_panel_mouse_entered() -> void:
	_mouse_is_inside = true
	_slider_is_moveable = true
func _on_background_panel_mouse_exited() -> void:
	_mouse_is_inside = false
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_slider_is_moveable = false
		if not _last_values.is_empty():
			_end_dragging()
func _on_resized() -> void:
#	_update_slider()
	pass
