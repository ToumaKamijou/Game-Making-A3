extends Node


enum LIGHT_COLOR {
	WHITE = 0,
	RED = 1,
	GREEN = 2,
	BLUE = 3,
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
	return "" # Fallback
