class_name DamageFlash
extends ColorRect
## Clarão vermelho na tela inteira quando o jogador leva dano.

## Opacidade no pico do clarão.
@export var peak_alpha: float = 0.35
@export var fade_seconds: float = 0.4

var _tween: Tween


## Começa transparente.
func _ready() -> void:
	color.a = 0.0


## Acende o clarão no pico e o apaga aos poucos.
func flash() -> void:
	if _tween != null:
		_tween.kill()
	color.a = peak_alpha
	_tween = create_tween()
	_tween.tween_property(self, "color:a", 0.0, fade_seconds)


## Apaga o clarão na hora.
func clear() -> void:
	if _tween != null:
		_tween.kill()
	color.a = 0.0
