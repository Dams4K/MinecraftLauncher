extends Resource
class_name MCProfile

const FILE_PATH = "user://profile.tres"
const UNKOWN_SKIN = preload("res://demo/assets/textures/skins/unkown.png")

@export var player_name: String = ""
@export var skin_path: String = ""
@export var cape_path: String = ""

var minecraft_folder: String = "" : set = set_minecraft_folder

var MOD_SKINS_FOLDER = minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/skins/%s.png")
var MOD_CAPES_FOLDER = minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/capes/%s.png")
var CAPES_ASSETS_FOLDER = "user://capes"

static func load_profile(mc_folder):
	if FileAccess.file_exists(FILE_PATH):
		var r = ResourceLoader.load(FILE_PATH)
		if r != null:
			return r.set_minecraft_folder(mc_folder)
	return MCProfile.new().set_minecraft_folder(mc_folder)
func save_profile():
	ResourceSaver.save(self, FILE_PATH)


func set_cape_path(path: String):
	if not FileAccess.file_exists(path):
		return
	
	var image = Image.load_from_file(path)
	if image.get_size() != Vector2i(64, 32):
		return
	
	cape_path = CAPES_ASSETS_FOLDER.path_join(path.get_file())
	image.save_png(cape_path)
	image.save_png(MOD_CAPES_FOLDER % player_name)
	save_profile()


func set_skin_path(path: String):
	if not FileAccess.file_exists(path):
		return
	
	var image = Image.load_from_file(path)
	if image.get_size() != Vector2i(64, 64):
		return
	
	skin_path = MOD_SKINS_FOLDER % player_name
	image.save_png(skin_path)
	save_profile()

func set_minecraft_folder(path: String):
	minecraft_folder = path
	MOD_SKINS_FOLDER = minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/skins/%s.png")
	MOD_CAPES_FOLDER = minecraft_folder.path_join("/CustomSkinLoader/LocalSkin/capes/%s.png")
	return self

func get_skin_texture() -> Texture2D:
	if FileAccess.file_exists(MOD_SKINS_FOLDER % player_name):
		var image = Image.load_from_file(MOD_SKINS_FOLDER % player_name)
		var texture = ImageTexture.create_from_image(image)
		return texture
	return UNKOWN_SKIN

func get_cape_texture() -> Texture2D:
	if FileAccess.file_exists(cape_path):
		var image = Image.load_from_file(cape_path)
		var texture = ImageTexture.create_from_image(image)
		return texture
	return null
