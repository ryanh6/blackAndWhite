extends BasicGameScreen
class_name BlackWhiteScreen

const NOTILE: int = BlackWhiteGame.NOTILE
const SPECTATOR: int = -2
const PLACETIME: float = 0.45
const RESULTDELAY: float = 0.8
const SUMMARYDELAY: float = 1.0
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

enum Cover {
	NONE, 
	INTRO, 
	MATCH 
}

var controller: GameController
var game: BlackWhiteGame
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

@onready var background: TextureRect = %Background
@onready var margin: MarginContainer = %Margin
@onready var layout: BoxContainer = %Layout
@onready var leftPanel: BlackWhitePlayerPanel = %LeftPanel
@onready var rightPanel: BlackWhitePlayerPanel = %RightPanel
@onready var center: VBoxContainer = %Center
@onready var bottomRow: HBoxContainer = %BottomRow
@onready var scoreLabel: Label = %ScoreLabel
@onready var statusLabel: Label = %StatusLabel
@onready var history: RoundHistory = %History
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

func _ready() -> void:
	leftHand.tileChosen.connect(myTileChosen)
	slotsBox.placementRequested.connect(mySlotPressed)
	roundOverlay.continueRequested.connect(coverContinue)
	
	summaryTimer = Timer.new()
	summaryTimer.one_shot = true
	summaryTimer.timeout.connect(showSummary)
	add_child(summaryTimer)
	
	pauseButton.pressed.connect(requestPause.emit)
	resized.connect(applyLayout)
	opponentSlot.disabled = true
	applyLayout()


func bind(newController: GameController) -> void:
	controller = newController
	game = controller.logic as BlackWhiteGame
	localPlayerID = controller.localPlayerID
	background.texture = controller.look.background()
	
	viewId = localPlayerID if localPlayerID >= 0 else SPECTATOR

	controller.eventsReceived.connect(onEvents)
	controller.stateReplaced.connect(onStateReplaced)

	assignSides()
	layoutKnown = false
	applyLayout()
	syncAll(true)

func assignSides() -> void:
	leftID = viewID if viewID >= 0 else 0
	rightID = 1 - leftID
	leftPanel.showPlayer(leftID, playerName(leftID), iconFor(leftID))
	rightPanel.showPlayer(rightID, playerName(rightID), iconFor(rightID))
