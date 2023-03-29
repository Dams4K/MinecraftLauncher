extends Node
class_name MinecraftVersions

const VERSION_MANIFEST_V2_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

static func get_version_file(downloader: Requests, version_id):
	var versions = (await downloader.do_get(VERSION_MANIFEST_V2_URL)).json()
	
	for v in versions["versions"]:
		if v["id"] == version_id:
			return (await downloader.do_get(v["url"])).json()
