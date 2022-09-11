extends Node

const CHUNK_SIZE = 1024
func check_sha1(file_path: String, sha1: String, context: int = HashingContext.HASH_SHA1):
	var ctx = HashingContext.new()
	ctx.start(context)
	
	var file = File.new()
	file.open(file_path, File.READ)
	
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	
	var res = ctx.finish()
	return res.hex_encode() == sha1
