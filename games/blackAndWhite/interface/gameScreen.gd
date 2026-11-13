extends Control
class_name GameScreen

signal requestPause
signal requestNextRound
signal requestTitle

@onready var playerOnePanel: PlayerInterface = %Player1Panel
@onready var playerTwoPanel: PlayerInterface = %Player2Panel
@onready var playerOneColumn: VBoxContainer = %Player1Column
@onready var playerTwoColumn: VBoxContainer = %Player2Column
@onready var scoreLabel: Label = %ScoreLabel
@onready var pauseButton: Button = %PauseButton

var game: Game

func _ready():
	pauseButton.pressed.connect(requestPause.emit)

func setGame(newGame: Game):
	game = newGame
	_refresh()

func _refresh():
	if game == null:
		return
	
	playerOnePanel.updatePanel(game.playerList[0].roundsWon, game.currentPlayerID == 0)
	playerTwoPanel.updatePanel(game.playerList[1].roundsWon, game.currentPlayerID == 1)
	
	scoreLabel.text = "Score %d - %d" % [game.playerList[0].roundsWon, game.playerList[1].roundsWon]
	
