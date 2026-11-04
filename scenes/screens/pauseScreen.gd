extends Control
class_name PauseScreen

signal requestResume
signal requestReturnToTitle

@onready var heading: Label = %Heading
@onready var resumeButton: Button = %ResumeButton
@onready var returnToTitleButton: Button = %ReturnToTitleButton

func _ready() -> void:
	resumeButton.pressed.connect(requestResume.emit)
	returnToTitleButton.pressed.connect(requestReturnToTitle.emit)
