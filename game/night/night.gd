class_name Night
extends Node3D
## Uma noite de pesca: gera o pedido e encerra a ação dos personagens ao amanhecer.

signal night_finished(order: NightOrder)

## Número da noite na run. A Run (M3) vai definir este valor antes de a noite começar.
@export var night_number: int = 1
@export var fish_species: Array[FishData] = []

var order: NightOrder

var _rng := RandomNumberGenerator.new()

@onready var _clock: NightClock = $NightClock
@onready var _actors: Node3D = $Actors


func _ready() -> void:
	_rng.randomize()
	order = NightOrder.new(OrderRules.generate(night_number, fish_species, _rng))
	_clock.dawn_reached.connect(_on_night_clock_dawn_reached)


func _on_night_clock_dawn_reached() -> void:
	# Só os personagens param: mar, céu e balanço continuam, como pede o amanhecer.
	_actors.process_mode = Node.PROCESS_MODE_DISABLED
	night_finished.emit(order)
