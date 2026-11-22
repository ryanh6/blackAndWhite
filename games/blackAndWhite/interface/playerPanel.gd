extends VBoxContainer
class_name BlackWhitePlayerPanel

signal tileChosen(number: int)

@onready var icon: PlayerIcon = %Icon
@onready var hand: TileHandInterface = $Hand

func ready() -> void:
	hand.tileChosen.connect(tileChosen.emit)

func showPlayer(playerID: int, givenName: String, icon: Texture2D) -> void:
	icon.setPlayer(playerID, givenName, icon)
	
func showHand(player: BlackWhitePlayer, reveal: bool, enabled: bool, selected: int) -> void:
	if reveal:
		hand.showFaces(player.hand, enabled, selected)
	else:
		hand.showHidden(player.blackTilesRemaining, player.whiteTilesRemaining)
