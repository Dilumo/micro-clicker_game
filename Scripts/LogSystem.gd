extends Control

@export var max_messages: int = 10  # Número máximo de mensagens exibidas
@export var log_container : VBoxContainer  # Referência ao VBoxContainer onde as mensagens serão exibidas
@export var system_song : AudioStreamPlayer2D
@export var message_scene: PackedScene  # Referência à cena que representa uma mensagem (Label ou customizado)



# Paleta de cores para diferentes emissores
var log_colors = {
	"system" : Color(0.8, 0.8, 0.8),  # Cinza claro
	"boss"   : Color(1, 0.2, 0.2),  # Intense red
	"alert"  : Color(1, 1, 0),   # yellow
	"error"  : Color(1, 0, 0), # red 
	"info"   : Color(0.2, 0.6, 1), # light blue
	"unlock" : Color(0.2, 1, 0.2) # green
}

func _ready():
	if NotificationSystem:
		NotificationSystem.notify_message.connect(add_message)

func add_message(sender: String, message: String, message_type: String) -> void:
	# Instancia uma nova mensagem baseada na cena
	var message_instance = message_scene.instantiate()
	
	# Verifica se a instância é de um RichTextLabel para evitar erros
	if message_instance is RichTextLabel:
		message_instance.bbcode_enabled = true  # Ativa BBCode
		# Define o texto com cor e negrito usando BBCode
		var color = log_colors.get(message_type, Color(1, 1, 1)).to_html()
		var bbcode_text = "[[b][color=#" + color + "]" + sender + "[/color][/b]]: [color=#" + color + "]" + message + "[/color]"
		message_instance.text  = bbcode_text 
		
		# Cria o tween para ajustar o canal alfa (fade-in)
		var tween = create_tween()
		tween.tween_property(message_instance, "modulate:a", 1, 0.5)
		
		system_song.play()
	
		# Adiciona a nova mensagem ao container no início (topo)
		log_container.call_deferred("add_child", message_instance)

	# Remove mensagens antigas se exceder o limite
	if log_container.get_child_count() > max_messages:
		log_container.get_child(0).queue_free()
