extends HBoxContainer
class_name BlackWhiteBoardInterface

signal placementRequested

@onready var mySlot: SlotInterface = $MySlot
@onready var opponentSlot: SlotInterface = $OpponentSlot

func ready() -> void:
	mySlot.pressed.connect(placementRequested.emit)
	opponentSlot.disabled = true
	
func showPlacements(game: BlackWhiteGame, leftID: int) -> void:
	for entry in [[mySlot, leftID], [opponentSlot, 1 - leftID]]:
		var slot: SlotInterface = entry[0]
		var colour: StringName = game.players[entry[1]].placedColour
		
		if colour == &"":
			slot.showEmpty()
		else:
			slot.showTitle(colour)
