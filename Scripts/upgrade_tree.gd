extends Control

func _ready():
	# Conecta os sinais de cada upgrade e desenha as conexões
	for child in $Upgrades.get_children():
		if child is UpgradeNode:
			child.upgrade_purchased.connect(_on_upgrade_purchased)
	draw_connections()

func _on_upgrade_purchased():
	draw_connections()

# Atualiza as conexões entre os upgrades
func draw_connections():
	# Remove linhas antigas
	#$Connections.clear()

	# Cria novas linhas para cada conexão
	for upgrade in $Upgrades.get_children():
		if upgrade is UpgradeNode:
			for prerequisite_data in upgrade.upgrade_data.prerequisites:
				# Busca o nó do pré-requisito correspondente ao UpgradeData
				var prerequisite_node = find_upgrade_node(prerequisite_data)
				if prerequisite_node:
					var line = Line2D.new()
					line.default_color = prerequisite_node.unlocked_color if prerequisite_node.is_purchased else prerequisite_node.locked_color
					line.points = [prerequisite_node.position, upgrade.position]
					$Connections.add_child(line)

func find_upgrade_node(data: ResetUpgradeData) -> UpgradeNode:
	# Busca um UpgradeNode baseado no UpgradeData
	for child in $Upgrades.get_children():
		if child is UpgradeNode and child.upgrade_data == data:
			return child
	return null
