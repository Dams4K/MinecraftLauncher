extends Resource
class_name MCJVMArgs

@export var natives_directory: String
@export var launcher_name: String
@export var launcher_version: String
@export var libraries_path: Array[String]
@export var xmx: String = "2G"

var complementaries: Array = []

func to_array() -> Array:
	var array: Array = complementaries.duplicate()
	
	array.append("-Djava.library.path=%s" % natives_directory)
	array.append("-Dminecraft.launcher.brand=%s" % launcher_name)
	array.append("-Dminecraft.launcher.version=%s" % launcher_version)
	array.append("-Xmx%s" % xmx)
	
	var separator: String = ":"
	if Utils.get_os_type() == Utils.OS_TYPE.WINDOWS:
		separator = ";"
	array.append_array(["-cp", separator.join(libraries_path)])
	
	return array
