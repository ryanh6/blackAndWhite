extends RefCounted
class_name TileArt

## Defining asset path
const DIRECTORY = "res://games/blackAndWhite/assets/tiles/"
const ASPECT: float = 0.7474

## Stores textures by filename for reusability
static var cache: Dictionary = {}

## Retrieves the face up texture for a given tile
static func face(number: int) -> Texture2D:
	return load("tile%d.png" % number)

## Retrieves the face down texture for a given colour
static func hidden(colour: StringName) -> Texture2D:
	return load("tileHidden%s.png" % String(colour))

## Load the texture from cache
static func load(fileName: String) -> Texture2D:
	if not cache.has(fileName):
		var path := DIRECTORY + fileName
		
		if ResourceLoader.exists(path):
			cache[fileName] = load(path) as Texture2D
		else:
			null
			
	return cache[fileName]
