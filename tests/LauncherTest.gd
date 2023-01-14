extends Node

@export var installation: MinecraftInstallation = MinecraftInstallation.new()

@onready var downloader: HTTPRequest = $Downloader

func _ready() -> void:
	var assets: MinecraftAssets = installation.get_minecraft_assets()
	print("start downloading")
	await assets.download_assets(downloader)
	print("download finished")
