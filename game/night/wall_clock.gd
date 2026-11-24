class_name WallClock
extends Node3D
## Relógio de ponteiros da cabine. Mostra a hora do jogo lida do NightClock.

@export var night_clock: NightClock

@onready var _hour_hand: Node3D = $HourHand
@onready var _minute_hand: Node3D = $MinuteHand


func _ready() -> void:
	if night_clock == null:
		push_warning("WallClock sem NightClock: os ponteiros ficam parados.")


func _process(_delta: float) -> void:
	if night_clock == null:
		return
	var angles: Vector2 = NightTimeRules.hand_angles(night_clock.clock_minutes())
	# O mostrador olha para +Z; rotação positiva em Z seria anti-horária para quem o vê.
	_hour_hand.rotation.z = -angles.x
	_minute_hand.rotation.z = -angles.y
