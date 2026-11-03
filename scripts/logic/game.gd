extends Node
class_name Game

enum gamePhase {
	SELECTING,
	ENDROUND,
	ENDGAME
}

signal changed
signal finishRound(winnerID: int)
signal finishMatch(winnerID: int)

var playerList: Array[Player] = [Player.new(0), Player.new(1)]
var phase: gamePhase = gamePhase.SELECTING
