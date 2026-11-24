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

var _status_material := StandardMaterial3D.new()

@onready var _status_lamp: MeshInstance3D = $StatusLamp
@onready var _fuel_fill: Node3D = $FuelGauge/Fill


func _ready() -> void:
	if fuel_can == null:
		push_warning("Generator sem fuel_can: o gerador não pode ser reabastecido.")
	state = GeneratorState.new(fuel_capacity_seconds)
	state.running_changed.connect(_on_state_running_changed)
	# Sem sombreamento, para a luz de status ser vista de longe no escuro.
	_status_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_status_lamp.material_override = _status_material
	_refresh_status()


func _process(delta: float) -> void:
	state.consume(delta)
	var fuel: float = state.fuel_ratio()
	# Escala zero deixaria a base do nó degenerada: com o tanque vazio, a barra só some.
	_fuel_fill.visible = fuel > 0.0
	if fuel > 0.0:
		_fuel_fill.scale.x = fuel


func is_running() -> bool:
	return state.is_running()


func break_down() -> void:
	state.break_down()
	_refresh_status()


func get_prompt(hands: Hands) -> String:
	if hands.state.is_carrying_item(fuel_can):
		return "Refuel generator" if state.needs_fuel() else ""
	if state.broken and hands.state.can_take_item():
		return "Repair generator"
	return ""


func get_hold_seconds(hands: Hands) -> float:
	return refuel_seconds if hands.state.is_carrying_item(fuel_can) else repair_seconds


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


func _refresh_status() -> void:
	if state.is_running():
		_status_material.albedo_color = running_color
	elif state.broken:
		_status_material.albedo_color = broken_color
	else:
		_status_material.albedo_color = out_of_fuel_color


func _on_state_running_changed(running: bool) -> void:
	_refresh_status()
	running_changed.emit(running)
