class_name ItemData
extends Resource
## Algo que o jogador carrega com as duas mãos: um peixe, um galão, uma lâmpada de reposição.
## Itens novos entram como novos .tres.

@export var id: StringName
@export var display_name: String
## Malha mostrada nas mãos do jogador e no convés quando o item é largado.
@export var held_mesh: Mesh
