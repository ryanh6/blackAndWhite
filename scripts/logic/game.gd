extends Node
class_name BlackWhiteGame

enum gamePhase {
	PLACING,
	ENDROUND,
	ENDGAME
}

#signal changed
#signal finishRound(winnerID: int)
#signal finishMatch(winnerID: int)

const TILECOUNT: int = 9
const NOTILE: int = -1
const NOTOVER: int = -2

var playerList: Array[Player] = [Player.new(), Player.new()]
var randomNumber: RandomNumberGenerator = RandomNumberGenerator.new()
var viewerID: int = -1

var phase: gamePhase = gamePhase.PLACING
var roundNumber: int = 0
var currentPlayerID: int = 0
var secondPlayerID: int = 1

var wins: Array: 
	get:
		return [playerList[0].wins, playerList[1].wins]
var ties: int = 0

var previousWinnerID: int = -1
var matchWinnerID: int = -1

# Getter Functions
var getHands: Array:
	get:
		return [playerList[0].hand, playerList[1].hand]
var getPlacedTiles: Array:
	get:
		return [playerList[0].placedTile, playerList[1].placedTile]

var getBlackTilesRemaining: Array:
	get:
		return [playerList[0].blackTilesRemaining, playerList[1].blackTilesRemaining]

var getWhiteTilesRemaining: Array:
	get:
		return [playerList[0].whiteTilesRemaining, playerList[1].whiteTilesRemaining]
