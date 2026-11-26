class_name SupplyCrate
extends Interactable
## Caixa com estoque infinito de um item (galões, lâmpadas de reposição). Com as mãos livres,
## E pega um. Um exemplar do item fica em cima da caixa para mostrar o que ela guarda.

@export var item: ItemData
## Altura do tampo da caixa, onde o exemplar do item fica apoiado.
@export var lid_height: float = 0.5

@onready var _display: MeshInstance3D = $Display
@onready var _label: Label3D = $Label


## Mostra o nome e um exemplar do item em cima da caixa.
func _ready() -> void:
	if item == null:
		push_warning("SupplyCrate sem item: a caixa fica vazia.")
		return
	_label.text = item.display_name.to_upper()
	_display.mesh = item.held_mesh
	if item.held_mesh != null:
		_display.position.y = lid_height - item.held_mesh.get_aabb().position.y


## Dica de interação: pegar um item da caixa. Vazia sem item ou sem mãos livres.
func get_prompt(hands: Hands) -> String:
	if item == null or not hands.state.can_take_item():
		return ""
	return "Take %s" % item.display_name


## Coloca um exemplar do item nas mãos. O estoque nunca acaba.
func interact(hands: Hands) -> void:
	hands.carry_item(item)
