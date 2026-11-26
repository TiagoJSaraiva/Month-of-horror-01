class_name Hands
extends Node3D
## Coordena as mãos do jogador: troca a ferramenta da mão direita (1 vara, 2 revólver), abre e
## fecha o diário, carrega e larga itens. A vara e o revólver consultam [member state] antes de
## agir.

signal changed
signal item_dropped(item: ItemData, amount: int, at: Vector3)

@export var journal: Journal
## Lanterna da mão esquerda. As Hands não a usam: ela fica aqui para objetos com que o
## jogador interage, como a caixa de pilhas, chegarem a ela.
@export var flashlight: Flashlight
## Distância à frente do jogador em que o item largado cai, em metros.
@export var drop_distance: float = 0.7
## Até quantos metros abaixo das mãos procurar o convés.
@export var drop_probe_depth: float = 3.0

var state: HandsState = HandsState.new()

@onready var _carried_item_model: MeshInstance3D = $CarriedItemModel


## Avisa se falta o Journal e sincroniza o diário e o item carregado com o estado.
func _ready() -> void:
	if journal == null:
		push_warning("Hands sem Journal: o Tab não abre o diário.")
	state.changed.connect(_on_state_changed)
	_on_state_changed()


## Tab abre ou fecha o diário (abrir só sem item e sem linha na água); 1 e 2 trocam a ferramenta; a
## tecla de largar solta o item carregado.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_journal"):
		state.toggle_journal()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"equip_rod"):
		state.select_tool(HandsState.Tool.ROD)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"equip_revolver"):
		state.select_tool(HandsState.Tool.REVOLVER)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"drop_item") and state.is_carrying():
		_drop_carried_item()
		get_viewport().set_input_as_handled()


## Passa a carregar um item. Devolve false quando as mãos não estão livres.
func carry_item(item: ItemData, amount: int = 1) -> bool:
	return state.start_carrying(item, amount)


## Esvazia as mãos e avisa pelo sinal item_dropped onde o item cai.
func _drop_carried_item() -> void:
	var item: ItemData = state.carried_item
	var amount: int = state.carried_amount
	state.stop_carrying()
	item_dropped.emit(item, amount, _drop_point())


## Devolve onde o item cai: o convés à frente ou, além da amurada, aos pés.
func _drop_point() -> Vector3:
	var forward: Vector3 = -global_basis.z
	forward.y = 0.0
	if forward.length() > 0.1:
		var ahead: Vector3 = global_position + forward.normalized() * drop_distance
		var deck_ahead: Variant = _deck_below(ahead)
		if deck_ahead != null:
			return deck_ahead
	var deck_below: Variant = _deck_below(global_position)
	return deck_below if deck_below != null else global_position


## Devolve o ponto do convés logo abaixo de from, ou null se não houver convés dentro de
## drop_probe_depth.
func _deck_below(from: Vector3) -> Variant:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		from, from + Vector3.DOWN * drop_probe_depth, PhysicsLayers.WORLD
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit["position"]


## Abre ou fecha o diário, mostra ou esconde o item carregado e repassa o aviso changed.
func _on_state_changed() -> void:
	if journal != null:
		if state.mode == HandsState.Mode.JOURNAL:
			journal.open()
		else:
			journal.close()
	_carried_item_model.mesh = state.carried_item.held_mesh if state.is_carrying() else null
	_carried_item_model.visible = state.is_carrying()
	changed.emit()
