class_name MovementRules
extends RefCounted
## Regras puras do movimento horizontal em primeira pessoa.
## A componente vertical (gravidade) fica com quem chama.


## Aproxima a velocidade horizontal atual da velocidade desejada.
## Acelera enquanto há direção de input e freia quando não há, sem passar do alvo.
## [param wish_direction] é a direção do input no mundo; o comprimento é limitado a 1.
static func next_horizontal_velocity(
	current: Vector3,
	wish_direction: Vector3,
	max_speed: float,
	acceleration: float,
	deceleration: float,
	delta: float,
) -> Vector3:
	var flat_current: Vector3 = Vector3(current.x, 0.0, current.z)
	var flat_wish: Vector3 = Vector3(wish_direction.x, 0.0, wish_direction.z)
	var target: Vector3 = flat_wish.limit_length(1.0) * max_speed
	var rate: float = acceleration if flat_wish.length_squared() > 0.0 else deceleration
	return flat_current.move_toward(target, rate * delta)
