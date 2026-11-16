extends LiftButton
class_name TileInterface

signal tilePressed(number: int)

var number: int = -1
var colour: StringName = &""
var texture: Texture2D

@onready var artwork: TextureRect = %TileArt

func liftArt() -> Control:
	return artwork

func canHover() -> bool:
	return not disabled and number >= 0

func ready() -> void:
	super.ready()
	pressed.connect(func() -> void: tilePressed.emit(number))
	artwork.texture = texture

func showTileFace(newNumber: int) -> void:
	number = newNumber
	colour = BlackWhiteGame.getTileColour(newNumber)
	setTexture(TileArt.face(newNumber))

func showHidden(newColour: StringName) -> void:
	number = -1
	colour = newColour
	setTexture(TileArt.hidden(newColour))

func setTileSize(tileSize: Vector2) -> void:
	setPictureSize(tileSize)

func setDimmed(isDimmed: bool) -> void:
	if is_node_ready():
		if isDimmed:
			artwork.modulate = Color(0.75, 0.75, 0.75)
		else:
			artwork.modulate = Color(1.0, 1.0, 1.0)

func getArtRectangle() -> Rect2:
	return artwork.get_global_rect()

func setTexture(newTexture: Texture2D) -> void:
	texture = newTexture
	if is_node_ready():
		artwork.texture = newTexture
