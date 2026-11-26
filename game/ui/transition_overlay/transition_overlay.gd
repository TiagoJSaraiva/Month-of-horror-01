class_name TransitionOverlay
extends CanvasLayer
## Transições de tela da run: o aviso do amanhecer, a tela preta entre as noites e o título
## da noite que começa. Cada transição pode ser aguardada com await; começar uma nova
## interrompe a anterior, para duas não disputarem a mesma sombra.

const DAWN_TEXT := "6:00 AM\nThe night is over."

## Opacidade da sombra no amanhecer: a cena congelada continua visível por baixo.
@export var dawn_shade_alpha: float = 0.85
@export var dawn_fade_seconds: float = 2.0
@export var message_fade_seconds: float = 1.0
@export var cover_seconds: float = 1.0
@export var title_hold_seconds: float = 1.5
@export var reveal_seconds: float = 1.5

var _tween: Tween

@onready var _shade: ColorRect = $Shade
@onready var _message: Label = $Message


## Escurece a tela sobre a noite congelada e mostra o aviso do amanhecer.
func play_dawn() -> void:
	_message.text = DAWN_TEXT
	var tween: Tween = _restart_tween()
	tween.tween_property(_shade, "color:a", dawn_shade_alpha, dawn_fade_seconds)
	tween.tween_property(_message, "modulate:a", 1.0, message_fade_seconds)
	await tween.finished


## Cobre a tela de preto, para a troca de noite acontecer sem ser vista.
func cover() -> void:
	var tween: Tween = _restart_tween().set_parallel()
	tween.tween_property(_shade, "color:a", 1.0, cover_seconds)
	tween.tween_property(_message, "modulate:a", 0.0, cover_seconds)
	await tween.finished


## Mostra o título sobre a tela preta e depois revela a cena.
func reveal(title: String) -> void:
	_shade.color.a = 1.0
	_message.text = title
	_message.modulate.a = 1.0
	var tween: Tween = _restart_tween()
	tween.tween_interval(title_hold_seconds)
	tween.tween_property(_shade, "color:a", 0.0, reveal_seconds)
	tween.parallel().tween_property(_message, "modulate:a", 0.0, reveal_seconds)
	await tween.finished


## Cancela a transição em andamento e devolve um novo Tween.
func _restart_tween() -> Tween:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	return _tween
