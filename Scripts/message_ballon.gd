extends Control

@export var title: String = "Notification"
@export var message: String = "Click on the loading popup to continue!"

@onready var title_label = $Panel/Ballon/lblTitle
@onready var message_label = $Panel/Ballon/lblMessage
@onready var close_button = $Panel/Ballon/btnClose

var is_open = false
var no_need_more_message = false

# Configuração inicial
func _ready():
	title_label.text = title
	message_label.text = message
	close_button.pressed.connect(hide_message)
	hide()  # Inicialmente invisível

# Exibe o balão com animação
func show_message():
	if no_need_more_message: return
	visible = true
	is_open = true
	modulate = Color(1, 1, 1, 0)  # Transparente
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)  # Fade-in

func hide_message():
	modulate = Color(1,1,1,1)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)  # Fade-out
	is_open = false
