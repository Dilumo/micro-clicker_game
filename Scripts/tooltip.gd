extends Control

@export var padding: Vector2 = Vector2(10, 10)
@export var label : Label
@export var panel : Panel 

# Define o texto do tooltip
func set_text(text: String):
	label.text = text
	update_size()

# Ajusta o tamanho do painel com base no texto
func update_size():
	var label_size = label.get_minimum_size()
	panel.size = label_size + padding
