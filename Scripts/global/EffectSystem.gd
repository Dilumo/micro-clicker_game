# EffectSystem
extends Node
signal spawn_new_bar

func apply_effect(effect_type: String, effect_value: float, bar : Resource = null):
	match effect_type:
		"main_bar_speed":
			global.resetable_stats["main_bar_speed_multiplier"] += effect_value
		"main_bar_points":
			global.resetable_stats["main_bar_points_bonus"] += int(effect_value)
		"permanent_main_bar_speed":
			global.permanent_upgrades["main_bar_speed_base"] += effect_value
		"permanent_main_bar_points":
			global.permanent_upgrades["main_bar_points_base"] += int(effect_value)
		"new_bar":
			spawn_new_bar.emit(bar)
		_:
			NotificationSystem.notify("System", "Unknown effect type: " + effect_type, "error")
			
func get_readable_effect_name(effect_type: String) -> String:
	match effect_type:
		"main_bar_speed":
			return "Bar Speed"
		"main_bar_points":
			return "Bar Points"
		"permanent_main_bar_speed":
			return "Base System Speed"
		"permanent_main_bar_points":
			return "Base System Points"
		"new_bar":
			return "New Bar"
		_:
			return "Unknown Effect"


func get_readable_effect(effect_type: String) -> String:
	match effect_type:
		"main_bar_speed":
			return "Temporarily increases the speed of the main bar."
		"main_bar_points":
			return "Temporarily increases the points gained per click on the main bar."
		"permanent_main_bar_speed":
			return "Permanently increases the base speed of the main bar."
		"permanent_main_bar_points":
			return "Permanently increases the points gained per click on the main bar."
		"new_bar":
			return "Adds a new bar for interaction."
		_:
			return "Unknown effect."
