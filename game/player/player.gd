class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa. Anda no plano do convés na direção para onde o Head olha.
## O corpo nunca gira: quem gira é o Head (MouseLook), e a cápsula é simétrica.

@export var walk_speed: float = 3.5
@export var acceleration: float = 20.0
@export var deceleration: float = 25.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## Diário nas mãos do jogador. Público para a Night entregar o pedido a ele.
@onready var journal: Journal = $Head/Journal
## Mãos do jogador. Públicas para a Night ouvir o peixe largado.
@onready var hands: Hands = %Hands
## Vida do jogador. Pública para a Night ouvir a morte e os inimigos causarem dano.
@onready var health: Health = $Health
@onready var _head: Node3D = $Head


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	var wish_direction: Vector3 = _head.global_basis * Vector3(input.x, 0.0, input.y)
	var horizontal: Vector3 = MovementRules.next_horizontal_velocity(
		velocity, wish_direction, walk_speed, acceleration, deceleration, delta
	)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity.y -= _gravity * delta
	move_and_slide()
