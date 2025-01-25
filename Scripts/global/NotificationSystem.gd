extends Node


signal notify_message(sender: String, message: String, message_type: String)

# Emite uma notificação com o remetente, mensagem e tipo
func notify(sender: String, message: String, message_type: String) -> void:
	emit_signal("notify_message", sender, message, message_type)
