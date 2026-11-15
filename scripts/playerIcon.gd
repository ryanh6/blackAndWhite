extends VBoxContainer
class_name PlayerIcon

const ACTIVETINT: Color = Color(1.0, 1.0, 1.0, 1.0)
const INACTIVETINT: Color = Color(0.5, 0.5, 0.5, 0.8)

var playerID: int = -1
var tween: Tween

@onready var icon: TextureRect = %Icon
@onready var nameLabel: Label = %Name

func setPlayer(newPlayerID: int, displayName: String, newTexture: Texture2D) -> void:
	playerID = newPlayerID
	nameLabel.text = displayName
	icon.texture = newTexture

func setActive(isActive: bool, animate: bool = true) -> void:
	var targetScale: Vector2
	var targetTint: Color
	
	if tween != null:
		tween.kill()
	
	if isActive:
		targetScale = Vector2.ONE * (1.1)
		targetTint = ACTIVETINT
	else:
		targetScale = Vector2.ONE * (1.0)
		targetTint = INACTIVETINT
	icon.pivot_offset = icon.size / 2.0
	
	if not animate:
		icon.scale = targetScale
		modulate = targetTint
		return
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(icon, "scale", targetScale, 0.2)
	tween.tween_property(self, "modulate", targetTint, 0.2)

func setIconSize(pixels: float) -> void:
	icon.custom_minimum_size = Vector2(pixels, pixels)
