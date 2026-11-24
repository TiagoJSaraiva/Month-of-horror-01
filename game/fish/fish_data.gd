class_name FishData
extends Resource
## Uma espécie de peixe. Novas espécies entram como novos .tres, sem mudar código.

@export var id: StringName
@export var display_name: String

@export_group("Fishing")
## Intervalo, em segundos, entre o lançamento e a mordida.
@export var bite_delay_min: float = 2.0
@export var bite_delay_max: float = 5.0
## Velocidade do peixe no trilho do minijogo, em trilhos por segundo.
@export var swim_speed: float = 0.35
## Quantas vezes por segundo, em média, o peixe escolhe um novo destino no trilho.
@export var direction_changes_per_second: float = 0.8
