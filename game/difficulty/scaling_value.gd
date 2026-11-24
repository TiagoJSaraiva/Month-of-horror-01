class_name ScalingValue
extends Resource
## Um valor que muda a cada noite: vale [member first_night_value] na noite 1, soma
## [member per_night] a cada noite seguinte e para em [member limit] (máximo quando cresce,
## mínimo quando cai).

@export var first_night_value: float = 1.0
@export var per_night: float = 0.0
@export var limit: float = 1.0
