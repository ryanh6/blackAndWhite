extends VBoxContainer
class_name TileHandInterface

signal tileChosen(number: int)

const TILESCENE: PackedScene = preload("res://games/blackAndWhite/scenes/tileInterface.tscn")
const WHITETILES: int = 4
const BLACKTILES: int = 5

var tilesList: Array[TileInterface] = []
var rows: Array[HBoxContainer] = []
var isShowFace: bool = false

static func numberForSlot(slot: int) -> int:
	if slot < WHITETILES:
		return slot * 2 + 1
	else:
		return (slot - WHITETILES) * 2

static func slotForNumber(number: int) -> int:
	if number % 2 == 1:
		return (number - 1) >> 1
	else:
		return WHITETILES + (number >> 1)

func ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 0)
	
	for count in [WHITETILES, BLACKTILES]:
		var newRow := HBoxContainer.new()
		newRow.alignment = BoxContainer.ALIGNMENT_CENTER
		newRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
		add_child(newRow)
		rows.append(newRow)
		for index in count:
			var newTile: TileInterface = TILESCENE.instantiate()
			newRow.add_child(newTile)
			newTile.tilePressed.connect(onTilePressed)
			tilesList.append(newTile)

func setTileSize(tileSize: Vector2, separation: float) -> void:
	for selectedRow in rows:
		selectedRow.add_theme_constant_override("separation", roundi(separation))
	
	for selectedTile in tilesList:
		selectedTile.setTileSize(tileSize)

func showFace(hand: Array, isEnabled: bool, selectedNumber: int) -> void:
	isShowFace = true
	
	for slot in tilesList.size():
		var newTile := tilesList[slot]
		var newNumber: int = numberForSlot(slot)
		var held: bool = hand.has(newNumber)
		
		newTile.showTileFace(newNumber)
		
		if held:
			newTile.modulate.a = 1.0
		else:
			newTile.modulate.a = 0.0
			
		newTile.disabled = true
		newTile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		newTile.setDimmed(false)
		newTile.setSelected(false)
