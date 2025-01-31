extends Control

@export var save_file_path : String = "user://save_data.json"  # Caminho do arquivo de save
@export var gameplay_scene_path : String = "res://Scenes/gameplay.tscn"  # Cena do gameplay
@export var loading_commands : Array = [  # Comandos fictícios para exibição
	"Loading Universal Operating System...",
	"Initializing Quantum Processes...",
	"Connecting to Infinite Realities...",
	"Done."
]
@export var command_delay : float = 1.0  # Intervalo entre os comandos
@export var minimum_loading_time : float = 5.0  # Tempo mínimo de *loading*

@export var loading_sound : AudioStreamPlayer2D
@export var change_command_sound : AudioStreamPlayer2D

# Nó para exibir os comandos
@export var command_label : Label 

# Variáveis internas
var _loading_finished : bool = false
var _animation_finished : bool = false

func _ready() -> void:
	# Inicia a sequência de comandos fictícios
	start_loading_animation()
	
	# Inicia o processo de carregamento do jogo
	load_game_async()
	
	loading_sound.play()
	# Espera o som de carregamento terminar antes de continuar 
	await get_tree().create_timer(loading_sound.stream.get_length()).timeout

# Exibe os comandos fictícios com atraso
func start_loading_animation() -> void:
	var tween = create_tween()
	var total_delay = 0.0
	for command in loading_commands:
		total_delay += command_delay
		tween.tween_callback(Callable(self, "_display_command").bind(command)).set_delay(total_delay)

	# Adiciona um callback final para quando a animação terminar
	tween.tween_callback(Callable(self, "_on_animation_finished")).set_delay(total_delay)


# Mostra cada comando na tela
func _display_command(command : String) -> void:
	command_label.text += command + "\n"
	change_command_sound.play()

# Marca o fim da animação de *loading*
func _on_animation_finished() -> void:
	_animation_finished = true
	_check_loading_complete()

# Carrega o jogo de forma assíncrona
func load_game_async() -> void:
	await get_tree().create_timer(minimum_loading_time).timeout  # Espera o tempo mínimo
	var loaded = await global.load_game()  # Chama a função de carregamento no Global
	if loaded:
		_loading_finished = true
		_check_loading_complete()
	else:
		print("Erro ao carregar o jogo!")

# Verifica se pode avançar para a próxima cena
func _check_loading_complete() -> void:
	if _loading_finished and _animation_finished:
		change_to_gameplay()

# Troca para a cena de gameplay
func change_to_gameplay() -> void:
	if gameplay_scene_path:
		GameManagement.go_to_scene(gameplay_scene_path)
	else:
		print("Erro ao carregar a cena de gameplay:", gameplay_scene_path)
