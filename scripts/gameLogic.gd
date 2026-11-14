extends RefCounted
class_name GameLogic

## Tracks accepted command count, used to notice if a copy has fallen out of sync
var sequence: int = 0

## Identifies which player this game belongs to as players may have access to different information
## viewerID of -1 means access to all information
func setViewerID(playerID: int) -> void:
	pass

## When true, players apply events from host instead of replaying commands
## Method is used when players have hidden information from each other
func useEventSync() -> bool:
	return false

## List of events that given player can see
## Used when players must hide information from each other
func eventForPlayer(events: Array, playerID: int) -> Array:
	return events

## Update this copy of the game from events of the host game
## Useed when must hide information, allowing secret-free copies
func applyEvents(events: Array) -> void:
	pass

## A save containing what given player is allowed to know
func snapshotForPlayer(playerID: int) -> Dictionary:
	return toDictionary()

#static func createSettingsSchema() -> SettingsSchema:
	#return SettingsSchema.new()

## matchSeed enables randomness in match (Dice Rolls, Coin Toss, etc.)
## matchSeed is shared so that all players get the same "random" results
#func startMatch(chosenSettings: GameSettings, matchSeed: int) -> Array:
	#return []

func validate(command: Dictionary, actionID: int) -> String:
	return "NOT IMPLEMENTED"

func execute(command: Dictionary) -> Array:
	return []

func toDictionary() -> Dictionary:
	return {}

func fromDictionary(data: Dictionary) -> void:
	pass
