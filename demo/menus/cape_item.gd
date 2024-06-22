extends Control

signal cape_selected(texture: String)

@export var TWEEN_DURATION = 5.0

var cape_mat = preload("res://demo/assets/materials/cape.tres")

#var selected: bool = false : set = set_selected

#@export var cape_texture: Texture2D : set = set_cape_texture
@export var cape_path: String : set = set_cape_path

@onready var cape_mesh: MeshInstance3D = %Cape
@onready var color_rect: ColorRect = $ColorRect

@onready var current_mat: StandardMaterial3D

func _ready() -> void:
	current_mat = cape_mat.duplicate()
	cape_mesh.set_surface_override_material(0, current_mat)
	
	set_cape_path(cape_path)


func set_cape_path(value: String):
	cape_path = value
	if cape_mesh:
		var i = Image.load_from_file(value)
		var t = ImageTexture.create_from_image(i)
		current_mat.albedo_texture = t

func _gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("click_cape"):
		cape_selected.emit(cape_path)

func _on_mouse_entered() -> void:
	var t = create_tween()
	t.tween_property(color_rect, "color:a", 0.15, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)


func _on_mouse_exited() -> void:
	var t = create_tween()
	t.tween_property(color_rect, "color:a", 0.0, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)
