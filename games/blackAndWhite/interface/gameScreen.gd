extends BasicGameScreen
class_name BlackWhiteScreen

## Defining constants
const NOTILE: int = BlackWhiteGame.NOTILE
const SPECTATOR: int = -2
const PLACETIME: float = 0.45
const RESULTDELAY: float = 0.8
const SUMMARYDELAY: float = 1.0

## Constants for layout based on background gold frame
const FRAMEPADDING: float = 28.0
const NAMEHEIGHT: float = 32.0
const ICONLANDSCAPE: float = 220.0
const ICONPORTRAIT: float = 170.0
const ICONMIN: float = 140.0
const TILEGAP: float = 6.0
const PANELSPACING: float = 8.0
const CENTERWIDTH: float = 330.0
const SIDEGAP: float = 40.0
const PORTRAITPANELGAP: float = 16.0

## Identifies the overlay currently covering the board
enum Cover {
	NONE, 
	INTRO, 
	MATCH 
}

var controller: GameController
var game: BlackWhiteGame

## The player that this device controls, -1 means both players
var localPlayerID: int = -1
var selectedTile: int = NOTILE

var viewID: int = SPECTATOR
var leftID: int = 0
var rightID: int = 1
var queue: Array = []
var busy: bool = false
var cover: Cover = Cover.NONE
var portrait: bool = false
var layoutKnown: bool = false
var summaryUp: bool = false
var summaryTimer: Timer

## Defining node variables
@onready var background: TextureRect = %Background
@onready var margin: MarginContainer = %Margin
@onready var layout: BoxContainer = %Layout
@onready var leftPanel: BlackWhitePlayerPanel = %LeftPanel
@onready var rightPanel: BlackWhitePlayerPanel = %RightPanel
@onready var center: VBoxContainer = %Center
@onready var bottomRow: HBoxContainer = %BottomRow
@onready var scoreLabel: Label = %ScoreLabel
@onready var statusLabel: Label = %StatusLabel
#@onready var history: RoundHistory = %History
@onready var leftHand: TileHandInterface = leftPanel.hand
@onready var rightHand: TileHandInterface = rightPanel.hand
@onready var slotsBox: BlackWhiteBoardInterface = %SlotsBox
@onready var mySlot: SlotInterface = slotsBox.my_slot
@onready var opponentSlot: SlotInterface = slotsBox.opponent_slot
@onready var leftIcon: PlayerIcon = leftPanel.badge
@onready var rightIcon: PlayerIcon = rightPanel.badge
@onready var roundOverlay: RoundOverlay = %RoundOverlay
@onready var effectsLayer: Control = %EffectsLayer
@onready var pauseButton: Button = %PauseButton

## On ready, connects the controls and lays out the screen details
func _ready() -> void:
	leftHand.tileChosen.connect(myTileChosen)
	slotsBox.placementRequested.connect(mySlotPressed)
	roundOverlay.continueRequested.connect(coverContinue)
	
	summaryTimer = Timer.new()
	summaryTimer.one_shot = true
	summaryTimer.timeout.connect(showSummary)
	add_child(summaryTimer)
	
	pauseButton.pressed.connect(requestPause.emit)
	opponentSlot.disabled = true

## Connecting Game To A Match -------------------------------------

## Connects the screen to a match and draws its initial state
func bind(newController: GameController) -> void:
	controller = newController
	game = controller.logic as BlackWhiteGame
	localPlayerID = controller.localPlayerID
	background.texture = controller.look.background()
	
	viewID = localPlayerID if localPlayerID >= 0 else SPECTATOR

	controller.eventsReceived.connect(onEvents)
	controller.stateReplaced.connect(onStateReplaced)

	assignSides()
	layoutKnown = false
	syncAll(true)

# Puts the viewer on the left side, or Player 1 when both hands are hidden
func assignSides() -> void:
	leftID = viewID if viewID >= 0 else 0
	rightID = 1 - leftID
	leftPanel.showPlayer(leftID, playerName(leftID), iconFor(leftID))
	rightPanel.showPlayer(rightID, playerName(rightID), iconFor(rightID))

## Retrieves the player icon
func iconFor(playerID: int) -> Texture2D:
	return controller.look.icon(playerID)

## Retrieves the player name
func playerName(playerID: int) -> String:
	if localPlayerID == -1:
		return "Player %d" % (playerID + 1)
	return "You" if playerID == localPlayerID else "Opponent"

## Checks if both player are sharing this device
func currentSeat() -> bool:
	return localPlayerID == -1

## Event Handling ----------------------------------------

## Adds incoming events to the queue
func onEvents(events: Array) -> void:
	queue.append_array(events)
	if not busy:
		runQueue()

