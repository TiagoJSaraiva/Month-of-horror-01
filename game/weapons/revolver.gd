class_name Revolver
extends Node3D
## Revólver na mão direita. O botão esquerdo atira na hora pela mira do centro da tela, e R
## recarrega (atirar sem bala também recarrega). A reserva é infinita; as regras ficam em
## RevolverState.

@export var hands: Hands
@export var hud_events: HudEvents
@export var damage: float = 25.0
@export var capacity: int = 6
@export var fire_interval: float = 0.35
@export var reload_seconds: float = 2.0
## Quanto tempo a luz do disparo fica acesa, em segundos.
@export var muzzle_flash_seconds: float = 0.05
@export var recoil_degrees: float = 8.0
@export var recoil_seconds: float = 0.15

## Criado no _ready, com os valores do inspetor.
var state: RevolverState

var _rest_rotation: Vector3
var _recoil_tween: Tween

@onready var _model: Node3D = $Model
@onready var _aim: RayCast3D = $Aim
@onready var _muzzle_flash: OmniLight3D = $Model/MuzzleFlash


func _ready() -> void:
	state = RevolverState.new(capacity, fire_interval, reload_seconds)
	_rest_rotation = _model.rotation
	_muzzle_flash.visible = false
	if hands == null or hud_events == null:
		push_warning("Revolver sem Hands ou HudEvents: o revólver não funciona.")
		_model.hide()
		set_process_unhandled_input(false)
		return
	state.changed.connect(_announce_ammo)
	hands.changed.connect(_on_hands_changed)
	_on_hands_changed()
	_announce_ammo()


func _unhandled_input(event: InputEvent) -> void:
	if not hands.state.is_tool_ready(HandsState.Tool.REVOLVER):
		return
	if event.is_action_pressed(&"primary_action"):
		_try_fire()
	elif event.is_action_pressed(&"reload"):
		state.start_reload()
	else:
		return
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	state.update(delta)


func _try_fire() -> void:
	if state.loaded == 0:
		state.start_reload()
		return
	if not state.fire():
		return
	_show_muzzle_flash()
	_kick()
	_aim.force_raycast_update()
	var hurtbox := _aim.get_collider() as Hurtbox
	if hurtbox != null:
		hurtbox.take_hit(damage)


func _show_muzzle_flash() -> void:
	_muzzle_flash.visible = true
	get_tree().create_timer(muzzle_flash_seconds).timeout.connect(_muzzle_flash.hide)


func _kick() -> void:
	if _recoil_tween != null:
		_recoil_tween.kill()
	_model.rotation = _rest_rotation + Vector3(deg_to_rad(recoil_degrees), 0.0, 0.0)
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(_model, "rotation", _rest_rotation, recoil_seconds)


func _announce_ammo() -> void:
	hud_events.ammo_changed.emit(state.loaded, state.capacity, state.is_reloading())


func _on_hands_changed() -> void:
	var in_hand: bool = hands.state.is_tool_ready(HandsState.Tool.REVOLVER)
	_model.visible = in_hand
	if not in_hand:
		state.cancel_reload()
