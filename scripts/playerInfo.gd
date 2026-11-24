extends RefCounted
class_name PlayerInfo

## Defined asset paths to all player icons
const ICONPATHS: Array[String] = [
	"res://assets/shared/players/lion.png",
	"res://assets/shared/players/wolf.png",
	"res://assets/shared/players/ram.png",
	"res://assets/shared/players/panther.png",
	"res://assets/shared/players/fox.png",
	"res://assets/shared/players/deer.png",
	"res://assets/shared/players/elephant.png",
	"res://assets/shared/players/otter.png",
	"res://assets/shared/players/rhino.png",
	"res://assets/shared/players/bear.png",
	"res://assets/shared/players/boar.png",
	"res://assets/shared/players/bat.png",
	"res://assets/shared/players/hare.png",
	"res://assets/shared/players/hippo.png",
	"res://assets/shared/players/koala.png",
	"res://assets/shared/players/lynx.png",
	"res://assets/shared/players/ox.png",
	"res://assets/shared/players/raccoon.png",
]

## Display the name of the player
static func displayName(playerID: int) -> String:
	return "Player %d" % (playerID + 1)

## Find player icon based on array index
static func iconAt(index: int) -> Texture2D:
	return load(ICONPATHS[index]) as Texture2D
