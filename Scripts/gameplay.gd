extends Control

@onready var popup_main_bar = $Main/main_panel/PopupBar
@onready var label_bar_points = $Main/top_bar/lblProgressBarPoints
@onready var label_infinit_bar_points = $Main/top_bar/lblInfinitBarPoints
@onready var auto_bars_container = $Main/main_panel/AutoBarsContainer

@export var button_reset : Button
@export var audio_music : AudioStreamPlayer2D

@onready var upgrade_control = $Main/rigth_panel


func _ready():
	# Play music
	audio_music.play()
	popup_main_bar.bar_full.connect(add_point_bar)
	upgrade_control.new_bar.connect(connect_new_bar)
	upgrade_control.upgrade_purchased.connect(_update_ui)
	button_reset.pressed.connect(go_to_reset_scene)
	# Conecta dinamicamente as barras automáticas já existentes (no caso de estar carregando o jogo)
	for bar in auto_bars_container.get_children():
		bar.bar_full.connect(add_point_bar)
	
	_update_ui()
	global.l_save_timer() # Start saver timer
	
func add_point_bar(point):
	global.increment_points(point)
	_update_ui()
	
func sub_point_bar(point):
	global.decrement_points(point)
	_update_ui()
	
func _update_ui():
	label_bar_points.text = "/bars: " + str(global.points_bar)
	label_infinit_bar_points.text = "/infinit/bars: " + str(global.reset_points)

# Função chamada ao adicionar novas barras
func connect_new_bar(bar):
	bar.bar_full.connect(add_point_bar)
	bar.buy_upgrade.connect(sub_point_bar)
	
func go_to_reset_scene():
	GameManagement.go_to_scene("res://scenes/reset_upgrad_scene.tscn")
