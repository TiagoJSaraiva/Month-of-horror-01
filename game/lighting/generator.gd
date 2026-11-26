class_name Generator
extends Interactable
## Gerador do barco, na popa. Gasta combustível funcionando e quebra por sorteio
## (MaintenanceFailures). É mantido segurando E: com o galão nas mãos, reabastece; com as mãos
## livres, conserta. A luz de status e o medidor de combustível mostram o estado de longe.

signal running_changed(running: bool)

@export var fuel_can: ItemData
## Quanto dura o tanque cheio, em segundos de funcionamento.
@export var fuel_capacity_seconds: float = 150.0
@export var refuel_seconds: float = 3.0
@export var repair_seconds: float = 4.0
@export var running_color: Color = Color(0.2, 1.0, 0.3)
@export var broken_color: Color = Color(1.0, 0.15, 0.1)
@export var out_of_fuel_color: Color = Color(0.1, 0.1, 0.1)

## Criado no _ready, com a capacidade do inspetor.
var state: GeneratorState
## Multiplica os tempos de reabastecer e consertar (bônus da run: 0,5 é a metade).
var hold_multiplier: float = 1.0

var _status_material: StandardMaterial3D = StandardMaterial3D.new()

@onready var _status_lamp: MeshInstance3D = $StatusLamp
@onready var _fuel_fill: Node3D = $FuelGauge/Fill


## Cria o GeneratorState com a capacidade do inspetor e prepara a luz de status.
func _ready() -> void:
	if fuel_can == null:
		push_warning("Generator sem fuel_can: o gerador não pode ser reabastecido.")
	state = GeneratorState.new(fuel_capacity_seconds)
	state.running_changed.connect(_on_state_running_changed)
	# Sem sombreamento, para a luz de status ser vista de longe no escuro.
	_status_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_status_lamp.material_override = _status_material
	_refresh_status()


## Gasta combustível e ajusta a barra do medidor, escondida com o tanque vazio.
func _process(delta: float) -> void:
	state.consume(delta)
	var fuel: float = state.fuel_ratio()
	# Escala zero deixaria a base do nó degenerada: com o tanque vazio, a barra só some.
	_fuel_fill.visible = fuel > 0.0
	if fuel > 0.0:
		_fuel_fill.scale.x = fuel


## O gerador está funcionando: tem combustível e não está quebrado.
func is_running() -> bool:
	return state.is_running()


## Quebra o gerador e atualiza a luz de status; se ele deixa de funcionar, emite running_changed.
func break_down() -> void:
	state.break_down()
	_refresh_status()


## Dica de interação: reabastecer com o galão nas mãos, ou consertar com as mãos livres. Vazia nos
## outros casos.
func get_prompt(hands: Hands) -> String:
	if hands.state.is_carrying_item(fuel_can):
		return "Refuel generator" if state.needs_fuel() else ""
	if state.broken and hands.state.can_take_item():
		return "Repair generator"
	return ""


## Tempo, em segundos, que o jogador segura E para reabastecer ou consertar.
func get_hold_seconds(hands: Hands) -> float:
	var seconds: float = (
		refuel_seconds if hands.state.is_carrying_item(fuel_can) else repair_seconds
	)
	return seconds * hold_multiplier


## Com o galão nas mãos, reabastece se o tanque não estiver cheio (o galão volta vazio e as mãos
## ficam livres); sem galão, conserta se estiver quebrado e com as mãos livres. Nos outros casos não
## faz nada.
func interact(hands: Hands) -> void:
	if hands.state.is_carrying_item(fuel_can):
		if not state.needs_fuel():
			return
		# O galão volta vazio para a cabine: as mãos ficam livres.
		hands.state.stop_carrying()
		state.refuel()
	elif state.broken and hands.state.can_take_item():
		state.repair()
	_refresh_status()


## Pinta a luz de status: verde se o gerador funciona, vermelha se ele está quebrado, apagada se ele
## está sem combustível.
func _refresh_status() -> void:
	if state.is_running():
		_status_material.albedo_color = running_color
	elif state.broken:
		_status_material.albedo_color = broken_color
	else:
		_status_material.albedo_color = out_of_fuel_color


## Atualiza a luz de status e repassa a mudança pelo sinal running_changed.
func _on_state_running_changed(running: bool) -> void:
	_refresh_status()
	running_changed.emit(running)
