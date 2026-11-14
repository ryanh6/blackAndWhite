extends GameLogic
class_name BlackAndWhiteGame

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

var winCount: Array: 
	get:
		return [playerList[0].wins, playerList[1].wins]
var tieCount: int = 0

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

var getPlacedColours: Array:
	get:
		return [playerList[0].placedColour, playerList[1].placedColour]

var history: Array = []

static func getTileColour(tile: int) -> int:
	if tile % 2 == 0:
		return 1
	return 0

static func calculateRequiredWins() -> int:
	return TILECOUNT / 2 + 1

#func startMatch(chosenSettings: GameSettings, matchSeed: int) -> Array:
	#settings = chosenSettings.copy()
	#rng.seed = matchSeed
	#sequence = 0
	#
	#phase = gamePhase.PLACING
	#roundNumber = 0
	#tieCount = 0
	#previousWinnerID = -1
	#matchWinnerID = -1
	#
	#history = []
	#
	#for player in playerList:
		#playerList[player].reset(viewerID == -1 or viewerID == player)
	#
	#return startRound()
#
#func prepareNextRound() -> Array:
	#var secondMove = secondPlayerID
	#return startRound()

#func startRound(secondMoveID: int): Array:
	#return

func isSecondMove(playerID: int) -> bool:
	return playerID == secondPlayerID

func opponentTileColour() -> StringName:
	var firstMove: int = 1 - secondPlayerID
	return playerList[firstMove].placedColour

func validate(command: Dictionary, actionID: int) -> String:
	match String(command.get("Type", "")):
		"Place"
