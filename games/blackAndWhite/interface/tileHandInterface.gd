extends VBoxContainer
class_name TileHandInterface

## Define signals
signal tileChosen(number: int)

## Define constants and paths
const TILESCENE: PackedScene = preload("res://games/blackAndWhite/scenes/tileInterface.tscn")
const WHITETILES: int = 4
const BLACKTILES: int = 5

## Define variables
var tilesList: Array[TileInterface] = []
var rows: Array[HBoxContainer] = []
var showingFace: bool = false

## Maps a slot to a tile number
static func numberForSlot(slot: int) -> int:
	if slot < WHITETILES:
		return slot * 2 + 1
	else:
		return (slot - WHITETILES) * 2

## Maps a tile number back to its slot in hand
static func slotForNumber(number: int) -> int:
	if number % 2 == 1:
		return (number - 1) >> 1
	else:
		return WHITETILES + (number >> 1)

## Builds tile rows and connects each tile's press signal
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

## Sets the gap between each tile
func setTileSize(tileSize: Vector2, separation: float) -> void:
	for selectedRow in rows:
		selectedRow.add_theme_constant_override("separation", roundi(separation))
	
	for selectedTile in tilesList:
		selectedTile.setTileSize(tileSize)

## Reveals the faces / numbers on each tile
func showFaces(hand: Array, isEnabled: bool, selectedNumber: int) -> void:
	showingFace = true
	
	for slot in tilesList.size():
		var newTile := tilesList[slot]
		var newNumber: int = numberForSlot(slot)
		var held: bool = hand.has(newNumber)
		
		newTile.showTileFace(newNumber)
		
		if held:
			newTile.modulate.a = 1.0
		else:
			newTile.modulate.a = 0.0
		
		## Reset interaction and selection for each tile
		newTile.disabled = true
		newTile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		newTile.setDimmed(false)
		newTile.setSelected(false)

## Show face down tiles using the remaining count for each colour
func showHidden(blackRemaining: int, whiteRemaining: int) -> void:
	showingFace = false
	
	for slot in tilesList.size():
		var held: int
		var tile := tilesList[slot]
		var isWhite : bool = slot < WHITETILES
		
		if isWhite:
			held = slot < whiteRemaining
			tile.showHidden(BlackWhiteGame.WHITE)
		else:
			held = (slot - WHITETILES) < blackRemaining
			tile.showHidden(BlackWhiteGame.BLACK)
			
		if held:
			tile.modulate.a = 1.0
		else:
			tile.modulate.a = 0.0
			
		tile.disabled = true
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.setDimmed(false)
		tile.setSelected(false)

## Reports whether the hand is displaying tile numbers
func isShowingFaces() -> bool:
	return showingFace

## Gets tile control at the slot assigned to its number
func tileForNumber(number: int) -> TileInterface:
	return tilesList[slotForNumber(number)]

## Find a visible tile to use as start of placement animation
func sourceTile(number: int, colour: StringName) -> TileInterface:
	var first: int
	var last: int
	
	if showingFace and number >= 0:
		var newTile := tileForNumber(number)
		
		if newTile.modulate.a > 0.5:
			return newTile
		else:
			return null
	
	if colour == BlackWhiteGame.WHITE:
		first = 0
		last = WHITETILES - 1
	else:
		first = WHITETILES
		last = tilesList.size() - 1
	
	## Scan backwards to find the right most tile
	for slot in range(last, first - 1, -1):
		if tilesList[slot].modulate.a > 0.5:
			return tilesList[slot]
			
	return null

## Forwards presses onto number tiles
func onTilePressed(number: int) -> void:
	if number >= 0:
		tileChosen.emit(number)
