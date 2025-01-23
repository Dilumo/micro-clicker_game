extends Resource
class_name UpgradeData

@export var name: String
@export var icon : Texture2D
@export var cost: int
@export var base_cost: int
@export var cost_growth: float
@export var description: String
@export var effect_type: String
@export var effect_value: float
@export var base_effect: float
@export var effect_growth: float
@export var unlock_condition: String

# In case that type effect is new_bar
@export var new_bar_data : AutoBarData
