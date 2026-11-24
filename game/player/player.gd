class_name Player
extends CharacterBody3D
## Jogador em primeira pessoa. Anda no plano do convés na direção para onde o Head olha.
## O corpo nunca gira: quem gira é o Head (MouseLook), e a cápsula é simétrica.
## No começo da noite recebe os bônus da run e os repassa aos próprios componentes.

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
## Lanterna. Pública para a Night aplicar a dificuldade da noite na bateria.
@onready var flashlight: Flashlight = %Flashlight
@onready var _head: Node3D = $Head
@onready var _fishing_rod: FishingRod = %FishingRod
@onready var _revolver: Revolver = %Revolver


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


## Aplica os bônus da run sobre os valores do inspetor. A Night chama uma vez, no começo da
## noite (o jogador é recriado a cada noite).
func apply_stats(stats: PlayerStats) -> void:
	walk_speed = stats.apply(StatModifier.Stat.MOVE_SPEED, walk_speed)
	health.set_max_health(stats.apply(StatModifier.Stat.MAX_HEALTH, health.max_health))
	_fishing_rod.fishing_power = stats.apply(
		StatModifier.Stat.FISHING_POWER, _fishing_rod.fishing_power
	)
	_fishing_rod.double_catch_chance = stats.chance(StatModifier.Stat.DOUBLE_FISH_CHANCE)
	# Cadência é tiros por segundo: +20% de cadência divide o intervalo entre tiros por 1,2.
	_revolver.configure(
		stats.apply(StatModifier.Stat.WEAPON_DAMAGE, _revolver.damage),
		roundi(stats.apply(StatModifier.Stat.AMMO_CAPACITY, _revolver.capacity)),
		_revolver.fire_interval / stats.apply(StatModifier.Stat.FIRE_RATE, 1.0),
		stats.apply(StatModifier.Stat.RELOAD_TIME, _revolver.reload_seconds)
	)
	flashlight.set_battery_seconds(
		stats.apply(StatModifier.Stat.BATTERY_CAPACITY, flashlight.battery_seconds)
	)