## Prevents tile input while events are played in order
func runQueue() -> void:
	busy = true
	while not queue.is_empty():
		await play(queue.pop_front())
	busy = false
	syncAll()

## Play a match event and let animations run
func play(event: Dictionary) -> void:
	match StringName(event["Type"]):
		BlackWhiteGame.EVENTROUNDSTARTED:
			roundOverlay.dismiss()
			setCover(Cover.NONE)
			selectedTile = NOTILE
			if currentSeat():
				setViewer(int(event["FirstPlayerID"]))
			if int(event["RoundNumber"]) == 1:
				showIntro()
		BlackWhiteGame.EVENTTILEPLACED:
			selectedTile = NOTILE
			await animatePlacement(event)
		BlackWhiteGame.EVENTTURNCHANGED:
			if currentSeat():
				setViewer(int(event["PlayerID"]))
		BlackWhiteGame.EVENTROUNDENDED:
			if currentSeat():
				setViewer(SPECTATOR)
			if game.phase == BlackWhiteGame.gamePhase.ENDROUND:
				summaryTimer.start(SUMMARYDELAY)
		BlackWhiteGame.EVENTMATCHENDED:
			if currentSeat():
				setViewer(SPECTATOR)
			await get_tree().create_timer(RESULTDELAY).timeout
			showMatchResult()

## Clears any queued events and redraws after a resync
func onStateReplaced() -> void:
	queue.clear()
	summaryTimer.stop()
	selectedTile = NOTILE
	assignSides()
	match game.phase:
		BlackWhiteGame.gamePhase.ENDROUND:
			showSummary()
		BlackWhiteGame.gamePhase.ENDGAME:
			showMatchResult()
		_:
			if cover == Cover.MATCH:
				roundOverlay.dismiss()
				setCover(Cover.NONE)
	syncAll(true)	

## Changes the current active overlay
func setCover(value: Cover) -> void:
	cover = value
	if game != null and is_node_ready():
		syncSelectionVisuals()

## Switches whose private tiles are currently visible and updates sides
func setViewer(newViewer: int) -> void:
	viewID = newViewer
	assignSides()

## Drawing current state of the board -------------------------------

## Refreshes hands, slots, icons, scores to ensure things are in sync
func syncAll(instant: bool = false) -> void:
	if game == null:
		return

	syncSelectionVisuals()
	slotsBox.showPlacements(game, leftID)

	var placing := game.phase == BlackWhiteGame.gamePhase.PLACING
	for icon in [leftIcon, rightIcon]:
		icon.set_active(not placing or icon.player_id == game.current_player_id, not instant)

	var parts := "Score %d - %d" % [game.players[leftID].wins, game.players[rightID].wins]
	if game.ties > 0:
		parts += "  (%d tie%s)" % [game.ties, "" if game.ties == 1 else "s"]
	scoreLabel.text = parts
	statusLabel.text = statusText()
	
	history.visible = game.settings.get_bool(&"ShowRoundHistory")
	history.showHistory(game, leftID, rightID >= 0)

## Updates the tile visibility, and placement slot pulsing
func syncSelectionVisuals() -> void:
	leftPanel.showHand(game.players[leftID], viewID >= 0, canAct(), selectedTile)
	rightPanel.showHand(game.players[rightID], false, false, NOTILE)
	mySlot.setPulsing(canAct() and selectedTile != NOTILE)

## Chooses the appropriate status message for the current phase of the match
func statusText() -> String:
	var prefix := "Round %d of %d - " % [game.roundNumber, BlackWhiteGame.TILECOUNT]
	
	match game.phase:
		BlackWhiteGame.gamePhase.PLACING:
			return prefix + turnText()
		BlackWhiteGame.gamePhase.ENDROUND:
			return prefix + roundResultText()
		BlackWhiteGame.gamePhase.ENDGAME:
			return matchResultText()
	return ""

## Describes who turn it currently is
func turnText() -> String:
	var actor := game.currentPlayerID
	var first := 1 - game.secondPlayerID
	
	## The second player to place can see the colour of the first player tile.
	var seen := ""
	if game.isSecondMove(actor) and game.players[first].placedColour != &"":
		seen = "%s placed a %s tile. " % [playerName(first), String(game.players[first].placedColour)]

	if currentSeat():
		return "%s%s's turn" % [seen, playerName(actor)]
	if actor == localPlayerID:
		return "%sYour turn: choose a tile" % seen
	
	return "Opponent is choosing a tile..."

## Names the winner of the round
func roundResultText() -> String:
	if game.previousWinnerID == -1:
		return "This round is a tie!"
	return winText("round")

## Names the winner of the whole match
func matchResultText() -> String:
	if game.matchWinnerID == -1:
		return "It's a draw!"
	
	var winner := playerName(game.matchWinnerID)
	return "You win the match!" if winner == "You" else "%s wins the match!" % winner

