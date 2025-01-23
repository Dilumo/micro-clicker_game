extends Control

# Sinal para quando a barra for concluída
signal bar_full
signal done_button_pressed
signal progress_completed

@export var max_progress: float = 100  # Progresso máximo da barra
@export var adictional_progress: float = 5    # Incrementa o progresso ao clicar
var current_progress: float = 0       # Progresso atual

@onready var progress_bar = $Panel/txtuBarBackgroung/txtuProgressBar
@onready var progress_button = $Panel/btnClick
@onready var label = $Panel/lblMessage

@onready var button_done = $Panel/btnDone
@onready var label_done = $Panel/btnDone/lblButton

@export var audio_click : AudioStreamPlayer2D

var original_position : Vector2
var original_color : Color

# Chamado ao iniciar
func _ready():
	original_position = position
	original_color = modulate
	reset_bar()
	progress_button.pressed.connect(_on_progress_button_pressed)
	button_done.pressed.connect(_on_done_button_pressed)

# Reseta a barra de progresso
func reset_bar():
	current_progress = 0
	update_bar()

# Atualiza visualmente a barra de progresso
func update_bar():
	var percentage = current_progress / max_progress
	progress_bar.scale.x = percentage  # Escala horizontal
	if percentage >= 1.0:
		on_bar_full()

# Evento ao pressionar o botão
func _on_progress_button_pressed():
	if current_progress < max_progress:
		current_progress += adictional_progress
		flash_effect()
		shake_effect()
		update_bar()
		audio_click.play()

# Quando a barra é preenchida
func on_bar_full():
	progress_button.disabled = true
	label.text = "Game loaded!"
	emit_signal("bar_full")
	update_done_button()

# Atualiza o estado visual e funcional do botão "Done"
func update_done_button():
	if current_progress >= max_progress:
		label_done.modulate = Color(0.01, 0.01, 0.01)  # Preto ativo
		emit_signal("progress_completed")
	else:
		label_done.modulate = Color(0.5, 0.5, 0.5)  # Cinza desativado

# Evento ao pressionar o botão "Done"
func _on_done_button_pressed():
	if current_progress >= max_progress:
		emit_signal("done_button_pressed")
	else:
		# Caso clique antes de carregar, funciona como botão de progresso
		_on_progress_button_pressed()

# Efeito de "piscada"
func flash_effect():
	modulate = Color(1, 1, 1, 0.8)  # Breve mudança de opacidade ou cor
	await get_tree().create_timer(0.1).timeout
	modulate = original_color

# Efeito de "sacudida"
func shake_effect():
	for i in range(5):  # Número de tremores
		position.x += 1  # Move para a direita
		await get_tree().create_timer(0.02).timeout
		position.x -= 2  # Move para a esquerda
		await get_tree().create_timer(0.02).timeout
		position.x += 1  # Volta para o centro
	position = original_position  # Restaura posição original
