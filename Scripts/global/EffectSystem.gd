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
			print("Unknown effect type:", effect_type)

func get_readable_effect_name(effect_type: String) -> String:
	match effect_type:
		"main_bar_speed":
			return "Velocidade Barra"
		"main_bar_points":
			return "Pontos Barra"
		"permanent_main_bar_speed":
			return "Velocidade Sistema Base"
		"permanent_main_bar_points":
			return "Pontos Sistema Base"
		"new_bar":
			return "Nova Barra"
		_:
			return "Efeito Desconhecido"


func get_readable_effect(effect_type: String) -> String:
	match effect_type:
		"main_bar_speed":
			return "Aumenta a velocidade da barra principal temporariamente."
		"main_bar_points":
			return "Aumenta a quantidade de pontos ganhos por clique na barra principal temporariamente."
		"permanent_main_bar_speed":
			return "Aumenta permanentemente a velocidade base da barra principal."
		"permanent_main_bar_points":
			return "Aumenta permanentemente os pontos ganhos por clique na barra principal."
		"new_bar":
			return "Adiciona uma nova barra para interação."
		_:
			return "Efeito desconhecido."
