class_name Hurtbox
extends Area3D
## Área que recebe golpes, como o tiro do revólver, e repassa o dano ao Health do dono. Fica
## na camada hurtbox, onde a mira das armas procura.

signal hit(amount: float)

@export var health: Health


## Avisa no console quando a área não tem Health ligado.
func _ready() -> void:
	if health == null:
		push_warning("Hurtbox sem Health: os golpes não causam dano.")


## Recebe um golpe: passa o dano ao Health, se houver, e emite hit.
func take_hit(amount: float) -> void:
	if health != null:
		health.damage(amount)
	hit.emit(amount)
