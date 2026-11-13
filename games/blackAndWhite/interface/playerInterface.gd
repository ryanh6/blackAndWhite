extends Control
class_name PlayerInterface

@export var playerName: String = "Player"
@export var playerIcon: Texture2D

@onready var icon: TextureRect = %PlayerIcon
@onready var nameLabel: Label = %PlayerName

func _ready():
	icon.texture = playerIcon
	icon.pivot_offset = icon.size / 2
	nameLabel.text = playerName

func updatePanel(score: int, isCurrent: bool):
	icon.pivot_offset = icon.size / 2
	
	if isCurrent:
		icon.scale = Vector2(1.1, 1.1)
	else:
		icon.scale = Vector2(1, 1)
