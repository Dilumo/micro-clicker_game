extends Node

# Armazena o estado dos upgrades como um dicionário
var upgrades_state: Dictionary = {}

# Inicializa o estado dos upgrades
func initialize_upgrades(upgrades_data: Array):
	for upgrade in upgrades_data:
		if upgrade.name not in upgrades_state:
			upgrades_state[upgrade.name] = false  # Padrão: não comprado

# Marca um upgrade como comprado
func purchase_upgrade(upgrade_name: String):
	upgrades_state[upgrade_name] = true

# Verifica se um upgrade foi comprado
func is_upgrade_purchased(upgrade_name: String) -> bool:
	return upgrades_state.get(upgrade_name, false)
