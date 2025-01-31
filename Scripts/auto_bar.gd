extends Control

signal bar_full  # Emite o ponto ao completar o carregamento
signal buy_upgrade  # Emite sinal ao comprar um upgrade

# Resource pre-setting
@export var autobar_data : AutoBarData

# UI changeable 
@export var progress_bar : TextureProgressBar
@export var texture_bg : NinePatchRect
@export var upgrade_button : Button
@export var title_label : Label
@export var descripton_label : Label
@export var subdescription_label : Label
@export var illustration_texture : TextureRect

#Information
@export var cost_label : Label
@export var info_label : Label

@export var timer : Timer
@export var tooltip : Control

# Sounds 
@export var sound_spawn : AudioStreamPlayer2D

@export var increment_cust = 1.5

var current_speed: float
var current_points: int
var current_cost: int
var current_progress: float = 0  # Progresso atual

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	upgrade_button.mouse_entered.connect(_on_button_hover)
	upgrade_button.mouse_exited.connect(_on_button_exit)

func set_data(data : AutoBarData) -> void:
	if !data: return
	autobar_data = data
	
	current_speed = autobar_data.base_speed
	current_points = autobar_data.points_per_cycle
	current_cost = autobar_data.upgrade_cost
	
	progress_bar.min_value = 0
	progress_bar.max_value = autobar_data.max_progress
	progress_bar.value = 0
	
	tooltip.visible = false
	
	timer.wait_time = current_speed
	timer.start()
	
	update_resetable_state()
	set_ui_data()
	y_update_subdescription()

func update_resetable_state():
	# Atualiza os dados da barra no `resetable_stats`
	if not global.resetable_stats.has("auto_bars"):
		global.resetable_stats["auto_bars"] = {}

	var updated_data = {
		"key": autobar_data.key,
		"bar_name": autobar_data.bar_name,
		"base_speed": current_speed,
		"points_per_cycle": current_points,
		"upgrade_cost": current_cost,
		"max_progress": autobar_data.max_progress
	}
	global.resetable_stats["auto_bars"][autobar_data.bar_name] = updated_data

func set_ui_data() -> void:
	title_label.text = autobar_data.bar_name
	descripton_label.text = autobar_data.bar_descripiton
	update_relativs_infos()
	
func update_relativs_infos() -> void:
	info_label.text = "bar/give : " + str(current_points) + "............................bar/progress/speed: " + str("%.2f sec." % current_speed)
	cost_label.text = "bar/cost: " + str(current_cost)

# Loop function to change subdescription
func y_update_subdescription() -> void:
	if autobar_data.sub_descriptions.size() == 0:
		subdescription_label.text = ""
		return
	
	var index = randi() % autobar_data.sub_descriptions.size()
	subdescription_label.text = autobar_data.sub_descriptions[index]
	
	await get_tree().create_timer(120.0).timeout
	y_update_subdescription()

func sound_spawn_play() ->  void:
	sound_spawn.play()

func _on_timer_timeout():
	emit_signal("bar_full", current_points)
	current_progress = 0
	progress_bar.value = 0
	timer.start()
	update_resetable_state()

func _process(delta):
	# Incrementa o progresso com base no delta
	current_progress += (delta / current_speed) * autobar_data.max_progress
	current_progress = clamp(current_progress, 0, autobar_data.max_progress)
	progress_bar.value = current_progress  # Atualiza a barra

func _on_upgrade_pressed():
	if global.points_bar >= current_cost:  # Verifica se o jogador tem pontos suficientes
		global.decrement_points(current_cost)
		current_cost = int(current_cost * increment_cust)  # Incrementa custo progressivamente
		current_speed *= autobar_data.speed_increase  # Aumenta a velocidade
		current_points += autobar_data.points_increase  # Adiciona pontos por ciclo

		timer.wait_time = current_speed
		update_relativs_infos()
		update_resetable_state()

func _on_button_hover():
	# Exibe tooltip com informações do próximo upgrade
	tooltip.visible = true
	tooltip.set_text("Próximo Upgrade:\nVelocidade: %.2f s\nPontos: %d" % [current_speed * autobar_data.speed_increase, autobar_data.points_increase + current_points])
	tooltip.global_position = get_global_mouse_position() + Vector2(10, 10)
	
func _on_button_exit():
	# Esconde o tooltip
	tooltip.visible = false
