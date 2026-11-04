extends Control
class_name titleScreen

signal requestStart
signal requestOptions

@onready var startButton: Button = %StartButton
@onready var optionsButton: Button = %OptionsButton
@onready var quitButton: Button = %QuitButton

func _ready() -> void:
	startButton.pressed.connect(requestStart.emit)
	optionsButton.pressed.connect(requestOptions.emit)
	quitButton.pressed.connect(get_tree().quit)
