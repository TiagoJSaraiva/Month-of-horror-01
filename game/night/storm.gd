class_name Storm
extends Node
## Tempestade da noite: sorteia se haverá uma e quando (StormRules), acompanha o NightClock e
## anuncia a intensidade de 0 a 1. A Night repassa a intensidade ao céu, ao balanço, à lua, ao
## clima e às falhas de manutenção.

signal started
signal ended
signal strength_changed(strength: float)

const START_HINT: String = "The wind is picking up..."
const END_HINT: String = "The storm is passing."
## Menor mudança anunciada: cada anúncio refaz a iluminação do céu, então não vale a cada frame.
const STRENGTH_STEP: float = 0.01

@export var night_clock: NightClock
@export var settings: StormSettings
@export var hud_events: HudEvents
## Quanto tempo, em segundos, as dicas de começo e fim ficam na tela.
@export var hint_seconds: float = 3.0

## Tempestade sorteada para esta noite. Sem sorteio, não há tempestade.
var plan: StormPlan = StormPlan.new()
var strength: float = 0.0

var _active: bool = false


## Sem NightClock ou StormSettings, avisa e desliga a tempestade.
func _ready() -> void:
	if night_clock == null or settings == null:
		push_warning("Storm sem NightClock ou StormSettings: não há tempestade.")
		set_process(false)


## Acompanha o relógio da noite e avisa o começo e o fim da tempestade. Emite strength_changed
## quando a intensidade muda pelo menos STRENGTH_STEP, e também ao chegar em 0 ou 1.
func _process(_delta: float) -> void:
	if not plan.has_storm:
		return
	var elapsed: float = night_clock.progress * night_clock.duration_seconds
	_update_active(elapsed)
	var new_strength: float = StormRules.strength(elapsed, plan, settings.ramp_seconds)
	var reached_an_end: bool = (
		new_strength != strength and (new_strength == 0.0 or new_strength == 1.0)
	)
	if absf(new_strength - strength) >= STRENGTH_STEP or reached_an_end:
		strength = new_strength
		strength_changed.emit(strength)


## Sorteia a tempestade desta noite. Chamado pela Night no _ready.
func roll(night_number: int, rng: RandomNumberGenerator) -> void:
	if night_clock == null or settings == null:
		return
	plan = StormRules.plan(night_number, night_clock.duration_seconds, settings, rng)


## A tempestade está acontecendo agora.
func is_active() -> bool:
	return _active


## Atualiza _active (lido por is_active) e, só na virada para ativa ou inativa, emite started/ended
## e a dica.
func _update_active(elapsed: float) -> void:
	var active: bool = elapsed >= plan.start_seconds and elapsed < plan.end_seconds()
	if active == _active:
		return
	_active = active
	if active:
		started.emit()
		_hint(START_HINT)
	else:
		ended.emit()
		_hint(END_HINT)


## Pede ao HUD, pelo HudEvents, que mostre a dica por hint_seconds; sem HudEvents, não faz nada.
func _hint(text: String) -> void:
	if hud_events != null:
		hud_events.hint_requested.emit(text, hint_seconds)
