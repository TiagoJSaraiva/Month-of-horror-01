class_name CardPool
extends Resource
## As cartas com que cada run começa e as chances de raridade de cada carta da seleção.

@export var cards: Array[CardData] = []
@export var common_chance: float = 0.6
@export var rare_chance: float = 0.3
## Cartas por seleção.
@export var selection_size: int = 3
