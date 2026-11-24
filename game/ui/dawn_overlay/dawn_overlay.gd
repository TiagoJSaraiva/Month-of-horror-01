class_name DawnOverlay
extends CanvasLayer
## Aviso de fim da noite: escurece a tela e depois mostra a mensagem do amanhecer.

## Opacidade final da sombra: a cena congelada continua visível por baixo.
@export var shade_alpha: float = 0.85
@export var shade_fade_seconds: float = 2.0
@export var message_fade_seconds: float = 1.0

@onready var _shade: ColorRect = $Shade
@onready var _message: Label = $Message


func play() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_shade, "color:a", shade_alpha, shade_fade_seconds)
	tween.tween_property(_message, "modulate:a", 1.0, message_fade_seconds)
