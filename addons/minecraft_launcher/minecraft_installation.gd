extends Resource
class_name MinecraftInstallation

@export_global_file("*.json") var version_file
@export_global_dir var game_folder


func get_data():
	var file = FileAccess.open(version_file, FileAccess.READ)
	if file.get_error() != OK:
		print("error opening version_file")
		return
	
	var content = file.get_as_text()
	return JSON.parse_string(content)


func get_minecraft_assets():
	var version_data = get_data()
	return MinecraftAssets.new(version_data["assetIndex"])

func get_minecraft_libraries():
	var version_data = get_data()
	return MinecraftLibraries.new(version_data["libraries"])

func run(minecraft_libraries: MinecraftLibraries, minecraft_assets: MinecraftAssets):
	var libs_abs_path: Array[String] = []
	for lib in minecraft_libraries.get_libs(minecraft_libraries.LibrariesType.LIBRARIES):
		libs_abs_path.append(ProjectSettings.globalize_path(minecraft_libraries.LIBRARIES_PATH.path_join(lib.get("path", ""))))
	libs_abs_path.append("/home/damien/.local/share/godot/app_userdata/MinecraftLauncher/versions/1.8.9/1.8.9.jar")
	var args: Array[String] = [
		"-Djava.library.path=%s" % ProjectSettings.globalize_path(minecraft_libraries.NATIVES_PATH),
		"-Dminecraft.launcher.brand=%s" % "GodotLauncher",
		"-Dminecraft.launcher.version=%s" % ProjectSettings.get("application/config/version"),
		"-cp", ":".join(libs_abs_path),
		"-Xss%sM" % 1,
		"net.minecraft.client.main.Main",
		"--gameDir", ProjectSettings.globalize_path(game_folder),
		"--version", "1.8.9",
		"--username", "Dams4LT",
		"--uuid", "0",
		"--accessToken", "null",
		"--assetIndex", str(minecraft_assets.get_id()),
		"--assetsDir", ProjectSettings.globalize_path(minecraft_assets.ASSETS_FOLDER)
	]
	var output = []
	OS.execute("/usr/lib/jvm/jdk-8/bin/java", args, output, true, false)
	print(output)
#	print(args)
