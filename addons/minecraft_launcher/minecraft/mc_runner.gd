extends Resource
class_name MCRunner

var java_path: String

var game_args: MCGameArgs

var tweaker: MCTweaker

func run():
	var args: Array = []
	args.append_array(tweaker.get_jvm())
	args.append(tweaker.get_main_class())
	args.append_array(game_args.to_array())
	
	if OS.is_debug_build():
		var file = FileAccess.open("user://cmd.txt", FileAccess.WRITE)
		file.store_string("%s %s" % [java_path, " ".join(args)])
		file.close()
	
	if Utils.get_os_type() == Utils.OS_TYPE.WINDOWS:
		#var run_file = "user://run.ps1" # Powershell file format which allow more than 8192 char
		var run_file = "user://run.bat"
		var file = FileAccess.open(run_file, FileAccess.WRITE)
		file.store_string("%s %s" % [java_path, " ".join(args)])
		file.close()
		
		#var shell = "powershell.exe"
		#var w_args = ["-Command", ProjectSettings.globalize_path(run_file)]
		
		var shell = "CMD.exe"
		var w_args = ["/C", ProjectSettings.globalize_path(run_file)]
		
		# Allow ps1 to be run by powershell
		#OS.create_process(shell, ["-Command", "Set-ExecutionPolicy", "Unrestricted", "-Scope", "CurrentUser", "-Force"])
		OS.create_process(shell, w_args)
	else:
		var run_file = "user://run.sh"
		var file = FileAccess.open(run_file, FileAccess.WRITE)
		file.store_string("cd %s && %s %s" % [ProjectSettings.globalize_path("user://"), java_path, " ".join(args)])
		file.close()
		OS.create_process(ProjectSettings.globalize_path(run_file), [])
