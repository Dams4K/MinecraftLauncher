@tool
extends CanvasLayer

@export var backgrounds: Array[Texture2D]
@export var blur_amount: float = 0:
	set(v):
		blur_amount = v
		if blur_effect != null:
			update_blur_effect()
@export var debug_change_background: bool:
	set(v):
		change_background()

@onready var control: Control = $Control
@onready var texture_rect: TextureRect = %TextureRect
@onready var blur_effect: ColorRect = %BlurEffect

func _ready() -> void:
	randomize()
	texture_rect.texture = null
	update_blur_effect()

func update_blur_effect():
	blur_effect.material.set("shader_parameter/blur_amount", blur_amount)

func change_background():
	print("baaaackgrounds")
	if len(backgrounds) == 0 || texture_rect == null: return
	
	backgrounds.shuffle()
	texture_rect.texture = backgrounds[0]
