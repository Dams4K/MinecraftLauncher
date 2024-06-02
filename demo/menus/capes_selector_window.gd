extends Window

signal cape_selected(path: String)

@export var CAPE_ITEM: PackedScene
const CAPES_FOLDER = "user://capes"

var internal_capes_folder = "res://demo/assets/textures/capes/"

@onready var capes_selector_menu: ScrollContainer = $CapesSelectorMenu
@onready var grid_container: GridContainer = %GridContainer
@onready var file_dialog: FileDialog = $CapesSelectorMenu/FileDialog

func _ready() -> void:
	hide()
	
	update_grid()

func update_grid():
	var dir = DirAccess.open(CAPES_FOLDER)
	if CAPE_ITEM and dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "png":
				add_cape(CAPES_FOLDER.path_join(file_name))
			file_name = dir.get_next()

func _process(delta: float) -> void:
	var viewport_size = capes_selector_menu.get_viewport_rect().size
	var columns = int((viewport_size.x - capes_selector_menu.offset_left + capes_selector_menu.offset_right) / (128.0 + 4.0)) # 128.0 size of items | 4.0 size of space between items
	grid_container.columns = columns

func add_cape(texture_path: String):
	var texture_name: String = texture_path.get_file().replace(".", "")
	
	if grid_container.get_node_or_null(texture_name) != null:
		return
	
	var cape_item = CAPE_ITEM.instantiate()
	cape_item.name = texture_name
	cape_item.cape_path = texture_path
	cape_item.cape_selected.connect(_on_cape_selected)
	grid_container.add_child(cape_item)
	grid_container.move_child(cape_item, 0) # place items before AddCape

func _on_cape_selected(path: String):
	cape_selected.emit(path)
	hide()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		hide()


func _on_add_cape_add_cape_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	cape_selected.emit(path)
	DirAccess.copy_absolute(path, CAPES_FOLDER.path_join(path.get_file()))
	update_grid()
	hide()
