class_name Health
extends Node
## Vida de um personagem (jogador ou inimigo). As regras ficam em HealthState. Com
## hud_events definido (só no jogador), anuncia a vida e o dano no HUD.

signal changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

@export var max_health: float = 100.0
## Vida por segundo recuperada depois de regen_delay_seconds sem dano. 0 desliga.
@export var regen_per_second: float = 0.0
@export var regen_delay_seconds: float = 0.0
@export var hud_events: HudEvents

## Criado no _ready, com os valores do inspetor.
var state: HealthState


func _ready() -> void:
	state = HealthState.new(max_health, regen_per_second, regen_delay_seconds)
	state.changed.connect(_on_state_changed)
	state.died.connect(died.emit)
	_on_state_changed()


func _process(delta: float) -> void:
	state.update(delta)


func is_dead() -> bool:
	return state.is_dead()


func damage(amount: float) -> void:
	if state.is_dead() or amount <= 0.0:
		return
	state.damage(amount)
	damaged.emit(amount)
	if hud_events != null:
		hud_events.player_damaged.emit()


func _on_state_changed() -> void:
	changed.emit(state.current, state.max_health)
	if hud_events != null:
		hud_events.health_changed.emit(state.current, state.max_health)
