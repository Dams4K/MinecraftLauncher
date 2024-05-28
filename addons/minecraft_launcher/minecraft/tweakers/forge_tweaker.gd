extends MCTweaker
class_name ForgeTweaker


@export_placeholder("1.20.1-forge-47.2.32") var forge_version_name: String
## Available paths:[br]http://<path>.jar[br]https://<path>.jar[br]res://<path>.jar
@export_file("*.jar") var installer_path: String


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

func get_jvm(library_folder: String) -> Array:
	var args = complementary_data["arguments"]["jvm"]
	for i in range(len(args)):
		args[i] = args[i].replace("${library_directory}", ProjectSettings.globalize_path(library_folder))
		args[i] = args[i].replace("${classpath_separator}", ":") #TODO: ";" on windows
		args[i] = args[i].replace("${version_name}", get_forge_version_name().replace(".jar", ""))
	
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
		var dir = DirAccess.make_dir_recursive_absolute(folder)
		
		var file = FileAccess.open(installer_path, FileAccess.READ)
		var outside_file = FileAccess.open(path, FileAccess.WRITE)
		outside_file.store_buffer(file.get_buffer(file.get_length()))
		outside_file.close()
	return path

func install_forge(downloader: Requests, minecraft_folder: String, java_path: String):
	# Forge check if launcher_profiles.json exists to install itself..
	var fake_profile = FileAccess.open(minecraft_folder.path_join("launcher_profiles.json"), FileAccess.WRITE)
	fake_profile.store_string(JSON.stringify({}))
	
	var installer_path = await get_installer(downloader, minecraft_folder)
	minecraft_folder = ProjectSettings.globalize_path(minecraft_folder)
	
	var outputs = []
	#TODO: don't reinstall when it's already installed
	#TODO: same file for windows (not permissions required)
	var install_forge_sh = installer_path.get_base_dir().path_join("install_forge.sh")
	var exc_file = FileAccess.open(install_forge_sh, FileAccess.WRITE)
	exc_file.store_string("cd $2\n$1 -jar $3 --installClient $2")
	FileAccess.set_unix_permissions(install_forge_sh, 493)
	exc_file.close()
	
	print("%s %s %s %s" % [install_forge_sh, java_path, minecraft_folder, installer_path])
	await OS.execute(install_forge_sh, [java_path, minecraft_folder, installer_path])

func get_forge_version_name():
	return "%s_forge.jar" % minecraft_version

func get_main_class():
	return complementary_data["mainClass"]
