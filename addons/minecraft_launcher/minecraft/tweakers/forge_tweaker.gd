extends MCTweaker
class_name ForgeTweaker


@export_placeholder("1.20.1-forge-47.2.32") var forge_version_name: String
## Available paths:[br]http://<path>.jar[br]https://<path>.jar[br]res://<path>.jar
@export_file("*.jar") var installer_path: String

var install_forge_thread = null

func setup(downloader: Requests, minecraft_folder: String, java_path: String):
	await install_forge(downloader, minecraft_folder, java_path)
	
	return await super.setup(downloader, minecraft_folder, java_path)

func get_complementary_version_data(downloader: Requests, version_id: StringName):
	#TODO: fix folders issues
	var path = "user://".path_join(MCInstallation.VERSIONS_FOLDER.path_join("%s/%s.json" % [forge_version_name, forge_version_name]))
	assert(FileAccess.file_exists(path), "File %s don't exist" % path)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	if err != OK:
		push_error("Error %s while parsing %s" % [err, path])
		
	return json.data

func get_jvm() -> Array:
	client_jar_path = "" # forge don't need this, we must remove it
	var args = super.get_jvm()
	for arg in complementary_data["arguments"]["jvm"]:
		var value = format_jvm_arg(arg)
		if value is String: # If value is in a correct format
			value = value.replace("${version_name}", get_forge_version_name().replace(".jar", ""))
			args.append(value)
	return args

func get_game_args():
	return complementary_data["arguments"]["game"]

func get_client_jar(downloader: Requests, versions_folder: String):
	#var path = ProjectSettings.globalize_path(versions_folder.path_join(get_forge_version_name()))
	#if version_jar.begins_with("http"):
		#await Utils.download_file(downloader, version_jar, path, "")
	#elif version_jar.begins_with("res://"):
		#var file = FileAccess.open(version_jar, FileAccess.READ)
		#var outside_file = FileAccess.open(path, FileAccess.WRITE)
		#outside_file.store_buffer(file.get_buffer(file.get_length()))
	return ""

func get_installer(downloader: Requests, minecraft_folder: String):
	var file_name: String = installer_path.get_file()
	var path = ProjectSettings.globalize_path(minecraft_folder.path_join("installers/%s" % file_name))
	if installer_path.begins_with("http"):
		await Utils.download_file(downloader, installer_path, path, "")
	elif installer_path.begins_with("res://"):
		var folder = path.get_base_dir()
		DirAccess.make_dir_recursive_absolute(folder)
		var dir := DirAccess.open("res://")
		dir.copy(installer_path, path)
		#var file = FileAccess.open(installer_path, FileAccess.READ)
		#var outside_file = FileAccess.open(path, FileAccess.WRITE)
		#outside_file.store_buffer(file.get_buffer(file.get_length()))
		#outside_file.close()
	return path

func install_forge(downloader: Requests, minecraft_folder: String, java_path: String):
	# Forge check if launcher_profiles.json exists to install itself..
	var fake_profile = FileAccess.open(minecraft_folder.path_join("launcher_profiles.json"), FileAccess.WRITE)
	fake_profile.store_string(JSON.stringify({}))
	
	var i_p = await get_installer(downloader, minecraft_folder)
	var installer_folder = i_p.get_base_dir()
	minecraft_folder = ProjectSettings.globalize_path(minecraft_folder)
	
	var install_check_file = "installed"
	
	if FileAccess.file_exists(installer_folder.path_join(install_check_file)):
		print_debug("Forge is already installed")
		return #Forge already installed
	
	var f = func (): real_forge_install(i_p, java_path, minecraft_folder, install_check_file)
	install_forge_thread = Thread.new()
	install_forge_thread.start(f)
	
func real_forge_install(i_p, java_path, minecraft_folder, install_check_file):
	var installer_folder = i_p.get_base_dir()
	if Utils.get_os_type() == Utils.OS_TYPE.LINUX:
		var install_forge_sh = installer_folder.path_join("install_forge.sh")
		var exc_file = FileAccess.open(install_forge_sh, FileAccess.WRITE)
		exc_file.store_string("cd $2\n$1 -jar $3 --installClient $2\ntouch %s" % installer_folder.get_basename().path_join(install_check_file))
		FileAccess.set_unix_permissions(install_forge_sh, 493)
		exc_file.close()
		
		var df = FileAccess.open(installer_folder.path_join("debug.txt"), FileAccess.WRITE)
		df.store_string("%s %s %s %s" % [install_forge_sh, java_path, minecraft_folder, i_p])
		df.close()
		
		await OS.execute(install_forge_sh, [java_path, minecraft_folder, i_p])
		
	elif Utils.get_os_type() == Utils.OS_TYPE.WINDOWS:
		#TODO: don't reinstall when it's already installed using "installed" file
		#TODO: same file for windows (no permissions required)
		
		await OS.execute(java_path, ["-jar", i_p, "--installClient", minecraft_folder])

func get_forge_version_name():
	return "%s_forge.jar" % minecraft_version

func get_main_class():
	return complementary_data["mainClass"]

func is_ready():
	return install_forge_thread == null or (not install_forge_thread.is_alive())
