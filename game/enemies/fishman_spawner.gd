class_name FishmanSpawner
extends Node3D
## Faz peixes-homens subirem a bordo enquanto o nível de luz do barco está abaixo do limiar,
## com mais frequência quanto mais escuro (SpawnRules). Quando a luz volta ao limiar, manda
## todos fugirem. Fica dentro de Actors, então congela no amanhecer junto com eles.
## Os pontos de subida são os Marker3D filhos de ClimbPoints, com o eixo +Z apontando para o mar.

@export var fishman_scene: PackedScene
## Nível de luz (0 a 1) abaixo do qual eles sobem.
@export var light_threshold: float = 0.5
## Intervalo entre surgimentos no escuro total.
@export var min_spawn_seconds: float = 6.0
## Intervalo entre surgimentos logo abaixo do limiar.
@export var max_spawn_seconds: float = 20.0
@export var max_alive: int = 3
## Um ponto de subida mais perto do jogador que isto não é sorteado.
@export var min_distance_to_player: float = 2.0

var _lighting: BoatLighting
var _target: Node3D
var _target_health: Health
var _climb_points: Array[Marker3D] = []
var _fishmen: Array[Fishman] = []
var _elapsed: float = 0.0
var _rng := RandomNumberGenerator.new()
# Dificuldade da noite (set_difficulty): 1 não muda nada.
var _interval_multiplier: float = 1.0
var _health_multiplier: float = 1.0
var _damage_multiplier: float = 1.0

@onready var _climb_points_root: Node3D = $ClimbPoints


## Sorteia a semente e reúne os pontos de subida filhos de ClimbPoints.
func _ready() -> void:
	_rng.randomize()
	for child: Node in _climb_points_root.get_children():
		var point := child as Marker3D
		if point != null:
			_climb_points.append(point)


## Com o barco abaixo do limiar de luz, conta o intervalo e faz um peixe-homem subir num ponto
## sorteado.
func _process(delta: float) -> void:
	if _lighting == null:
		return
	var interval: float = SpawnRules.spawn_interval(
		_lighting.light_level,
		light_threshold,
		min_spawn_seconds * _interval_multiplier,
		max_spawn_seconds * _interval_multiplier
	)
	if interval == SpawnRules.NO_SPAWN:
		_elapsed = 0.0
		return
	_elapsed += delta
	if _elapsed >= interval and _fishmen.size() < max_alive:
		var point: Marker3D = _pick_climb_point()
		if point != null:
			_elapsed = 0.0
			spawn(point)


## Começa a vigiar a luz do barco. Chamado pela Night.
func start(lighting: BoatLighting, target: Node3D, target_health: Health) -> void:
	_lighting = lighting
	_target = target
	_target_health = target_health
	lighting.light_level_changed.connect(_on_lighting_light_level_changed)


## Dificuldade da noite: multiplica os intervalos entre surgimentos e a vida e o dano de cada
## peixe-homem.
func set_difficulty(
	interval_multiplier: float, health_multiplier: float, damage_multiplier: float
) -> void:
	_interval_multiplier = interval_multiplier
	_health_multiplier = health_multiplier
	_damage_multiplier = damage_multiplier


## Faz um peixe-homem subir no ponto dado. Público para os testes escolherem o ponto.
func spawn(point: Marker3D) -> Fishman:
	var fishman := fishman_scene.instantiate() as Fishman
	add_child(fishman)
	fishman.removed.connect(_on_fishman_removed.bind(fishman))
	fishman.strengthen(_health_multiplier, _damage_multiplier)
	fishman.climb_aboard(point, _climb_points, _target, _target_health)
	_fishmen.append(fishman)
	return fishman


## Pontos de subida do barco.
func climb_points() -> Array[Marker3D]:
	return _climb_points


## Sorteia um ponto de subida longe do jogador, ou null se todos estão perto.
func _pick_climb_point() -> Marker3D:
	var candidates: Array[Marker3D] = []
	for point: Marker3D in _climb_points:
		if _is_far_from_target(point):
			candidates.append(point)
	if candidates.is_empty():
		return null
	return candidates[_rng.randi_range(0, candidates.size() - 1)]


## O ponto está a pelo menos min_distance_to_player do jogador.
func _is_far_from_target(point: Marker3D) -> bool:
	if _target == null:
		return true
	return point.global_position.distance_to(_target.global_position) >= min_distance_to_player


## Manda todos os peixes-homens fugirem quando a luz volta ao limiar.
func _on_lighting_light_level_changed(level: float) -> void:
	if level < light_threshold:
		return
	for fishman: Fishman in _fishmen:
		fishman.flee()


## Tira da lista o peixe-homem que saiu.
func _on_fishman_removed(fishman: Fishman) -> void:
	_fishmen.erase(fishman)
