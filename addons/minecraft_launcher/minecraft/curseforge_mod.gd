extends MCMod
class_name CFMod

const API := "https://api.curseforge.com"
const GET_MOD := "/v1/mods/%s/files/%s"

@export var modid: int
@export var fileid: int

func get_headers():
	return [
		"Accept: application/json",
		"x-api-key: %s" % GlobalFunctions.curseforge_api_key
	]

func get_file(downloader: Requests, mod_folder: String):
	DirAccess.make_dir_recursive_absolute(mod_folder)
	
	var url = API.path_join(GET_MOD) % [modid, fileid]
	var file_data = (await downloader.do_get(url, "", get_headers())).json()
	var mod_name = file_data["data"]["displayName"]
	var mod_url = file_data["data"]["downloadUrl"]
	await downloader.do_file(mod_url, mod_folder.path_join("%s.jar" % mod_name))
	print("Mod %s downloaded" % mod_name)
