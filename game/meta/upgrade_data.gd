class_name UpgradeData
extends Resource
## Upgrade permanente, comprado com pontos entre as runs. Cada nível soma um percentual ao
## atributo, como as cartas.

@export var id: StringName
@export var display_name: String
@export var stat: StatModifier.Stat = StatModifier.Stat.MAX_HEALTH
@export var percent_per_level: float = 10.0
@export var max_level: int = 5
## Custo do primeiro nível; cada nível seguinte custa mais (MetaRules.upgrade_cost).
@export var base_cost: int = 20
