class_name Fishman
extends CharacterBody3D
## Peixe-homem: sobe pela amurada quando o barco escurece, persegue o jogador pela malha de
## navegação e ataca de perto. Atordoado, fecha os olhos; com a luz de volta, foge pela amurada
## mais próxima; morto, cai e some. As decisões ficam em FishmanBrain; aqui entram movimento,
## visual e dano.

signal removed

## Distância horizontal, em metros, para considerar que chegou ao ponto de fuga.
const ARRIVAL_DISTANCE := 0.4

@export var move_speed: float = 2.6
@export var flee_speed: float = 3.5
@export var attack_damage: float = 20.0
@export var climb_seconds: float = 1.5
@export var attack_range: float = 1.4
@export var windup_seconds: float = 0.6
@export var recover_seconds: float = 1.0
@export var stun_seconds: float = 1.0
@export var stun_immunity_seconds: float = 2.0
## A cada quantos segundos o caminho até o destino é recalculado.
@export var repath_seconds: float = 0.2
@export var death_seconds: float = 0.6
## Quanto o corpo inclina para trás na preparação do golpe, em graus.
@export var windup_lean_degrees: float = 20.0

var brain := FishmanBrain.new()

var _target: Node3D
var _target_health: Health
## Pontos de subida do barco: um deles é por onde ele sobe, o mais próximo é por onde foge.
var _climb_points: Array[Marker3D] = []
var _climb_point: Marker3D
var _tween: Tween
var _repath_left: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _model: Node3D = $Model
@onready var _eyes: Node3D = $Model/Eyes
@onready var _health: Health = $Health
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _agent: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	brain.climb_seconds = climb_seconds
	brain.attack_range = attack_range
	brain.windup_seconds = windup_seconds
	brain.recover_seconds = recover_seconds
	brain.stun_seconds = stun_seconds
	brain.stun_immunity_seconds = stun_immunity_seconds
	brain.state_changed.connect(_on_brain_state_changed)
	brain.attack_landed.connect(_on_brain_attack_landed)
	_health.died.connect(brain.kill)


func _physics_process(delta: float) -> void:
	if _target == null or brain.state == FishmanBrain.State.DEAD:
		return
	brain.update(delta, _flat_distance_to(_target.global_position))
	match brain.state:
		FishmanBrain.State.CLIMBING:
			return
		FishmanBrain.State.CHASING:
			_walk_toward(_target.global_position, move_speed, delta)
			_face(_target.global_position)
		FishmanBrain.State.FLEEING:
			_flee(delta)
			return
		_:
			velocity.x = 0.0
			velocity.z = 0.0
			_face(_target.global_position)
	_apply_gravity_and_move(delta)


## Sobe pela amurada no ponto dado e passa a perseguir o alvo. Chamado pelo FishmanSpawner
## logo depois de entrar na árvore.
func climb_aboard(
	point: Marker3D, climb_points: Array[Marker3D], target: Node3D, target_health: Health
) -> void:
	_target = target
	_target_health = target_health
	_climb_points = climb_points
	_climb_point = point
	# Subindo, ele atravessa a amurada: sem colisão até pisar no convés.
	_collision.disabled = true
	global_position = _water_point(point)
	_face(point.global_position)
	_tween = create_tween()
	_tween.tween_property(self, "global_position", _crest_point(point), climb_seconds * 0.7)
	_tween.tween_property(self, "global_position", point.global_position, climb_seconds * 0.3)


## Luz no rosto (chamado pelo sensor de luz no M5).
func stun() -> void:
	brain.stun()


## A luz do barco voltou.
func flee() -> void:
	brain.flee()


func _walk_toward(destination: Vector3, speed: float, delta: float) -> void:
	_repath_left -= delta
	if _repath_left <= 0.0:
		_agent.target_position = destination
		_repath_left = repath_seconds
	var direction: Vector3 = _agent.get_next_path_position() - global_position
	direction.y = 0.0
	if direction.length() < 0.05:
		direction = Vector3.ZERO
	velocity.x = direction.normalized().x * speed
	velocity.z = direction.normalized().z * speed


func _flee(delta: float) -> void:
	if _tween != null and _tween.is_running():
		return
	var exit_point: Marker3D = _nearest_climb_point()
	if exit_point == null:
		_remove()
		return
	if _flat_distance_to(exit_point.global_position) > ARRIVAL_DISTANCE:
		_walk_toward(exit_point.global_position, flee_speed, delta)
		_face(exit_point.global_position)
		_apply_gravity_and_move(delta)
		return
	_leave_over_side(exit_point)


# Passa por cima da amurada no ponto dado e cai de volta no mar.
func _leave_over_side(point: Marker3D) -> void:
	if _tween != null:
		_tween.kill()
	_collision.disabled = true
	_tween = create_tween()
	_tween.tween_property(self, "global_position", _crest_point(point), climb_seconds * 0.3)
	_tween.tween_property(self, "global_position", _water_point(point), climb_seconds * 0.3)
	_tween.tween_callback(_remove)


func _apply_gravity_and_move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	move_and_slide()


func _die() -> void:
	if _tween != null:
		_tween.kill()
	_collision.disabled = true
	# Para o tiro seguinte atravessar o corpo caído.
	_hurtbox.collision_layer = 0
	_tween = create_tween().set_parallel()
	_tween.tween_property(_model, "rotation:x", deg_to_rad(-90.0), death_seconds)
	_tween.tween_property(_model, "position:y", -0.6, death_seconds)
	_tween.chain().tween_callback(_remove)


func _remove() -> void:
	removed.emit()
	queue_free()


func _face(point: Vector3) -> void:
	var flat_target := Vector3(point.x, global_position.y, point.z)
	if flat_target.distance_to(global_position) > 0.01:
		look_at(flat_target, Vector3.UP)


func _flat_distance_to(point: Vector3) -> float:
	return Vector2(point.x, point.z).distance_to(Vector2(global_position.x, global_position.z))


func _nearest_climb_point() -> Marker3D:
	var nearest: Marker3D = null
	for point: Marker3D in _climb_points:
		if (
			nearest == null
			or _flat_distance_to(point.global_position) < _flat_distance_to(nearest.global_position)
		):
			nearest = point
	return nearest


# O eixo +Z de cada ponto de subida aponta para o mar.
func _water_point(point: Marker3D) -> Vector3:
	var outward: Vector3 = point.global_basis.z
	return point.global_position + outward * 1.4 + Vector3.DOWN * point.global_position.y


func _crest_point(point: Marker3D) -> Vector3:
	var outward: Vector3 = point.global_basis.z
	return point.global_position + outward * 0.45 + Vector3.UP * 1.3


func _on_brain_state_changed(state: FishmanBrain.State) -> void:
	_eyes.visible = state != FishmanBrain.State.STUNNED
	var lean: float = (
		deg_to_rad(windup_lean_degrees) if state == FishmanBrain.State.WINDING_UP else 0.0
	)
	_model.rotation.x = lean
	match state:
		FishmanBrain.State.CHASING:
			# Fim da subida: termina no ponto de chegada mesmo que o tween ainda não tenha acabado.
			if _collision.disabled:
				if _tween != null:
					_tween.kill()
				global_position = _climb_point.global_position
				_collision.disabled = false
		FishmanBrain.State.FLEEING:
			# Fugindo durante a subida: volta pela mesma amurada.
			if _tween != null and _tween.is_running():
				_leave_over_side(_climb_point)
		FishmanBrain.State.DEAD:
			_die()


func _on_brain_attack_landed() -> void:
	if _target_health != null:
		_target_health.damage(attack_damage)
