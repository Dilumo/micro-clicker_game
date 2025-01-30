extends Control

@export var label_infinit_bar : Label
@export var node_upgrades : GridContainer
@export var button_continue : Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_infinit_bar.text =  "/infinit/bars: " + str(global.reset_points)
	button_continue.pressed.connect(_continue_button_cliked)
	EffectSystem.end_game.connect(call_endgame)
	for upgrade in node_upgrades.get_children():
		upgrade.upgrade_purchased.connect(upgrade_purchased)
		
# Called to update points and UI
func upgrade_purchased() -> void:
	label_infinit_bar.text =  "/infinit/bars: " + str(global.reset_points)

func _continue_button_cliked() -> void:
	global.reboot_resets()
	GameManagement.go_to_scene("res://scenes/gameplay.tscn")
	
func call_endgame() -> void:
	GameManagement.go_to_scene("res://scenes/endgame.tscn")
