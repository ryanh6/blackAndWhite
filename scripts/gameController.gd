extends Node
class_name GameController

signal matchStarted
signal eventsReceived(events: Array)
signal stateReplaced
signal connectionLost
signal rosterChanged(connected: int, target: int)
signal summaryContinueReceived(serial: int)

#var descriptor: GameDescriptor
var logic: GameLogic
var localPlayerID: int = -1
var playerCount: int = 2
var matchSeed: int = 0
var look: MatchBackground = MatchBackground.new()

func startMatch(settings: GameSettings) -> void:
	pass
	
func submit(command: Dictionary) -> void:
	pass
	
func isOnline() -> bool:
	return false
	
func setReady(isReady: bool) -> void:
	pass

func canContinueSummary() -> bool:
	return true
	
func announceSummaryContinue(serial: int) -> void:
	pass

func shutdown() -> void:
	pass
