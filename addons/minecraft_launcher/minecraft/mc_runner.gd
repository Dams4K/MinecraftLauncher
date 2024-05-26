extends Resource
class_name MCRunner

var java_path: String

var jvm_args: MCJVMArgs
var game_args: MCGameArgs
var main_class: String

func run():
	var args: Array = []
	args.append_array(jvm_args.to_array())
	args.append(main_class)
	args.append_array(game_args.to_array())
	
	if OS.is_debug_build():
		var file = FileAccess.open("cmd.txt", FileAccess.WRITE)
		file.store_string("%s %s" % [java_path, " ".join(args)])
		file.close()
	
	OS.create_process(java_path, args)
