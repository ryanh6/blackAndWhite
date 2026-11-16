extends RefCounted
class_name TileArt

const DIRECTORY = "res://games/blackAndWhite/assets/tiles/"
const ASPECT: float = 0.7474

static var cache: Dictionary = {}

static func face(number: int) -> Texture2D:
	return load("tile%d.png" % number)

static func hidden(colour: StringName) -> Texture2D:
	return load("tileHidden%s.png" % String(colour))

static func load(fileName: String) -> Texture2D:
	if not cache.has(fileName):
		var path := DIRECTORY + fileName
		
		if ResourceLoader.exists(path):
			cache[fileName] = load(path) as Texture2D
		else:
			null
			
	return cache[fileName]
