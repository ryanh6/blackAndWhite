extends VBoxContainer
class_name BlackAndWhitePlayerPanel

signal tileChosen(number: int)

@onready var icon: PlayerIcon = %Icon
#@onready var hand: TileHandView = $Hand

#func ready() -> void:
	#hand.tileChosen.connect(tileChosen.emit)

func showPlayer(playerID: int, givenName: String, icon: Texture2D) -> void:
	icon.setPlayer(playerID, givenName, icon)
	
#func showHand()
