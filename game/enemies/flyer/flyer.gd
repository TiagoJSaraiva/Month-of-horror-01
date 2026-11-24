class_name Flyer
extends CharacterBody3D
## Voador da tempestade: chega do mar, circula o barco e mergulha no jogador ou numa lâmpada
## boa que esteja à vista (as paredes bloqueiam a visão, então a cabine protege). Avisa antes
## de mergulhar acendendo os olhos. Não liga para a lanterna; morre com tiros e vai embora
## quando a tempestade acaba. As decisões ficam em FlyerBrain.

signal removed

## Distância, em metros, para considerar que chegou a um ponto do voo.
const ARRIVAL_DISTANCE := 0.5
## Altura dos olhos do jogador acima dos pés: o mergulho mira a cabeça.
const PLAYER_HEAD_HEIGHT := 1.6

@export var cruise_speed: float = 5.0
@export var dive_speed: float = 9.0
@export var circle_radius: float = 7.0
## Altura, em y do mundo, do círculo sobre o barco.
@export var circle_height: float = 6.0
@export var circle_seconds_min: float = 3.0
@export var circle_seconds_max: float = 6.0
@export var warning_seconds: float = 0.6
@export var attack_damage: float = 15.0
## O mergulho acerta o jogador que ainda estiver a esta distância do ponto mirado.
@export var hit_radius: float = 1.2
## Chance de escolher o jogador quando ele e uma lâmpada estão à vista.
@export var player_chance: float = 0.5
## Um mergulho que não chega ao ponto neste tempo (bateu numa parede) termina mesmo assim.
@export var max_dive_seconds: float = 3.0
## Ao se afastar até esta distância do barco, indo embora, ele some.
@export var leave_distance: float = 40.0
@export var death_seconds: float = 1.5
@export var wing_flap_speed: float = 10.0
@export var wing_flap_degrees: float = 40.0
## Escala dos olhos durante o aviso.
@export var warning_eye_scale: float = 2.0

var brain := FlyerBrain.new()

var _player: Node3D
var _player_health: Health
var _bulbs: Array[Bulb] = []
var _orbit_angle: float = 0.0
var _dive_point := Vector3.ZERO
var _dive_bulb: Bulb
var _dive_seconds: float = 0.0
var _flap_time: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _rng := RandomNumberGenerator.new()

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _left_wing: Node3D = $Model/LeftWing
@onready var _right_wing: Node3D = $Model/RightWing
@onready var _eyes: Node3D = $Model/Eyes
@onready var _health: Health = $Health
@onready var _hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	_rng.randomize()
	brain.warning_seconds = warning_seconds
	brain.state_changed.connect(_on_brain_state_changed)
	_health.died.connect(brain.kill)


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	_flap(delta)
	brain.update(
		delta,
		_can_see(_player_head()),
		not _visible_bulbs().is_empty(),
		_rng.randf(),
		player_chance
	)
	match brain.state:
		FlyerBrain.State.ARRIVING:
			if _fly_toward(_orbit_point(), cruise_speed):
				brain.arrived(_circle_seconds())
		FlyerBrain.State.CIRCLING:
			_orbit_angle += cruise_speed / circle_radius * delta
			_fly_toward(_orbit_point(), cruise_speed)
		FlyerBrain.State.WARNING:
			velocity = Vector3.ZERO
			_face(_target_point())
		FlyerBrain.State.DIVING:
			_dive(delta)
		FlyerBrain.State.RETURNING:
			if _fly_toward(_orbit_point(), cruise_speed):
				brain.returned(_circle_seconds())
		FlyerBrain.State.LEAVING:
			_leave()
		FlyerBrain.State.DEAD:
			_fall(delta)


## Começa a voar até o barco. Chamado pelo FlyerSpawner logo depois de entrar na árvore.
func start(player: Node3D, player_health: Health, bulbs: Array[Bulb]) -> void:
	_player = player
	_player_health = player_health
	_bulbs = bulbs
	# Entra no círculo pelo lado de onde veio.
	_orbit_angle = atan2(global_position.z, global_position.x)


