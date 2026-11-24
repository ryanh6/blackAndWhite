extends VBoxContainer
class_name BlackWhitePlayerPanel

## Define signals
signal tileChosen(number: int)

## Define node variables
@onready var icon: PlayerIcon = %Icon
@onready var hand: TileHandInterface = $Hand

## Pass tile clicks from the hand up to the screen
func ready() -> void:
	hand.tileChosen.connect(tileChosen.emit)

## Sets the player's ID, name and player icon
func showPlayer(playerID: int, givenName: String, icon: Texture2D) -> void:
	icon.setPlayer(playerID, givenName, icon)

## Shows number tiles or hidden tiles by colour
func showHand(player: BlackWhitePlayer, reveal: bool, enabled: bool, selected: int) -> void:
	if reveal:
		hand.showFaces(player.hand, enabled, selected)
	else:
		hand.showHidden(player.blackTilesRemaining, player.whiteTilesRemaining)
