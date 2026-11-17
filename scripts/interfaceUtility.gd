extends RefCounted
class_name InterfaceUtility

static func clearButtonStyles(button: Button) -> void:
	for styleType in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		button.add_theme_stylebox_override(styleType, StyleBoxEmpty.new())
