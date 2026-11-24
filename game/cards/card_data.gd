class_name CardData
extends Resource
## Uma carta de boost. Cartas novas entram como novos .tres, sem mudar código.

enum Rarity { COMMON, RARE, LEGENDARY }

@export var id: StringName
@export var display_name: String
## Texto do efeito mostrado na seleção.
@export_multiline var description: String
@export var rarity: Rarity = Rarity.COMMON
@export var modifiers: Array[StatModifier] = []
