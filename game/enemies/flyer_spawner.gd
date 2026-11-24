class_name FlyerSpawner
extends Node3D
## Traz voadores do mar enquanto a tempestade dura e manda todos embora quando ela acaba.
## Fica dentro de Actors, então congela no amanhecer junto com eles.

@export var flyer_scene: PackedScene
## Segundos entre o começo da tempestade e o primeiro voador.
@export var first_spawn_seconds: float = 4.0
@export var spawn_seconds: float = 12.0
@export var max_alive: int = 2
## Distância horizontal do barco, sobre o mar, de onde eles chegam.
@export var spawn_distance: float = 25.0
@export var spawn_height: float = 10.0

var _player: Node3D
var _player_health: Health
var _lighting: BoatLighting
var _flyers: Array[Flyer] = []
var _active: bool = false
var _until_spawn: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if not _active:
		return
	_until_spawn -= delta
	if _until_spawn <= 0.0 and _flyers.size() < max_alive:
		_until_spawn = spawn_seconds
		spawn()


## Começa a ouvir a tempestade. Chamado pela Night.
func start(storm: Storm, lighting: BoatLighting, player: Node3D, player_health: Health) -> void:
	_lighting = lighting
	_player = player
	_player_health = player_health
	storm.started.connect(_on_storm_started)
	storm.ended.connect(_on_storm_ended)


## Faz um voador chegar de um ponto sorteado sobre o mar. Público para os testes.
func spawn() -> Flyer:
	var angle: float = _rng.randf_range(0.0, TAU)
	var flyer := flyer_scene.instantiate() as Flyer
	add_child(flyer)
	flyer.global_position = Vector3(
		cos(angle) * spawn_distance, spawn_height, sin(angle) * spawn_distance
	)
	flyer.removed.connect(_on_flyer_removed.bind(flyer))
	flyer.start(_player, _player_health, _lighting.bulbs())
	_flyers.append(flyer)
	return flyer


func _on_storm_started() -> void:
	_active = true
	_until_spawn = first_spawn_seconds


func _on_storm_ended() -> void:
	_active = false
	for flyer: Flyer in _flyers:
		flyer.leave()


func _on_flyer_removed(flyer: Flyer) -> void:
	_flyers.erase(flyer)
