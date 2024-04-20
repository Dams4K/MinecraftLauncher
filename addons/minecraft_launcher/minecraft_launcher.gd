@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("MinecraftLauncher", "Node", preload("launcher.gd"), preload("icon.svg"))
	add_custom_type("MCInstallation", "Node", preload("res://addons/minecraft_launcher/minecraft/mc_installation.gd"), preload("res://addons/minecraft_launcher/icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("MinecraftLauncher")
	remove_custom_type("MCInstallation")
