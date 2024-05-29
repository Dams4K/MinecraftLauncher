extends Node3D

@onready var anchor: Node3D = $Anchor

@export var rotation_speed: float = 0.002
@export var can_animate: bool = true

var velocity_y: float = 0.0

func set_camera_rotation(angle: float):
	anchor.rotation.y = angle

func get_camera_rotation():
	return anchor.rotation.y

func _process(delta: float) -> void:
	if can_animate:
		anchor.rotation.y += rotation_speed

func launch(velocity: float):
	pass
