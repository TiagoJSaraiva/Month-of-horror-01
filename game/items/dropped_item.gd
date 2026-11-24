class_name DroppedItem
extends Interactable
## Item largado no convés. Pode ser pego de novo com as mãos livres.

## Definidos por quem cria o item, antes de ele entrar na árvore.
var item: ItemData
var amount: int = 1

@onready var _mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	if item != null and item.held_mesh != null:
		_mesh.mesh = item.held_mesh
		# Malhas centradas na origem afundariam no convés: apoia a base no chão.
		_mesh.position.y = -item.held_mesh.get_aabb().position.y


func get_prompt(hands: Hands) -> String:
	if item == null or not hands.state.can_take_item():
		return ""
	return "Pick up %s" % item.display_name


func interact(hands: Hands) -> void:
	if hands.carry_item(item, amount):
		queue_free()
