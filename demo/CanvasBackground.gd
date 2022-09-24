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
@export_range(0, 100, 0.01) var transition_time: float = 10.0:
	set(v):
		transition_time = v
		if transition_timer != null:
			transition_timer.wait_time = v
			if !transition_timer.is_stopped() && v == 0:
				transition_timer.stop()


@onready var control: Control = $Control
@onready var blur_effect: ColorRect = %BlurEffect
@onready var transition_timer: Timer = $Timer

@onready var background_texture: TextureRect = %BackgroundTexture
@onready var transition_texture: TextureRect = %TransitionTexture


var transition_tween = null

func _ready() -> void:
	randomize()
	background_texture.texture = null
	transition_texture.texture = null
	update_blur_effect()
	
	if transition_time > 0:
		transition_timer.wait_time = transition_time
		transition_timer.start()

func update_blur_effect():
	blur_effect.material.set("shader_parameter/blur_amount", blur_amount)

func change_background():
	if len(backgrounds) == 0 || background_texture == null: return
	
	backgrounds.shuffle()
	background_texture.texture = backgrounds[0]


func _on_timer_timeout() -> void:
	transition_texture.modulate.a = 1.
	transition_texture.texture = background_texture.texture
	change_background()
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transition_texture, "modulate", Color(1.,1.,1.,0.), 1)
	transition_tween.play()
