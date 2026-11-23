extends Button
class_name SlotInterface

const BORDERCOLOUR := Color(0.62, 0.45, 0.2, 0.9)

var pulse: Tween

@onready var frame: Panel = $Frame
@onready var art: TextureRect = %Art

func ready() -> void:
	InterfaceUtility.clearButtonStyles(self)
	focus_mode = Control.FOCUS_NONE
	
	var outline := StyleBoxFlat.new()
	outline.bg_color = Color(0, 0, 0, 0.18)
	outline.border_color = BORDERCOLOUR
	outline.set_border_width_all(3)
	outline.set_corner_radius_all(12)
	frame.add_theme_stylebox_override("Panel", outline)

func showEmpty() -> void:
	art.texture = null

func showTitle(colour: StringName) -> void:
	art.texture = TileArt.hidden(colour)

func setPulsing(active: bool) -> void:
	if pulse != null:
		pulse.kill()
		pulse = null
	frame.modulate.a = 1.0
	if active:
		pulse = create_tween().set_loops()
		pulse.tween_property(frame, "modulate:a", 0.4, 0.55)
		pulse.tween_property(frame, "modulate:a", 1.0, 0.55)

func hasTile() -> bool:
	return art.texture != null

func tileGlobalRectangle() -> Rect2:
	var area := art.get_global_rect()
	var width := minf(area.size.x, area.size.y * TileArt.ASPECT)
	var fitted := Vector2(width, width / TileArt.ASPECT)
	
	return Rect2(area.get_center() - fitted / 2.0, fitted)
