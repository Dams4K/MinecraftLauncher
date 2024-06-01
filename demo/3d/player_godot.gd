extends Node3D

signal change_cape_request

var cape_mat: StandardMaterial3D = preload("res://demo/assets/materials/cape.tres")

@onready var anchor: Node3D = $Anchor

@export var rotation_speed: float = 0.002
@export var can_animate: bool = true

var velocity_y: float = 0.0

@onready var cam: Camera3D = $Anchor/Camera3D
@onready var cape_collision: StaticBody3D = $cape/CapeCollision


func set_camera_rotation(angle: float):
	anchor.rotation.y = angle

func get_camera_rotation():
	return anchor.rotation.y

func _process(delta: float) -> void:
	if can_animate:
		anchor.rotation.y += rotation_speed

const RAY_LENGTH = 1000

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if cape_mat.albedo_texture:
		cape_mat.albedo_color.a = 1.0
		
		if result and result.collider == cape_collision:
			cape_mat.albedo_color.a = 0.95
			handle_cape_click()
	else:
		cape_mat.albedo_color.a = 0.05
	
		if result and result.collider == cape_collision:
			cape_mat.albedo_color.a = 0.1
			handle_cape_click()

func handle_cape_click():
	if Input.is_action_just_released("click_cape"):
		change_cape_request.emit()

func launch(velocity: float):
	pass
