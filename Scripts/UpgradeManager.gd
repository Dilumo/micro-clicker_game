extends Node

class_name UpgradeManager

signal new_bar
signal upgrade_unlocked(upgrade_data)
signal upgrade_purchased

@onready var vbox_container = $ScrollContainer/VBoxContainer
@onready var main_popup = $"../main_panel/PopupBar"
@onready var auto_bars_container = $"../main_panel/AutoBarsContainer"
@export var upgrade_scene: PackedScene

@export var upgrades_resource: Resource  # Aponta para upgrades.tres

var auto_bar_resources := {
	"equality_bar": preload("res://Data/auto_bar/equality_bar.tres"),
	"degradation_bar": preload("res://Data/auto_bar/degradation_bar.tres"),
	"privilegiometer_bar": preload("res://Data/auto_bar/privilegiometer_bar.tres")
}

var upgrades_data = []
var active_upgrades = []  # Upgrades disponíveis

func _ready():
	# Carrega os upgrades do recurso
	if upgrades_resource:
		upgrades_data = upgrades_resource.upgrades
	else:
		NotificationSystem.notify("System", "Upgrade resource not configured or invalid!", "error")
	
	check_unlock_conditions()
	update_active_upgrades()
	restore_auto_bars()
	
	global.points_changed.connect(check_unlock_conditions)
	global.clicks_changed.connect(check_unlock_conditions)
	EffectSystem.spawn_new_bar.connect(spawn_new_bar)

func update_active_upgrades():
	for upgrade in upgrades_data:
		if is_upgrade_unlocked(upgrade) and not active_upgrades.has(upgrade):
			active_upgrades.append(upgrade)
			emit_signal("upgrade_unlocked", upgrade)
			remove_upgrade_from_ui(upgrade.name)

func is_upgrade_unlocked(upgrade_data) -> bool:
	if not upgrade_data.unlock_condition:
		return true
	return evaluate_condition(upgrade_data.unlock_condition)

func check_unlock_conditions():
	# Loop pelos upgrades disponíveis
	for upgrade in upgrades_data:
		# Verifica se o upgrade já está ativo ou adquirido
		if upgrade.name in global.resetable_stats["acquired_upgrades"]:
			continue
		# Avalia a condição de desbloqueio
		if evaluate_condition(upgrade.unlock_condition):
			# Adiciona o upgrade à lista de upgrades ativos (disponíveis para compra)
			if not active_upgrades.any(func(u): return u.name == upgrade.name):
				active_upgrades.append(upgrade)
				emit_signal("upgrade_unlocked", upgrade)
				add_upgrade(upgrade)  # Atualiza a interface

func evaluate_condition(condition: String) -> bool:
	var points = global.resetable_stats["section_points_bar"]
	var clicks = global.clicks
	var expression = Expression.new()

	# Definindo variáveis locais para a expressão
	var variables = {"points": points, "clicks": clicks}

	var error = expression.parse(condition, variables.keys())
	if error != OK:
		NotificationSystem.notify("System", "Error executing expression: " + expression.get_error_text(), "error")
		return false

	var result = expression.execute(variables.values(), self)
	if expression.has_execute_failed():
		NotificationSystem.notify("System", "Error executing expression!", "error")
		return false

	return result


func add_upgrade(data):
	var upgrade_instance = upgrade_scene.instantiate()
	upgrade_instance.upgrade_name = data.name
	upgrade_instance.upgrade_cost = data.cost
	upgrade_instance.upgrade_description = data.description
	upgrade_instance.effect_type = data.effect_type
	upgrade_instance.effect_value = data.effect_value
	upgrade_instance.upgrade_clicked.connect(purchase_upgrade)
	vbox_container.add_child(upgrade_instance)
	active_upgrades.append(data)

