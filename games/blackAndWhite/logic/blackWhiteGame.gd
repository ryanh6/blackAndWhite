extends GameLogic
class_name BlackWhiteGame

enum gamePhase {
	PLACING,
	ENDROUND,
	ENDGAME
}

const TILECOUNT: int = 9
const NOTILE: int = -1
const UNFINISHED: int = -2
const BLACK: StringName = &"Black"
const WHITE: StringName = &"White"

const EVENTROUNDSTARTED: StringName = &"RoundStarted"
const EVENTTILEPLACED: StringName = &"TilePlaced"
const EVENTTURNCHANGED: StringName = &"TurnChanged"
const EVENTROUNDENDED: StringName = &"RoundEnded"
const EVENTMATCHENDED: StringName = &"MatchEnded"

var playerList: Array[BlackWhitePlayer] = [BlackWhitePlayer.new(), BlackWhitePlayer.new()]
var settings: GameSettings = GameSettings.create(settingsSchema())
var randomNumber: RandomNumberGenerator = RandomNumberGenerator.new()
var viewerID: int = -1

var phase: gamePhase = gamePhase.PLACING
var roundNumber: int = 0
var currentPlayerID: int = 0
var secondPlayerID: int = 1
var turnOrderReason: StringName = &"Default"

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

func setViewerID(playerID: int) -> void:
	viewerID = playerID

static func settingsSchema() -> SettingsSchema:
	var newSchema: SettingsSchema = SettingsSchema.new()
	
	newSchema.addTurnOrder()
	newSchema.section("Display")
	newSchema.addBool(&"ShowRoundHistory", "Show Round History", true, "Show a summary of earlier rounds")
	
	return newSchema

func startMatch(chosenSettings: GameSettings, matchSeed: int) -> Array:
	settings = chosenSettings.copy()
	randomNumber.seed = matchSeed
	sequence = 0
	
	phase = gamePhase.PLACING
	roundNumber = 0
	tieCount = 0
	previousWinnerID = -1
	matchWinnerID = -1
	
	history = []
	
	for player in playerList.size():
		playerList[player].reset(viewerID == -1 or viewerID == player)
	
	var second: int = 1
	var reason: StringName = &"Default"
	
	if settings.get_bool(&"CoinToss"):
		second = randomNumber.randi() % 2
		reason = &"CoinToss"
		
	return startRound(second, reason)

func prepareNextRound() -> Array:
	var second: int = secondPlayerID
	var reason: StringName = &"Unchanged"
	
	if settings.get_bool("&LoserSecond") and previousWinnerID != -1:
		second = 1 - previousWinnerID
		reason = &"RoundLoser"
	
	return startRound(second, reason)

func startRound(second: int, reason: StringName) -> Array:
	return [emit({
		"Type": EVENTROUNDSTARTED,
		"RoundNumber": roundNumber + 1,
		"FirstPlayerID": 1 - second,
		"SecondPlayerID": second,
		"Reason": reason
	})]

func isSecondMove(playerID: int) -> bool:
	return playerID == secondPlayerID

func opponentTileColour() -> StringName:
	var firstMove: int = 1 - secondPlayerID
	return playerList[firstMove].placedColour

func validate(command: Dictionary, actionID: int) -> String:
	match String(command.get("Type", "")):
		"Place":
			if phase != gamePhase.PLACING:
				return "INCORRECT PHASE"
			if actionID != -1 and actionID != currentPlayerID:
				return "NOT CURRENT TURN"
			
			var placedTile: Variant = command.get("Tile")
			if not (placedTile is int):
				return "INVALID MOVE"
			if not playerList[currentPlayerID].hand.has(placedTile):
				return "TILE NOT IN HAND"
			
			return ""
		"NextRound":
			if phase != gamePhase.ENDROUND:
				return "ROUND NOT OVER"
			
			return ""
	return "UNKNOWN COMMAND"

func execute(command: Dictionary) -> Array:
	var events: Array = []
	
	match String(command.get("Type", "")):
		"Place":
			events = placeTile(int(command["Tile"]))
		"NextRound":
			events = prepareNextRound()
	
	sequence += 1
	return events

func placeTile(tile: int) -> Array:
	var opponentID = 1 - currentPlayerID
	var winnerID = -1
	var result = UNFINISHED
	var events: Array = []
	
	events.append(emit({"Type": EVENTTILEPLACED, "PlayerID": currentPlayerID, "Colour": getTileColour(tile), "Tile": tile}))
	
	if playerList[opponentID].placedColour == &"":
		events.append(emit({"Type": EVENTTURNCHANGED, "PlayerID": opponentID}))
		return events
	
	if playerList[0].placedTile > playerList[1].placedTile:
		winnerID = 0
	elif playerList[1].placedTile > playerList[0].placedTile:
		winnerID = 1
	
	events.append(emit({"Type": EVENTROUNDENDED, "RoundNumber": roundNumber, "WinnerID": winnerID}))
	
	result = findMatchResult()
	if result != UNFINISHED:
		events.append(emit({"Type": EVENTMATCHENDED, "WinnerID": result}))
	
	return events

