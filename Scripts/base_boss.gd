extends Control

@export var eye_base: TextureRect  # Parte branca do olho
@export var iris: TextureRect  # Íris do olho
@export var float_amplitude: float = 5.0  # Amplitude do movimento de flutuação
@export var float_speed: float = 2.0  # Velocidade do movimento de flutuação
@export var iris_follow_mouse: bool = true  # A íris segue o mouse?
@export var iris_speed: float = 5.0  # Velocidade do movimento da íris
@export var iris_range: float = 8.0  # Raio máximo que a íris pode se mover
@export var shake_intensity: float = 3.0  # Intensidade do tremor
@export var shake_duration: float = 0.5  # Duração do tremor
@export var stop_interval_min: float = 5.0  # Tempo mínimo entre interrupções do olho
@export var stop_interval_max: float = 10.0  # Tempo máximo entre interrupções do olho
@export var sound: AudioStreamPlayer2D  # Som que será tocado
@export var messages: Array[String] = []  # Lista de mensagens para notificação

var float_offset: float = randf() * TAU  # Offset aleatório para a flutuação
var is_paused: bool = false
var shake_timer: float = 0.0
var next_pause_time: float = 0.0
var initial_eye_position: Vector2  # Posição inicial do olho
var initial_iris_position: Vector2  # Posição inicial da íris

func _ready():
	randomize()  # Define uma semente aleatória para o gerador de números
	initial_eye_position = eye_base.global_position
	initial_iris_position = iris.global_position
	next_pause_time = randf_range(stop_interval_min, stop_interval_max)

func _process(delta):
	if is_paused:
		if shake_timer > 0:
			shake_timer -= delta
			# Aplica o tremor ao olho
			eye_base.global_position = initial_eye_position + Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
		else:
			eye_base.global_position = initial_eye_position  # Volta ao normal após o tremor
		return

	# Movimento de flutuação suave
	var y_offset = sin(Time.get_ticks_msec() * 0.001 * float_speed + float_offset) * float_amplitude
	eye_base.global_position.y = initial_eye_position.y + y_offset  # Move a base do olho suavemente

	# Definir centro do olho corretamente
	var eye_center = eye_base.global_position + (eye_base.size / 2.0)

	# Calcular a posição alvo da íris
	var target_offset: Vector2
	if iris_follow_mouse:
		var mouse_pos = get_viewport().get_mouse_position()
		target_offset = (mouse_pos - eye_base.global_position - (eye_base.size / 2)).limit_length(iris_range)
	else:
		target_offset = Vector2(iris_range, 0)  # Sempre olha para a direita

	# Move a íris suavemente para o alvo dentro do limite
	iris.global_position = iris.global_position.lerp(eye_center + target_offset - (iris.size / 2.0), delta * iris_speed)

	# Checa se é hora de pausar
	next_pause_time -= delta
	if next_pause_time <= 0:
		trigger_pause()

func trigger_pause():
	is_paused = true
	shake_timer = shake_duration  # Define o tempo do tremor
	next_pause_time = randf_range(stop_interval_min, stop_interval_max)  # Define o próximo tempo de pausa aleatório

	# Íris olha para frente
	iris.global_position = initial_iris_position

	# Toca o som (se existir)
	if sound:
		sound.play()

	# Envia a notificação com uma mensagem aleatória (se houver mensagens configuradas)
	if messages.size() > 0:
		var index = randi_range(0, messages.size() - 1)
		var message = messages[index]
		NotificationSystem.notify("The Boss", message, "boss")
		

	# Espera um tempo e volta ao normal
	await get_tree().create_timer(shake_duration + 0.5).timeout
	is_paused = false
