extends HBoxContainer
class_name BlackWhiteBoardInterface

## Define signals
signal placementRequested

## Define node variables
@onready var mySlot: SlotInterface = $MySlot
@onready var opponentSlot: SlotInterface = $OpponentSlot

## Connects the player's slot and disables clicks on the opponent slot
func ready() -> void:
	mySlot.pressed.connect(placementRequested.emit)
	opponentSlot.disabled = true

## Updates each slot to show the placed tile colour or empty space
func showPlacements(game: BlackWhiteGame, leftID: int) -> void:
	for entry in [[mySlot, leftID], [opponentSlot, 1 - leftID]]:
		var slot: SlotInterface = entry[0]
		var colour: StringName = game.players[entry[1]].placedColour
		
		if colour == &"":
			slot.showEmpty()
		else:
			slot.showTitle(colour)
