extends RefCounted
class_name BlackAndWhitePlayer

var hand: Array = []
var wins: int = 0
var blackTilesRemaining: int = 5
var whiteTilesRemaining: int = 4
var placedTile: int = -1
var placedColour: StringName = &""

func reset(knowHand: bool) -> void:
	hand.clear()
	
	if knowHand:
		for tile in 9:
			hand.append(tile)
	
	wins = 0
	blackTilesRemaining = 5
	whiteTilesRemaining = 4
	clearPlacement()

func clearPlacement() -> void:
	placedTile = -1
	placedColour = &""

func placeTile(tile: int, colour: StringName) -> void:
	placedColour = colour
	
	if colour == &"Black":
		blackTilesRemaining -= 1
	else:
		whiteTilesRemaining -= 1
	
	if tile >= 0:
		hand.erase(tile)
		placedTile = tile