func findMatchResult() -> int:
	for player in playerList.size():
		if playerList[player].wins >= calculateRequiredWins():
			return player
	
	if roundNumber >= TILECOUNT:
		if playerList[0].wins > playerList[1].wins:
			return 0
		elif playerList[1].wins > playerList[0].wins:
			return 1
		return -1

	return UNFINISHED

func emit(event: Dictionary) -> Dictionary:
	apply(event)
	return event
	
func apply(event: Dictionary) -> void:
	match StringName(event["Type"]):
		EVENTROUNDSTARTED:
			roundNumber = int(event["RoundNumber"])
			currentPlayerID = int(event["FirstPlayerID"])
			secondPlayerID = int(event["SecondPlayerID"])
			
			for player in playerList:
				player.clearPlacement()
			phase = gamePhase.PLACING
			
		EVENTTILEPLACED:
			var player := int(event["PlayerID"])
			var tile := int(event.get("Tile", NOTILE))
			var colour := StringName(event["Colour"])
			playerList[player].placeTile(tile, colour)
			
		EVENTTURNCHANGED:
			currentPlayerID = int(event["PlayerID"])
			
		EVENTROUNDENDED:
			var winner := int(event["WinnerID"])
			if winner == -1:
				tieCount += 1
			else:
				playerList[winner].wins += 1
				
			previousWinnerID = winner
			history.append({
				"Round": roundNumber,
				"FirstPlayerID": 1 - secondPlayerID,
				"Colours": getPlacedColours.duplicate(),
				"Tiles": getPlacedTiles.duplicate(),
				"WinnerID": winner
			})
			phase = gamePhase.ENDROUND
			
		EVENTMATCHENDED:
			matchWinnerID = int(event["WinnerID"])
			phase = gamePhase.ENDGAME

func useEventSync() -> bool:
	return true

func eventForPlayer(events: Array, playerID: int) -> Array:
	var results: Array = []
	
	for event in events:
		var eventsCopy: Dictionary = event.duplicate()
		
		if StringName(eventsCopy["Type"]) == EVENTTILEPLACED and int(eventsCopy["PlayerID"]) != playerID:
			eventsCopy["Tile"] = NOTILE
		results.append(eventsCopy)
	
	return results
	
func applyEvents(events: Array) -> void:
	for event in events:
		apply(event)
	sequence += 1
	
func toDictionary() -> Dictionary:
	var handCopies: Array = []
	for hand in getHands:
		handCopies.append(hand.duplicate())
	return {
		"Settings": settings.toDictionary(),
		"ViewerID": viewerID,
		"Phase": int(phase),
		"RoundNumber": roundNumber,
		"CurrentPlayerID": currentPlayerID,
		"SecondPlayerID": secondPlayerID,
		"Wins": winCount.duplicate(),
		"Ties": tieCount,
		"PreviousWinner": previousWinnerID,
		"MatchWinner": matchWinnerID,
		"Hands": handCopies,
		"PlacedTiles": getPlacedTiles.duplicate(),
		"PlacedColours": coloursToStrings(getPlacedColours),
		"BlackTilesRemaining": getBlackTilesRemaining.duplicate(),
		"WhiteTilesRemaining": getWhiteTilesRemaining.duplicate(),
		"History": historyToDictionary(),
		"RNGSeed": randomNumber.seed,
		"RNGState": randomNumber.state,
		"Sequence": sequence
	}

func snapshotForPlayer(playerID: int) -> Dictionary:
	var data := toDictionary()
	var other := 1 - playerID
	data["ViewerID"] = playerID
	data["Hands"][other] = []
	data["PlacedTiles"][other] = NOTILE
	
	for entry in data["History"]:
		entry["Tiles"][other] = NOTILE
	return data
	
func coloursToStrings(colours: Array) -> Array:
	var result: Array = []
	
	for colour in colours:
		result.append(String(colour))
	return result
	
func stringsToColours(strings: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	
	for text in strings:
		result.append(StringName(text))
	return result
	
func historyToDictionary() -> Array:
	var result: Array = []
	
	for entry in history:
		result.append({
			"Round": entry["Round"],
			"FirstPlayerID": entry["FirstPlayerID"],
			"Colours": coloursToStrings(entry["Colours"]),
			"Tiles": entry["Tiles"].duplicate(),
			"WinnerID": entry["WinnerID"]
		})
	return result
