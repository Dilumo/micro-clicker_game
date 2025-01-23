extends Control

@export var float_duration: float = 1.0 # Duração do efeito
@export var float_distance: float = 50.0 # Distância que o número sobe
@export var random_offset_range: float = 50.0 # Alcance do deslocamento aleatório
@export var vertical_offset: float = -100.0  # Offset adicional para ajustar a posição inicial
@onready var label = $Label

func show_number(value: int, position: Vector2):
	label.text = "+" + str(value) # Define o texto com o valor
	global_position = position + Vector2(
		randf_range(-random_offset_range, random_offset_range),
		randf_range(-random_offset_range, random_offset_range) + vertical_offset
	) # Adiciona um deslocamento aleatório à posição inicial
	fade_and_float()


# Função que controla o movimento e desaparecimento
func fade_and_float():
	var start_position = global_position
	var end_position = global_position - Vector2(0, float_distance)

	for i in range(float_duration * 60): # Aproximadamente 60fps
		var t = i / (float_duration * 60)
		global_position = lerp(start_position, end_position, t) # Movimenta o número
		modulate.a = lerp(1, 0, t) # Gradualmente desaparece
		await get_tree().create_timer(1 / 60.0).timeout

	queue_free() # Remove o número da cena após a animação
