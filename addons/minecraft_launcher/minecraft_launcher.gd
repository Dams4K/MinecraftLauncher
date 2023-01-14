@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("MinecraftLauncher", "Node", preload("launcher.gd"), preload("icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("MinecraftLauncher")
