extends Control

# Sinal para quando a barra for concluída
signal bar_full

@export var max_progress: float = 100 # Progresso máximo da barra
var current_progress: float = 0 # Progresso atual

@export var bar : TextureRect
@export var progress_bar : TextureRect
@export var progress_button : Button
@export var progres_brightness : TextureRect 
@export var description_values : Label


@export var audio_click : AudioStreamPlayer2D
@export var audio_critical : AudioStreamPlayer2D
@export var shader_bar : ShaderMaterial

@onready var floating_number_scene = preload("res://Scenes/floating_number.tscn")

var original_position: Vector2
var original_color: Color

# Chamado ao iniciar
func _ready():
	original_position = bar.position
	original_color = bar.modulate
	reset_bar()
	EffectSystem.main_bar_update.connect(update_description_values)
	progress_button.pressed.connect(_on_progress_button_pressed)

# Reseta a barra de progresso
func reset_bar():
	current_progress = 0
	update_description_values()
	update_bar()

# Atualiza visualmente a barra de progresso
func update_bar():
	var percentage = clamp(current_progress / max_progress, 0, 1) # Garante que esteja entre 0 e 1
	progress_bar.scale.x = percentage # Atualiza a escala horizontal
	 # Ajusta o brilho
	progres_brightness.scale.x = percentage
	if percentage >= 1.0:
		on_bar_full()
	shader_bar.set_shader_parameter("progress", percentage)

# Evento ao pressionar o botão
func _on_progress_button_pressed():
	if current_progress < max_progress:
		current_progress += global.get_final_main_bar_speed()  # Incrementa linearmente
		current_progress = clamp(current_progress, 0, max_progress) # Incrementa o progresso ao clicar
		global.increment_clicks()
		flash_effect()
		shake_effect()
		update_bar()
		audio_click.play()

func show_floating_number(value: int, position: Vector2, critical : bool = false):
	var floating_number = floating_number_scene.instantiate()
	if critical:
		floating_number.modulate = Color.FIREBRICK
	add_child(floating_number)
	floating_number.show_number(value, position)


# Quando a barra é preenchida
func on_bar_full():
	current_progress = 0
	var base_points = global.get_final_main_bar_points() 

	# Check for critical hit
	var critical_hit = randf() < global.get_critical_hit_main_bar()

	# Calculate points with critical hit
	var points = base_points 
	if critical_hit:
		points *= 2
		audio_critical.play()

	# Emit signal with calculated points
	emit_signal("bar_full", points)
	await get_tree().create_timer(0.1).timeout
	progress_bar.scale.x = 0
	progres_brightness.scale.x = 0
	# Mostrar número flutuante
	show_floating_number(points, get_global_mouse_position(), critical_hit)

# Evento ao pressionar o botão "Done"
func _on_done_button_pressed():
	if current_progress >= max_progress:
		emit_signal("done_button_pressed")
	else:
		# Caso clique antes de carregar, funciona como botão de progresso
		_on_progress_button_pressed()
		
func update_description_values():
	description_values.text = "bar/complited : " + str(global.get_final_main_bar_points()) + "............................bar/progress/click: " + str(global.get_final_main_bar_speed()) + "%."

# shinny effect
func flash_effect():
	bar.modulate = Color(1, 1, 1, 0.8) # Breve mudança de opacidade ou cor
	await get_tree().create_timer(0.1).timeout
	bar.modulate = original_color

# Shack effect
func shake_effect():
	for i in range(5): # Número de tremores
		bar.position.x += 1 # Move para a direita
		await get_tree().create_timer(0.02).timeout
		bar.position.x -= 2 # Move para a esquerda
		await get_tree().create_timer(0.02).timeout
		bar.position.x += 1 # Volta para o centro
	bar.position = original_position # Restaura posição original
