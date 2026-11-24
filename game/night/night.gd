class_name Night
extends Node3D
## Uma noite de pesca: gera o pedido, entrega-o ao diário do jogador, registra os peixes
## guardados no freezer e encerra a ação dos personagens ao amanhecer.

signal night_finished(order: NightOrder)

## Número da noite na run. A Run (M3) vai definir este valor antes de a noite começar.
@export var night_number: int = 1
@export var fish_species: Array[FishData] = []
## Cena criada no convés quando o jogador larga um peixe.
@export var dropped_fish_scene: PackedScene

var order: NightOrder

var _rng := RandomNumberGenerator.new()

@onready var _clock: NightClock = $NightClock
@onready var _actors: Node3D = $Actors
@onready var _player: Player = $Actors/Player
@onready var _freezer: Freezer = $Boat/Freezer
@onready var _items: Node3D = $Items


func _ready() -> void:
	_rng.randomize()
	order = NightOrder.new(OrderRules.generate(night_number, fish_species, _rng))
	_player.journal.display(night_number, order)
	_clock.dawn_reached.connect(_on_night_clock_dawn_reached)
	_freezer.fish_stored.connect(_on_freezer_fish_stored)
	_player.hands.fish_dropped.connect(_on_hands_fish_dropped)


func _on_night_clock_dawn_reached() -> void:
	# Só os personagens param: mar, céu e balanço continuam, como pede o amanhecer.
	_actors.process_mode = Node.PROCESS_MODE_DISABLED
	night_finished.emit(order)


func _on_freezer_fish_stored(fish: FishData, amount: int) -> void:
	order.deliver(fish, amount)


func _on_hands_fish_dropped(fish: FishData, amount: int, at: Vector3) -> void:
	var dropped := dropped_fish_scene.instantiate() as DroppedFish
	dropped.fish = fish
	dropped.amount = amount
	_items.add_child(dropped)
	dropped.global_position = at
