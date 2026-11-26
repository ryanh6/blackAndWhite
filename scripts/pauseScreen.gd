class_name PauseScreen
extends SlideOverlay

signal request_resume
signal request_return_to_title

@onready var heading: Label = %Heading
@onready var resume_button: Button = %ResumeButton
@onready var return_button: Button = %ReturnToTitleButton


func _ready() -> void:
	resume_button.pressed.connect(request_resume.emit)
	return_button.pressed.connect(request_return_to_title.emit)


## Online matches can't be paused for the opponent, so this is just a menu there.
func set_online(online: bool) -> void:
	heading.text = "MENU" if online else "PAUSED"
	resume_button.text = "Back To Game" if online else "Resume"
