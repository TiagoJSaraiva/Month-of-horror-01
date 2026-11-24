class_name Flashlight
extends Node3D
## Lanterna na mão esquerda: liga e desliga com F e gasta a bateria só acesa. Funciona com
## as mãos em qualquer modo. Serve para enxergar e, pelo filho LightStun, atordoar o
## peixe-homem; não conta para o nível de luz do barco. A bateria só recarrega na caixa de
## pilhas da cabine.

## Segundos de luz com a bateria cheia. A carta rara e a dificuldade por noite (M7) mudam.
@export var battery_seconds: float = 90.0
@export var hud_events: HudEvents
## Quanto tempo, em segundos, o aviso de bateria vazia fica na tela.
@export var empty_hint_seconds: float = 2.0

## Criada no _ready, com a capacidade do inspetor.
var battery: FlashlightBattery

# Percentual inteiro já mostrado: o HUD só é avisado quando ele muda, não a cada frame.
var _shown_percent: int = -1

@onready var _beam: SpotLight3D = $Beam
@onready var _light_stun: LightStun = $LightStun


func _ready() -> void:
	if hud_events == null:
		push_warning("Flashlight sem HudEvents: a bateria não aparece na tela.")
	battery = FlashlightBattery.new(battery_seconds)
	_set_on(false)
	_announce_battery()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"toggle_flashlight"):
		return
	if is_on():
		_set_on(false)
	elif battery.is_empty():
		_hint("The batteries are dead.")
	else:
		_set_on(true)
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if is_on() and battery.drain(delta):
		_set_on(false)
		_hint("The flashlight died.")
	_announce_battery()


func is_on() -> bool:
	return _beam.visible


## Pilhas novas: a bateria volta cheia.
func recharge() -> void:
	battery.recharge()
	_announce_battery()


func _set_on(on: bool) -> void:
	_beam.visible = on
	_light_stun.enabled = on


func _announce_battery() -> void:
	if hud_events == null:
		return
	var percent: int = roundi(battery.ratio() * 100.0)
	if percent != _shown_percent:
		_shown_percent = percent
		hud_events.battery_changed.emit(battery.ratio())


func _hint(text: String) -> void:
	if hud_events != null:
		hud_events.hint_requested.emit(text, empty_hint_seconds)
