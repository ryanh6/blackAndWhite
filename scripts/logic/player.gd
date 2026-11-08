extends RefCounted
class_name Player

var hand: Array = []
var wins: int = 0
var blackTilesRemaining: int = 5
var whiteTilesRemaining: int = 4
var placedTile: int = -1
var placedColour: int = -1

func reset(knownHand: bool) -> void:
	hand.clear()
	
	if knownHand:
		for tile in 9:
			hand.append(tile)
	
	wins = 0
	blackTilesRemaining = 5
	whiteTilesRemaining = 4
	clearPlacement()

func clearPlacement() -> void:
	placedTile = -1
	placedColour = -1

func placeTile(tile: int, colour: int) -> void:
	placedColour = colour
	
	if colour == 0:
		blackTilesRemaining -= 1
	else:
		whiteTilesRemaining -= 1
	
	if tile >= 0:
		hand.erase(tile)
		placedTile = tile
