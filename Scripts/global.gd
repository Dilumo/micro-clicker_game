class_name Global extends Node

signal points_changed
signal clicks_changed
signal reset_points_changed

# Save data
signal game_loaded
signal game_saved
var save_file_path = "user://save_data.json"
var save_timer : int = 1 # Save in minutes

# Estatísticas resetáveis (valores que voltam ao padrão após um reset)
var resetable_stats := {
	"main_bar_speed_multiplier": 8.0,
	"main_bar_points_bonus": 10,
	"points_multiplier": 1.0,
	"speed_multiplier": 1.0,
	"section_points_bar": 0,
	"acquired_upgrades": {},
	"auto_bars" : {}
}

# Valores padrão para resetáveis
var default_resetable_stats := {
	"main_bar_speed_multiplier": 8.0,
	"main_bar_points_bonus": 10.0,
	"points_multiplier": 1.0,
	"speed_multiplier": 1.0,
	"section_points_bar": 0,
	"acquired_upgrades": {},
	"auto_bars" : {}
}

# Estatísticas permanentes (upgrades permanentes)
var permanent_upgrades := {
	"main_bar_speed_base": 1.0,
	"main_bar_points_base": 0
}

# Progresso e resets
var points_bar = 0
var since_started_points_bar = 0
var since_reset_clicks = 0
var clicks = 0
var reset_points = 0 # Total de pontos especiais acumulados

var points_for_next_reset = 100 # Progresso necessário para o primeiro ponto especial
var reset_progress_multiplier = 1.02 # Multiplicador que aumenta o custo dos próximos pontos especiais

# Custo dos upgrades permanentes
var upgrade_cost_multiplier = 1.5 # Escalonamento do custo dos upgrades

# Métodos de incremento e reset
func increment_points(amount: int):
	points_bar += amount
	since_started_points_bar += amount
	resetable_stats["section_points_bar"] += amount
	check_reset_points() 
	emit_signal("points_changed")

func increment_clicks():
	clicks += 1
	since_reset_clicks += 1
	emit_signal("clicks_changed")
	
func decrement_points(amount: int):
	points_bar -= amount
	emit_signal("points_changed")

func decrement_reset_point(ammount : int) -> void:
	reset_points -= ammount
	emit_signal("reset_points_changed")

func check_reset_points():
	# Verifica se atingiu o progresso necessário
	while since_started_points_bar >= points_for_next_reset:
		reset_points += 1
		since_started_points_bar -= points_for_next_reset
		# Escalonar o custo do próximo ponto
		points_for_next_reset *= reset_progress_multiplier
		emit_signal("reset_points_changed")

func reboot_resets() -> void:
	points_bar = 0
	clicks = 0
	reset_temporary_stats()

# Reset dos valores resetáveis
func reset_temporary_stats():
	for key in resetable_stats.keys():
		if typeof(default_resetable_stats[key]) in [TYPE_DICTIONARY, TYPE_ARRAY]:
			resetable_stats[key] = default_resetable_stats[key].duplicate(true)  # Deep copy
		else:
			resetable_stats[key] = default_resetable_stats[key]
		
func get_final_main_bar_speed() -> float:
	return resetable_stats["main_bar_speed_multiplier"] * permanent_upgrades["main_bar_speed_base"]

func get_final_main_bar_points() -> int:
	return resetable_stats["main_bar_points_bonus"] + permanent_upgrades["main_bar_points_base"]
	
	
func get_save_data() -> Dictionary:
	return {
		"resetable_stats": resetable_stats,
		"permanent_upgrades": permanent_upgrades,
		"points_bar": points_bar,
		"since_started_points_bar": since_started_points_bar,
		"since_reset_clicks": since_reset_clicks,
		"clicks": clicks,
		"reset_points": reset_points,
		"points_for_next_reset": points_for_next_reset,
		"reset_progress_multiplier": reset_progress_multiplier,
		"upgrade_cost_multiplier": upgrade_cost_multiplier,
		"upgrades_state": GlobalUpgrades.upgrades_state  # Referência ao nó de upgrades
	}

func load_save_data(data: Dictionary):
	resetable_stats = data.get("resetable_stats", resetable_stats)
	permanent_upgrades = data.get("permanent_upgrades", permanent_upgrades)
	points_bar = data.get("points_bar", points_bar)
	since_started_points_bar = data.get("since_started_points_bar", since_started_points_bar)
	since_reset_clicks = data.get("since_reset_clicks", since_reset_clicks)
	clicks = data.get("clicks", clicks)
	reset_points = data.get("reset_points", reset_points)
	points_for_next_reset = data.get("points_for_next_reset", points_for_next_reset)
	reset_progress_multiplier = data.get("reset_progress_multiplier", reset_progress_multiplier)
	upgrade_cost_multiplier = data.get("upgrade_cost_multiplier", upgrade_cost_multiplier)
	
	# Atualizar o estado dos upgrades
	if data.has("upgrades_state"):
		GlobalUpgrades.upgrades_state = data["upgrades_state"]

# Salvar os dados no arquivo
func save_game() -> void:
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	# Obtém data e hora atuais
	var datetime = Time.get_datetime_dict_from_system()
	var formatted_time = str(datetime.hour).lpad(2, "0") + ":" + str(datetime.minute).lpad(2, "0")
	if file:
		file.store_string(JSON.stringify(get_save_data()))
		file.close()
		
		# Notifica o jogador
		NotificationSystem.notify("System", "Game saved at " + formatted_time, "info")
		
		emit_signal("game_saved")
	else:
		NotificationSystem.notify("System", "Erro on saved game at " + formatted_time, "error")


# Carregar o jogo do arquivo
func load_game() -> bool:
	if FileAccess.file_exists(save_file_path):
		# Abre o arquivo no modo de leitura
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			# Lê o conteúdo do arquivo como texto
			var file_content = file.get_as_text()
			file.close()  # Fecha o arquivo após leitura
			
			# Cria o objeto JSON e tenta parsear o conteúdo
			var json = JSON.new()
			var error = json.parse(file_content)
			if error == OK:
				var data = json.data
				if typeof(data) == TYPE_DICTIONARY:
					load_save_data(data)  # Carrega os dados do save
					emit_signal("game_loaded")  # Emite o sinal de jogo carregado
					return true
				else:
					print("Dados de salvamento inválidos!")
			else:
				print("Erro ao parsear JSON:", json.get_error_message())
		else:
			print("Erro ao abrir o arquivo:", save_file_path)
	else:
		print("Arquivo de salvamento não encontrado:", save_file_path)
	return false


func l_save_timer() -> void:
	await get_tree().create_timer(60 * save_timer).timeout
	save_game()
	l_save_timer()
