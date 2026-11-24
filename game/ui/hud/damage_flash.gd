class_name DamageFlash
extends ColorRect
## Clarão vermelho na tela inteira quando o jogador leva dano.

## Opacidade no pico do clarão.
@export var peak_alpha: float = 0.35
@export var fade_seconds: float = 0.4

var _tween: Tween


func _ready() -> void:
	color.a = 0.0


func flash() -> void:
	if _tween != null:
		_tween.kill()
	color.a = peak_alpha
	_tween = create_tween()
	_tween.tween_property(self, "color:a", 0.0, fade_seconds)


func clear() -> void:
	if _tween != null:
		_tween.kill()
	color.a = 0.0