func purchase_upgrade(upgrade_name: String):
	# Encontra o upgrade pelos dados 
	var filtered_upgrades = active_upgrades.filter(func(u): return u.name == upgrade_name ) 
	var upgrade = ( 
		filtered_upgrades[0] if filtered_upgrades.size() > 0
		else null)
	if not upgrade:
		return

	# Calcula o custo atual e verifica a compra
	var level = global.resetable_stats["acquired_upgrades"].get(upgrade_name, 0)
	var cost = calculate_cost(upgrade, level)
	if not can_afford(cost):
		show_insufficient_points_feedback(upgrade_name)
		return
		
	global.decrement_points(cost)

	# Aplica o efeito e atualiza o estado
	var effect = calculate_effect(upgrade, level)
	apply_effect(upgrade.effect_type, effect, upgrade.new_bar_data)

	# Atualiza estado adquirido
	global.resetable_stats["acquired_upgrades"][upgrade_name] =  level + 1
	active_upgrades.erase(upgrade)  # Remove da lista de upgrades ativos
	remove_upgrade_from_ui(upgrade_name)  # Remove da interface
	emit_signal("upgrade_purchased")
	update_active_upgrades()
	# save game
	global.save_game()

func calculate_cost(upgrade_data, level: int) -> int:
	return int(upgrade_data.base_cost * pow(upgrade_data.cost_growth, level))

func calculate_effect(upgrade_data, level: int) -> float:
	return upgrade_data.base_effect + (level * upgrade_data.effect_growth)

func can_afford(cost: int) -> bool:
	return global.points_bar >= cost

func find_instace_upgrade(upgrade_name: String):
	for child in vbox_container.get_children():
		if child.upgrade_name == upgrade_name:
			return child
	return null

func remove_upgrade_from_ui(upgrade_name: String):
	var upgrade_UI = find_instace_upgrade(upgrade_name)
	if upgrade_UI:
		upgrade_UI.queue_free()
	return

func show_insufficient_points_feedback(upgrade_name : String):
	find_instace_upgrade(upgrade_name).cant_buy_upgrade()

func apply_effect(effect_type: String, effect_value: float, bar : Resource = null):
	EffectSystem.apply_effect(effect_type, effect_value, bar)

func restore_auto_bars():
	# Restaura todas as barras salvas em `resetable_stats`
	for bar_name in global.resetable_stats.get("auto_bars", {}):
		var bar_data_dict = global.resetable_stats["auto_bars"][bar_name]

		var key_bar = bar_data_dict.get("key", null)
		# Busca no dicionário de resources
		if not auto_bar_resources.has(key_bar):
			print("Bar resource not found: ", bar_name)
			continue

		# Duplica o recurso para evitar modificar o original
		var bar_data = auto_bar_resources[key_bar].duplicate() as AutoBarData
		if bar_data == null:
			print("Failed to duplicate AutoBarData for bar: ", bar_name)
			continue

		# Restaura os dados da barra
		bar_data.bar_name = bar_data_dict.get("bar_name", "Unnamed Bar")
		bar_data.base_speed = bar_data_dict.get("base_speed", 1.0)
		bar_data.points_per_cycle = bar_data_dict.get("points_per_cycle", 1)
		bar_data.upgrade_cost = bar_data_dict.get("upgrade_cost", 10)
		bar_data.max_progress = bar_data_dict.get("max_progress", 100)

		# Chama spawn_new_bar com o objeto atualizado
		spawn_new_bar(bar_data)

# Instancia uma nova barra automática
func spawn_new_bar(data : AutoBarData):
	var auto_bar = preload("res://Scenes/auto_bar.tscn").instantiate()
	auto_bars_container.add_child(auto_bar)
	auto_bar.set_data(data)
	auto_bar.sound_spawn_play()
	# Salva como dicionário para evitar problemas de serialização
	if not global.resetable_stats.has("auto_bars"):
		global.resetable_stats["auto_bars"] = {}

	global.resetable_stats["auto_bars"][data.bar_name] = {
		"key" : data.key,
		"bar_name": data.bar_name,
		"base_speed": data.base_speed,
		"points_per_cycle": data.points_per_cycle,
		"upgrade_cost": data.upgrade_cost,
		"max_progress": data.max_progress
	}
	
	emit_signal("new_bar", auto_bar)