## A tempestade acabou.
func leave() -> void:
	brain.leave()


# Voa até o ponto. Devolve true quando chegou.
func _fly_toward(point: Vector3, speed: float) -> bool:
	var to_point: Vector3 = point - global_position
	if to_point.length() <= ARRIVAL_DISTANCE:
		velocity = Vector3.ZERO
		return true
	velocity = to_point.normalized() * speed
	_face(point)
	move_and_slide()
	return false


func _dive(delta: float) -> void:
	_dive_seconds += delta
	var arrived: bool = _fly_toward(_dive_point, dive_speed)
	if not arrived and _dive_seconds < max_dive_seconds:
		return
	if brain.target == FlyerBrain.Target.PLAYER:
		if _player_head().distance_to(_dive_point) <= hit_radius:
			_player_health.damage(attack_damage)
	elif is_instance_valid(_dive_bulb):
		_dive_bulb.burn_out()
	brain.dive_finished()


func _leave() -> void:
	var outward: Vector3 = Vector3(global_position.x, 0.0, global_position.z).normalized()
	if outward == Vector3.ZERO:
		outward = Vector3.RIGHT
	velocity = (outward + Vector3.UP * 0.3).normalized() * cruise_speed * 1.5
	_face(global_position + velocity)
	move_and_slide()
	if Vector2(global_position.x, global_position.z).length() >= leave_distance:
		_remove()


func _fall(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y -= _gravity * delta
	global_position += velocity * delta


func _flap(delta: float) -> void:
	_flap_time += delta * wing_flap_speed
	var angle: float = deg_to_rad(wing_flap_degrees) * sin(_flap_time)
	_left_wing.rotation.z = angle
	_right_wing.rotation.z = -angle


func _orbit_point() -> Vector3:
	return Vector3(
		cos(_orbit_angle) * circle_radius, circle_height, sin(_orbit_angle) * circle_radius
	)


func _player_head() -> Vector3:
	return _player.global_position + Vector3.UP * PLAYER_HEAD_HEIGHT


func _target_point() -> Vector3:
	if brain.target == FlyerBrain.Target.BULB and is_instance_valid(_dive_bulb):
		return _dive_bulb.global_position
	return _player_head()


func _visible_bulbs() -> Array[Bulb]:
	var in_sight: Array[Bulb] = []
	for bulb: Bulb in _bulbs:
		if is_instance_valid(bulb) and not bulb.is_broken() and _can_see(bulb.global_position):
			in_sight.append(bulb)
	return in_sight


func _can_see(point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position, point, PhysicsLayers.WORLD)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _circle_seconds() -> float:
	return _rng.randf_range(circle_seconds_min, circle_seconds_max)


func _face(point: Vector3) -> void:
	var direction: Vector3 = point - global_position
	# look_at falha com a direção paralela ao "para cima", como num mergulho reto.
	if direction.length() < 0.01 or absf(direction.normalized().dot(Vector3.UP)) > 0.99:
		return
	look_at(point, Vector3.UP)


func _remove() -> void:
	removed.emit()
	queue_free()


func _on_brain_state_changed(state: FlyerBrain.State) -> void:
	var eye_scale: float = warning_eye_scale if state == FlyerBrain.State.WARNING else 1.0
	_eyes.scale = Vector3.ONE * eye_scale
	match state:
		FlyerBrain.State.WARNING:
			# O alvo fica decidido no início do aviso: uma lâmpada sorteada entre as à vista.
			var bulbs: Array[Bulb] = _visible_bulbs()
			_dive_bulb = (
				bulbs[_rng.randi_range(0, bulbs.size() - 1)] if not bulbs.is_empty() else null
			)
		FlyerBrain.State.DIVING:
			# Mira onde o alvo está agora; quem se mexe durante o mergulho escapa.
			_dive_point = _target_point()
			_dive_seconds = 0.0
		FlyerBrain.State.DEAD:
			_collision.disabled = true
			_hurtbox.collision_layer = 0
			get_tree().create_timer(death_seconds).timeout.connect(_remove)
