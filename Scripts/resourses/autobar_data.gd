extends Resource

class_name AutoBarData

@export var file_path : String # Caminho do arquivo
@export var bar_name : String = "how is there?" # Nome da barra
@export var bar_descripiton : String = "what do you do?" # Descrição da barra
@export var sub_descriptions : Array[String]
@export var illustration : Texture

@export var base_speed: float = 5.0  # Tempo para preencher a barra
@export var points_per_cycle: int = 1  # Pontos ganhos ao completar a barra
@export var upgrade_cost: int = 50  # Custo inicial do upgrade
@export var speed_increase: float = 0.9  # Fator multiplicativo para velocidade
@export var points_increase: int = 5  # Pontos extras por upgrade
@export var max_progress: int = 100  # Valor máximo da barra
