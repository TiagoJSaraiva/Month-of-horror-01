class_name MouseLook
extends Node3D
## Olhar em primeira pessoa: gira este nó na horizontal e a câmera filha na vertical.
## Só reage com o mouse capturado, para o cursor livre não mexer a câmera.

## Graus girados por pixel de movimento do mouse na tela.
@export var sensitivity_degrees: float = 0.15
@export var max_pitch_degrees: float = 85.0

@onready var _camera: Camera3D = $Camera3D


## Gira este nó (o Head) na horizontal e a câmera filha na vertical, com a inclinação limitada a
## ±max_pitch_degrees; só age com o mouse capturado.
func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	# screen_relative não depende da escala do SubViewport de baixa resolução (decisão 0009).
	var turn_degrees: Vector2 = motion.screen_relative * sensitivity_degrees
	rotate_y(deg_to_rad(-turn_degrees.x))
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_camera.rotation.x = clampf(
		_camera.rotation.x - deg_to_rad(turn_degrees.y), -max_pitch, max_pitch
	)
