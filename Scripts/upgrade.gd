extends Control

signal upgrade_clicked

@export var upgrade_name: String
@export var upgrade_cost: int
@export var upgrade_description: String

@onready var label_name = $Panel/texture_bg_upgrade/label_name
@onready var label_description = $Panel/texture_bg_upgrade/label_description
@onready var button_upgrade = $Panel/texture_bg_upgrade/button_upgrade
@onready var label_cost = $Panel/texture_bg_upgrade/label_cost
@onready var warning = $Panel/warning

@export var effect_type: String  # "speed" ou "points"
@export var effect_value: float  # Valor do efeito (exemplo: +10% ou +1 ponto)

var origional_position_set =  false
var  original_position : Vector2


func _ready():
	label_name.text = upgrade_name
	label_description.text = upgrade_description
	label_cost.text = str(upgrade_cost)
	button_upgrade.pressed.connect(on_button_upgrade_pressed)

func on_button_upgrade_pressed():
	emit_signal("upgrade_clicked", upgrade_name)
	
func cant_buy_upgrade():
	if not origional_position_set:
		original_position = position
		origional_position_set = true
	
	var tween = create_tween()

	# Movimento suave para a direita e esquerda
	tween.tween_property(self, "position", original_position + Vector2(5, 0), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", original_position - Vector2(10, 0), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", original_position + Vector2(5, 0), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", original_position, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	warning.visible = true
	await get_tree().create_timer(2).timeout
	warning.visible = false
