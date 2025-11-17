extends Node


enum LIGHT_COLOR {
	WHITE = 0,
	RED = 1,
	GREEN = 2,
	BLUE = 3,
	YELLOW = 4,
	PURPLE = 5,
	CYAN = 6
}


func change_flash_color(new_color: LIGHT_COLOR) -> Color:
	match new_color:
		Global.LIGHT_COLOR.WHITE:
			return Color.WHITE
		Global.LIGHT_COLOR.RED:
			return Color.RED
		Global.LIGHT_COLOR.GREEN:
			return Color.LIME_GREEN
		Global.LIGHT_COLOR.BLUE:
			return Color.ROYAL_BLUE
		Global.LIGHT_COLOR.YELLOW:
			return Color.YELLOW
		Global.LIGHT_COLOR.PURPLE:
			return Color.REBECCA_PURPLE
		Global.LIGHT_COLOR.CYAN:
			return Color.CYAN
	return Color.WHITE # Fallback


func change_color_group(new_color: LIGHT_COLOR) -> String:
	match new_color:
		Global.LIGHT_COLOR.WHITE:
			return ""
		Global.LIGHT_COLOR.RED:
			return "Red"
		Global.LIGHT_COLOR.GREEN:
			return "Green"
		Global.LIGHT_COLOR.BLUE:
			return "Blue"
		Global.LIGHT_COLOR.YELLOW:
			return "Yellow"
		Global.LIGHT_COLOR.PURPLE:
			return "Purple"
		Global.LIGHT_COLOR.CYAN:
			return "Cyan"
	return "" # Fallback
