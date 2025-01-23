extends Control

signal _open_message_ballon

@onready var popup_bar = $Panel/PopupBar
@onready var bg_window_error = $Panel/bg_windowError
@onready var bnt_next = $Panel/bg_windowError/btnClickToNext

@onready var ballon_message = $Panel/MessageBallon

var is_done_pressed : bool

func _ready():
	bg_window_error.visible = false  # Certifique-se de que o erro está oculto
	popup_bar.done_button_pressed.connect(on_done_button_pressed)
	popup_bar.progress_completed.connect(on_complet_progress)
	bnt_next.pressed.connect(transition_to_gameplay)
	# Dispara o sinal após 5 segundos
	await get_tree().create_timer(5.0).timeout
	_on_open_message_ballon()

func on_complet_progress():
	ballon_message.no_need_more_message = true
	if ballon_message.is_open:
		ballon_message.hide_message()

func on_done_button_pressed():
	# Mostra a mensagem de erro
	bg_window_error.visible = true
	popup_bar.visible = false
	ballon_message.visible = false
	is_done_pressed = true
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and is_done_pressed:
			transition_to_gameplay()

func transition_to_gameplay():
	# Troca para a cena de gameplay
	GameManagement.go_to_scene("res://scenes/gameplay.tscn")
	
func _on_open_message_ballon():
	#ballon_message.rect_position = Vector2(50, 50)  # Ajuste a posição conforme necessário
	ballon_message.show_message()
