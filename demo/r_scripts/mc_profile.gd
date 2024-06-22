extends Resource
class_name MCProfile

const FILE_PATH = "user://profile.tres"
const UNKOWN_SKIN = preload("res://demo/assets/textures/skins/unkown.png")

@export var player_name: String = ""
@export var skin_path: String = ""
@export var cape_path: String = ""

var minecraft_folder: String = "" : set = set_minecraft_folder

var MOD_SKINS_FOLDER = minecraft_folder.path_join("CustomSkinLoader/LocalSkin/skins/%s.png")
var MOD_CAPES_FOLDER = minecraft_folder.path_join("CustomSkinLoader/LocalSkin/capes/%s.png")
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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cape_path.get_base_dir()))
	image.save_png(cape_path)
	var p = MOD_CAPES_FOLDER % player_name
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(p.get_base_dir()))
	image.save_png(p)
	save_profile()


func set_skin_path(path: String):
	if not FileAccess.file_exists(path):
		return
	
	var image = Image.load_from_file(path)
	if image.get_size() == Vector2i(64, 32):
		#image.resize_to_po2()
		var im2 = Image.create(64, 64, image.has_mipmaps(), image.get_format())
		
		copy_pixels(Rect2i(0, 0, 64, 32), Vector2i(0, 0), image, im2)
		copy_pixels(Rect2i(0, 16, 16, 16), Vector2i(16, 48), image, im2)
		copy_pixels(Rect2i(40, 16, 16, 16), Vector2i(32, 48), image, im2)
		
		image = im2
	
	if image.get_size() != Vector2i(64, 64):
		return
	
	skin_path = MOD_SKINS_FOLDER % player_name
	image.save_png(skin_path)
	save_profile()

func copy_pixels(dim: Rect2i, top_left: Vector2i, from: Image, to: Image):
	for y in range(dim.size.y):
		for x in range(dim.size.x):
			to.set_pixel(top_left.x + x, top_left.y + y, from.get_pixel(dim.position.x + x, dim.position.y + y))

func set_minecraft_folder(path: String):
	minecraft_folder = path
	MOD_SKINS_FOLDER = minecraft_folder.path_join("CustomSkinLoader/LocalSkin/skins/%s.png")
	MOD_CAPES_FOLDER = minecraft_folder.path_join("CustomSkinLoader/LocalSkin/capes/%s.png")
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
