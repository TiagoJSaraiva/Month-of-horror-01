class_name Night
extends Node3D
## Uma noite de pesca: gera o pedido, entrega-o ao diário do jogador, põe o bilhete na mesa,
## registra os peixes guardados no freezer e encerra a ação dos personagens ao amanhecer.

signal night_finished(order: NightOrder)

## Número da noite na run. A Run define este valor antes de a noite começar.
@export var night_number: int = 1
@export var fish_species: Array[FishData] = []
## Cena criada no convés quando o jogador larga um item.
@export var dropped_item_scene: PackedScene

var order: NightOrder
## Bilhete dos clientes na mesa. A Run define antes de a noite entrar na árvore; sem texto, a
## mesa fica sem bilhete.
var table_note_text: String = ""
var table_note_pin: RunRules.Pin = RunRules.Pin.BLUE

var _rng := RandomNumberGenerator.new()

@onready var _clock: NightClock = $NightClock
@onready var _actors: Node3D = $Actors
@onready var _player: Player = $Actors/Player
@onready var _freezer: Freezer = $Boat/Freezer
@onready var _lighting: BoatLighting = $Boat/Lighting
@onready var _items: Node3D = $Items
@onready var _table_note: TableNote = $TableNote


func _ready() -> void:
	_rng.randomize()
	order = NightOrder.new(OrderRules.generate(night_number, fish_species, _rng))
	_player.journal.display(night_number, order)
	_table_note.show_note(table_note_text, table_note_pin)
	_clock.dawn_reached.connect(_on_night_clock_dawn_reached)
	_freezer.fish_stored.connect(_on_freezer_fish_stored)
	_player.hands.item_dropped.connect(_on_hands_item_dropped)


func _on_night_clock_dawn_reached() -> void:
	# Só os personagens e a manutenção param: mar, céu e balanço continuam, como pede o
	# amanhecer. Sem isso, o gerador ainda poderia quebrar na tela do amanhecer.
	_actors.process_mode = Node.PROCESS_MODE_DISABLED
	_lighting.process_mode = Node.PROCESS_MODE_DISABLED
	night_finished.emit(order)


func _on_freezer_fish_stored(fish: FishData, amount: int) -> void:
	order.deliver(fish, amount)


func _on_hands_item_dropped(item: ItemData, amount: int, at: Vector3) -> void:
	var dropped := dropped_item_scene.instantiate() as DroppedItem
	dropped.item = item
	dropped.amount = amount
	_items.add_child(dropped)
	dropped.global_position = at
