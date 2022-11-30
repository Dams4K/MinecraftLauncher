extends Node3D

var MATERIAL_FIX = load("res://demo/assets/blender/material_fix.tres")

@export var slim: bool = false:
	set(v):
		slim = v
		update_slim()

@export var texture: Texture

@onready var arms = [$ArmL, $ArmR, $ArmLLayer, $ArmRLayer]
@onready var arms_s = [$ArmSL, $ArmSR, $ArmSLLayer, $ArmSRLayer]


func _ready() -> void:
	MATERIAL_FIX.set("albedo_texture", texture)
	for child in get_children():
		child.set("surface_material_override/0", MATERIAL_FIX)
	
	update_slim()

func update_slim():
	if arms == null or arms_s == null: return
	
	if slim:
		for arm in arms:
			arm.visible = false
		for arm_s in arms_s:
			arm_s.visible  = true
	else:
		for arm_s in arms_s:
			if arm_s == null: continue
			arm_s.visible = false
		for arm in arms:
			arm.visible = true
