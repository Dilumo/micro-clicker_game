extends Control

@export var fade_in : ColorRect  
@export var shader_layer : ColorRect # Nó ColorRect com o shader vinculado
@export var noise_intro : AudioStreamPlayer2D
@export var effect_intro : AudioStreamPlayer2D
@export var end_effect_intro : AudioStreamPlayer2D

# Configurações do shader
@export var initial_transition_speed : float = 10.0  # Velocidade inicial do shader
@export var normal_transition_speed : float = 0.5  # Velocidade final normal
@export var initial_grain_scale : float = 5.0  # Escala inicial do grain
@export var normal_grain_scale : float = 1.0  # Escala final normal
@export var transition_duration : float = 3.0  # Duração para ajustar os valores

# Controle interno dos valores do shader
@export var _shader_speed: float = 0.5
@export var _grain_scale: float = 1.0

# Duração do fade-in em segundos
@export var fade_duration : float = 6.0
@export var start_effect_sound : float = 5.0

func _ready() -> void:
	# Ajusta os valores iniciais do shader
	adjust_shader_speed(initial_transition_speed)
	adjust_grain_scale(initial_grain_scale)
	
	# Gradualmente retorna os valores normais
	transition_shader_speed(normal_transition_speed, transition_duration)
	transition_grain_scale(normal_grain_scale, transition_duration)
	
	# Inicia o fade-in
	l_fade_in()
	
	# Toca o som inicial
	noise_intro.play()
	await get_tree().create_timer(start_effect_sound).timeout
	
	# Toca o efeito intermediário
	effect_intro.play()
	await effect_intro_finished()
	
	# Toca o som final
	end_effect_intro.play()
	if has_save_file():
		GameManagement.go_to_scene("res://Scenes/loading.tscn")
	else:
		GameManagement.go_to_scene("res://Scenes/main.tscn")

# Verifica se o arquivo de save existe
func has_save_file() -> bool:
	return FileAccess.file_exists(global.save_file_path)

# Função para fazer o fade-in
func l_fade_in() -> void:
	# Define a cor inicial como preto com opacidade total
	fade_in.color = Color(0, 0, 0, 1)
	
	# Cria o tween para ajustar o canal alfa (fade-in)
	var tween = create_tween()
	tween.tween_property(fade_in, "color:a", 0.0, fade_duration)

# Espera o som `effect_intro` terminar
func effect_intro_finished() -> void:
	await get_tree().create_timer(effect_intro.stream.get_length()).timeout

# Ajusta diretamente a velocidade do shader no ColorRect
func adjust_shader_speed(speed: float) -> void:
	if shader_layer.material and shader_layer.material is ShaderMaterial:
		shader_layer.material.set_shader_parameter("TransitionSpeed", speed)
	else:
		print("ColorRect material not found or not a ShaderMaterial!")

# Ajusta diretamente o grain scale no shader
func adjust_grain_scale(scale: float) -> void:
	if shader_layer.material and shader_layer.material is ShaderMaterial:
		shader_layer.material.set_shader_parameter("GrainScale", scale)
	else:
		print("ColorRect material not found or not a ShaderMaterial!")

# Gradualmente ajusta a velocidade do shader
func transition_shader_speed(target_speed: float, duration: float) -> void:
	if shader_layer.material and shader_layer.material is ShaderMaterial:
		var tween = create_tween()
		tween.tween_property(self, "_shader_speed", target_speed, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	else:
		print("ColorRect material not found or not a ShaderMaterial!")

# Gradualmente ajusta o grain scale do shader
func transition_grain_scale(target_scale: float, duration: float) -> void:
	if shader_layer.material and shader_layer.material is ShaderMaterial:
		var tween = create_tween()
		tween.tween_property(self, "_grain_scale", target_scale, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	else:
		print("ColorRect material not found or not a ShaderMaterial!")

# Atualiza o valor do TransitionSpeed no shader
func set_shader_speed(value: float) -> void:
	_shader_speed = value
	fade_in.material.set_shader_parameter("TransitionSpeed", value)

# Atualiza o valor do GrainScale no shader
func set_grain_scale(value: float) -> void:
	_grain_scale = value
	fade_in.material.set_shader_parameter("GrainScale", value)