## Formats the win message for the player who won the round
func winText(what: String) -> String:
	var winner := playerName(game.previousWinnerID)
	return "You win the %s!" % what if winner == "You" else "%s wins the %s!" % [winner, what]
	
## Overlay and Round Summary ----------------------------------

## Explains who places first
func turnOrderText() -> String:
	var first := 1 - game.secondPlayerID
	var who := playerName(first)
	var isYou := who == "You"
	
	var verb := "place" if isYou else "places"
	
	match game.turn_order_reason:
		&"coin_toss":
			return "Coin toss! %s %s first." % [who, verb]
		&"round_loser":
			return "%s won the last round, so %s %s first." % [who, "you" if isYou else "they", verb]
	
	if game.previousWinnerID == -1 and game.round_number > 1:
		return "The last round was a tie, so the order stays the same.\n%s %s first." % [who, verb]
	return "%s %s first." % [who, verb]

## Shows the round intro and blocks tile placement
func showIntro() -> void:
	setCover(Cover.INTRO)
	roundOverlay.showMessage("Round %d of %d" % [game.roundNumber, BlackWhiteGame.TILECOUNT],
		turnOrderText(), "Click to start")

## Asks for the summary screen after a round finishes
func showSummary() -> void:
	if game == null or game.phase != BlackWhiteGame.gamePhase.ENDROUND or summaryUp:
		return
	summaryUp = true
	requestRoundSummary.emit(summaryEntries(), game.roundNumber)

## Make summary entries with scores before and after the round
func summaryEntries() -> Array:
	var entries: Array = []
	
	for playerID in [leftID, rightID]:
		var score: int = game.players[playerID].wins
		var wonNow := 1 if game.previousWinnerID == playerID else 0
		entries.append({"Icon": iconFor(playerID), "Score": score, "previousScore": score - wonNow})
	
	return entries
	
## Starts the next round after the summary closes
func roundSummaryClosed() -> void:
	summaryUp = false

	if game.phase == BlackWhiteGame.gamePhase.ENDROUND and controller.may_continue_summary():
		controller.submit({"Type": "NextRound"})

## Show the match outcome and final score and return to title screen
func showMatchResult() -> void:
	setCover(Cover.MATCH)
	roundOverlay.showMessage(matchResultText(),
		"Final score %d - %d" % [game.players[leftID].wins, game.players[rightID].wins],
		"Click to return to the title screen")
	
## Dismiss the overlay and request to leave when match is over
func coverContinue() -> void:
	var finished := cover
	
	setCover(Cover.NONE)
	roundOverlay.dismiss()
	match finished:
		Cover.MATCH:
			requestLeave.emit()
	
## input -----------------------------------------------
	
## Check whether viewer can choose or place a tile right now
func canAct() -> bool:
	return not busy \
		and cover == Cover.NONE \
		and game.phase == BlackWhiteGame.gamePhase.PLACING \
		and viewID >= 0 \
		and game.currentPlayerID == viewID
	
## Selectes the clicked tile or clears selection
func myTileChosen(number: int) -> void:
	if not canAct():
		return
	
	selectedTile = NOTILE if number == selectedTile else number
	syncSelectionVisuals()

## Confirms the selected tile and places 
func mySlotPressed() -> void:
	if not canAct() or selectedTile == NOTILE:
		return
	
	var command := {"Type": "Place", "Tile": selectedTile}
	selectedTile = NOTILE
	syncSelectionVisuals()
	controller.submit(command)

## Placement of tile animation
func animatePlacement(event: Dictionary) -> void:
	var player := int(event["PlayerID"])
	var colour := StringName(event["Colour"])
	var tile := int(event.get("Rile", NOTILE))
	var hand := leftHand if player == leftID else rightHand
	var slot := mySlot if player == leftID else opponentSlot

	var source := hand.sourceTile(tile, colour)
	if source == null or not source.is_visible_in_tree() or not slot.is_visible_in_tree():
		slot.showTile(colour)
		return

	var start := source.getArtRectangle()
	var ghost := TextureRect.new()
	effectsLayer.add_child(ghost)
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost.texture = source.art.texture
	ghost.size = start.size
	ghost.global_position = start.position
	source.modulate.a = 0.0

	var target := slot.tileGlobalRectangle()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ghost, "global_position", target.position, PLACETIME)
	tween.tween_property(ghost, "size", target.size, PLACETIME)
	tween.tween_callback(func() -> void: ghost.texture = TileArt.hidden(colour)).set_delay(PLACETIME * 0.5)
	await tween.finished

	slot.showTile(colour)
	ghost.queue_free()
	
