extends Node

var config = ConfigFile.new()


var ram: int = 2:
	set(v):
		ram = v
		save_cfg()
var x_resolution: int = -1:
	set(v):
		x_resolution = v
		save_cfg()
var y_resolution: int = -1:
	set(v):
		y_resolution = v
		save_cfg()

func load_cfg():
	var config = ConfigFile.new()
	if config.load(ProjectSettings.get("Launcher/Paths/Config")) == OK:
		ram = config.get_value("Global", "ram", ram)
		
		x_resolution = config.get_value("Resolution", "x", x_resolution)
		y_resolution = config.get_value("Resolution", "y", y_resolution)

func save_cfg():
	config.set_value("Global", "ram", ram)
	config.set_value("Resolution", "x", x_resolution)
	config.set_value("Resolution", "y", y_resolution)
	
	config.save(ProjectSettings.get("Launcher/Paths/Config"))



func _ready() -> void:
	load_cfg()
