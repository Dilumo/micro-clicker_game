extends Node

class_name UpgradeManager

signal new_bar
signal upgrade_unlocked(upgrade_data)
signal upgrade_purchased

@onready var vbox_container = $ScrollContainer/VBoxContainer
@onready var main_popup = $"../main_panel/PopupBar"
@onready var auto_bars_container = $"../main_panel/AutoBarsContainer"
@export var upgrade_scene: PackedScene

var clicks = 0
var points = 0

@export var upgrades_resource: Resource  # Aponta para upgrades.tres

var upgrades_data = []
var active_upgrades = []  # Upgrades disponíveis

func _ready():
	# Carrega os upgrades do recurso
	if upgrades_resource:
		upgrades_data = upgrades_resource.upgrades
	else:
		print("Erro: Recurso de upgrades não configurado ou inválido.")
	check_unlock_conditions()
	
	update_active_upgrades()
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
		if upgrade.name in global.acquired_upgrades:
			continue
		# Avalia a condição de desbloqueio
		if evaluate_condition(upgrade.unlock_condition):
			# Adiciona o upgrade à lista de upgrades ativos (disponíveis para compra)
			if not active_upgrades.any(func(u): return u.name == upgrade.name):
				active_upgrades.append(upgrade)
				emit_signal("upgrade_unlocked", upgrade)
				add_upgrade(upgrade)  # Atualiza a interface

func evaluate_condition(condition: String) -> bool:
	var points = global.section_points_bar
	var clicks = global.clicks
	var expression = Expression.new()

	# Definindo variáveis locais para a expressão
	var variables = {"points": points, "clicks": clicks}

	var error = expression.parse(condition, variables.keys())
	if error != OK:
		print("Erro ao analisar a expressão: ", expression.get_error_text())
		return false

	var result = expression.execute(variables.values(), self)
	if expression.has_execute_failed():
		print("Erro ao executar a expressão")
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
	var level = global.acquired_upgrades.get(upgrade_name, 0)
	var cost = calculate_cost(upgrade, level)
	if not can_afford(cost):
		show_insufficient_points_feedback(upgrade_name)
		return
		
	global.decrement_points(cost)

	# Aplica o efeito e atualiza o estado
	var effect = calculate_effect(upgrade, level)
	apply_effect(upgrade.effect_type, effect, upgrade.new_bar_data)

	# Atualiza estado adquirido
	global.acquired_upgrades[upgrade_name] = level + 1
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


# Instancia uma nova barra automática
func spawn_new_bar(data : AutoBarData):
	var auto_bar = preload("res://Scenes/auto_bar.tscn").instantiate()
	auto_bars_container.add_child(auto_bar)
	auto_bar.set_data(data)
	auto_bar.sound_spawn_play()
	emit_signal("new_bar", auto_bar)
