class_name Journal
extends Node3D
## Diário que o jogador segura com as duas mãos. Fica preso ao giro horizontal do Head, e
## não à inclinação da câmera, para só aparecer quando o jogador olha para baixo.
## Quem decide abrir e fechar é o Hands.

## Quanto o diário desce, em metros, ao ser guardado.
@export var stow_drop: float = 0.4
@export var move_seconds: float = 0.2

var is_open: bool = false

var _held_position: Vector3
var _night_number: int = 0
var _order: NightOrder
var _tween: Tween

@onready var _text: Label3D = $Page/Text


## Guarda a posição de uso e começa com o diário guardado e escondido.
func _ready() -> void:
	_held_position = position
	position = _stowed_position()
	visible = false


## Passa a mostrar esta noite e este pedido, reescrevendo o texto a cada entrega.
func display(night_number: int, order: NightOrder) -> void:
	if _order != null and _order.changed.is_connected(_refresh):
		_order.changed.disconnect(_refresh)
	_night_number = night_number
	_order = order
	_order.changed.connect(_refresh)
	_refresh()


## Sobe o diário até a posição de leitura.
func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	_restart_tween().tween_property(self, "position", _held_position, move_seconds)


## Desce o diário e o esconde ao fim do movimento.
func close() -> void:
	if not is_open:
		return
	is_open = false
	var tween: Tween = _restart_tween()
	tween.tween_property(self, "position", _stowed_position(), move_seconds)
	tween.tween_callback(hide)


## Cancela o movimento em andamento e devolve um novo Tween.
func _restart_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	return _tween


## Reescreve o texto da página com a noite e o pedido atuais.
func _refresh() -> void:
	_text.text = JournalText.compose(_night_number, _order)


## Posição do diário guardado: a de leitura abaixada em stow_drop.
func _stowed_position() -> Vector3:
	return _held_position + Vector3.DOWN * stow_drop
