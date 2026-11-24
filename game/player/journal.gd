class_name Journal
extends Node3D
## Diário que o jogador segura com as duas mãos. Fica preso ao giro horizontal do Head, e
## não à inclinação da câmera, para só aparecer quando o jogador olha para baixo.

## Quanto o diário desce, em metros, ao ser guardado.
@export var stow_drop: float = 0.4
@export var move_seconds: float = 0.2

var is_open: bool = false

var _held_position: Vector3
var _night_number: int = 0
var _order: NightOrder
var _tween: Tween

@onready var _text: Label3D = $Page/Text


func _ready() -> void:
	_held_position = position
	position = _stowed_position()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_journal"):
		toggle()
		get_viewport().set_input_as_handled()


## Passa a mostrar esta noite e este pedido, reescrevendo o texto a cada entrega.
func display(night_number: int, order: NightOrder) -> void:
	if _order != null and _order.changed.is_connected(_refresh):
		_order.changed.disconnect(_refresh)
	_night_number = night_number
	_order = order
	_order.changed.connect(_refresh)
	_refresh()


func toggle() -> void:
	is_open = not is_open
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if is_open:
		visible = true
		_tween.tween_property(self, "position", _held_position, move_seconds)
	else:
		_tween.tween_property(self, "position", _stowed_position(), move_seconds)
		_tween.tween_callback(hide)


func _refresh() -> void:
	_text.text = JournalText.compose(_night_number, _order)


func _stowed_position() -> Vector3:
	return _held_position + Vector3.DOWN * stow_drop
