extends Node2D

class_name UpgradeNode

# Dados do upgrade
@export var upgrade_data: ResetUpgradeData
@onready var button_buy = $btn_buy as Button
@onready var lock_icon = $locked_icon as TextureRect
@onready var name_upgrade = $upgrade_name as Label
@onready var glow_effect = $glow_effect as TextureRect
@onready var upgrade_icon = $"upgrade_icon" as TextureRect

@export var tooltip : Control

# Referências visuais
@export var unlocked_color: Color = Color.GREEN
@export var locked_color: Color = Color.GRAY
@export var unlock_icon : Texture2D

# Estado do upgrade
var is_purchased: bool = false

# Sinais
signal upgrade_purchased(coust: int)

func _ready() -> void:
	# Inicializa o nó com os dados do UpgradeData
	if upgrade_data:
		name_upgrade.text = upgrade_data.name
		upgrade_icon.texture = upgrade_data.icon

	is_purchased =  GlobalUpgrades.is_upgrade_purchased(upgrade_data.name)

	button_buy.pressed.connect(purchase_upgrade)
	button_buy.mouse_entered.connect(_on_button_hover)
	button_buy.mouse_exited.connect(_on_button_exit)

func can_purchase(reset_points: int) -> bool:
	# Verifica se os pré-requisitos foram comprados e se há pontos suficientes
	for prerequisite_data in upgrade_data.prerequisites:
		var prerequisite_node = find_upgrade_node(prerequisite_data)
		if prerequisite_node == null or not prerequisite_node.is_purchased:
			return false
	return reset_points >= upgrade_data.cost

func purchase_upgrade() -> void:
	if can_purchase(global.reset_points):  # Apenas para teste
		global.decrement_reset_point(upgrade_data.cost)
		is_purchased = true
		for effect in upgrade_data.effects:
			EffectSystem.apply_effect(effect["type"], effect["value"].to_float())
		GlobalUpgrades.purchase_upgrade(upgrade_data.name)
		emit_signal("upgrade_purchased")
		update_visual_state()
	else:
		print("Não é possível comprar este upgrade.")

func update_visual_state() -> void:
	# Atualiza indicadores visuais com base no estado
	lock_icon.visible = not is_purchased
	glow_effect.visible = is_purchased
	#button_buy.disabled = is_purchased
	button_buy.icon = unlock_icon

func find_upgrade_node(data: ResetUpgradeData) -> UpgradeNode:
	# Busca um UpgradeNode baseado no UpgradeData
	for child in get_tree().get_nodes_in_group("UpgradeNodes"):
		if child is UpgradeNode and child.upgrade_data == data:
			return child
	return null

func _on_button_hover()->void:
	# Exibe tooltip com informações do upgrade
	tooltip.visible = true
	tooltip.set_text(upgrade_data.create_effect_description())
	tooltip.global_position = get_global_mouse_position() + Vector2(10, 10)
	
func _on_button_exit()->void:
	tooltip.visible = false
