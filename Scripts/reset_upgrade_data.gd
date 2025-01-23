extends Resource

class_name ResetUpgradeData

@export var name: String
@export var cost: int
@export var icon: Texture2D
@export var prerequisites: Array[ResetUpgradeData] = []

# Lista de efeito
@export var effects: Array[Dictionary] = []

# Atualiza a descrição com base nos efeitos
func create_effect_description() -> String:
	var descriptions = []
	for effect in effects:
		var effect_name = EffectSystem.get_readable_effect_name(effect["type"])
		var effect_value = effect["value"]
		descriptions.append("%s: +%s" % [effect_name, effect_value])
	return "%s\n---\n%s" % [name, "\n".join(descriptions)]
