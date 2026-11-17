extends Button
class_name LiftButton

const LIFT: float = 26.0
const POPUPSCALE: float = 0.1
const HOVERFRACTION: float = 0.4

@export var liftHeight: float = LIFT

var headRoom: float = -1.0
var hovered: bool = false
var selected: bool = false
var lift: float = 0.0:
	set(value):
		lift = value
		applyLift()

var liftTween: Tween

func liftArt() -> Control:
	return null
	
func canHover() -> bool:
	return not disabled
	
func ready() -> void:
	InterfaceUtility.clearButtonStyles(self)
	focus_mode = Control.FOCUS_NONE
	mouse_entered.connect(func() -> void: setHovered(true))
	mouse_exited.connect(func() -> void: setHovered(false))
	
	var artwork := liftArt()
	if artwork != null:
		artwork.resized.connect(updatePivot)
		
	applyLift()

func setSelected(value: bool) -> void:
	selected = value
	animateLift()

static func headRoomFor(pictureHeight: float, liftPixels: float = LIFT) -> float:
	if liftPixels > 0.0:
		return liftPixels + POPUPSCALE * pictureHeight
	else:
		return 0.0

func setPictureSize(pictureSize: Vector2) -> void:
	headRoom = headRoomFor(pictureSize.y, liftHeight)
	custom_minimum_size = Vector2(pictureSize.x, pictureSize.y + headRoom)
	applyLift()
	
func setHovered(value: bool) -> void:
	hovered = value
	animateLift()
	
func animateLift() -> void:
	var target: float = 0.0
	
	if selected:
		target = liftHeight
	elif hovered and canHover():
		target = liftHeight * HOVERFRACTION
	if liftTween != null:
		liftTween.kill()
	if not is_node_ready():
		lift = target
		return
		
	liftTween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	liftTween.tween_property(self, "lift", target, 0.14)

func applyLift() -> void:
	var amount: int
	var raised: int
	var room: int
	var artwork := liftArt()
	
	if artwork == null:
		return
	
	if liftHeight > 0.0:
		amount = lift
	else:
		amount = 0.0
		
	if headRoom >= 0.0:
		room = headRoom
	else:
		room = liftHeight
		
	artwork.offset_top = room - amount
	artwork.offset_bottom = -amount
	
	if liftHeight > 0.0:
		raised = amount / liftHeight
	else:
		raised = 0.0
		
	artwork.scale = Vector2.ONE * (1.0 + POPUPSCALE * raised)
	updatePivot()
	
func updatePivot() -> void:
	var artwork := liftArt()
	
	if artwork != null:
		artwork.pivot_offset = Vector2(artwork.size.x / 2.0, artwork.size.y)
