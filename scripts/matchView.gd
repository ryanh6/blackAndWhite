extends RefCounted
class_name MatchView

const BACKGROUNDDIR := "res://assets/backgrounds/"
const BACKGROUNDS : Array[String] = [
	"canalBackground", "castleBackground", "lighthouseBackground", "lighthouseBackground", "suspensionBridgeBackground", "trainStationBackground",
]

var backgroundIndex: int = 0
var iconOrder: Array[int] = []

func init(matchSeed: int = 0) -> void:
	var randomNumber := RandomNumberGenerator.new()
	randomNumber.seed = hash([matchSeed, "MatchView"])
	backgroundIndex = randomNumber.randi_range(0, BACKGROUNDS.size() - 1)
	iconOrder.clear()
	
	for index in PlayerInfo.ICONPATHS.size():
		iconOrder.append(index)
		
	for i in range(iconOrder.size() - 1, 0, -1):
		var j := randomNumber.randi_range(0, i)
		
		var swap := iconOrder[i]
		iconOrder[i] = iconOrder[j]
		iconOrder[j] = swap
		
func background() -> Texture2D:
	return load("%s%s.png" % [BACKGROUNDDIR, BACKGROUNDS[backgroundIndex]]) as Texture2D

func icon(playerID: int) -> Texture2D:
	return PlayerInfo.iconAt(iconOrder[playerID])
