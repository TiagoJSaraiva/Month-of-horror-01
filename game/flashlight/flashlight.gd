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


## Cria a bateria com a capacidade do inspetor e apaga o facho e o atordoamento. Avisa o HUD da
## carga; sem HudEvents, só emite um aviso no console.
func _ready() -> void:
	if hud_events == null:
		push_warning("Flashlight sem HudEvents: a bateria não aparece na tela.")
	battery = FlashlightBattery.new(battery_seconds)
	_set_on(false)
	_announce_battery()


## F liga ou desliga o facho. Com a bateria vazia, mostra o aviso em vez de ligar.
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


## Gasta a bateria com o facho aceso. Quando a carga acaba, apaga a lanterna e mostra o aviso na
## tela.
func _process(delta: float) -> void:
	if is_on() and battery.drain(delta):
		_set_on(false)
		_hint("The flashlight died.")
	_announce_battery()


## O facho está aceso.
func is_on() -> bool:
	return _beam.visible


## Troca a capacidade da bateria e a deixa cheia (bônus da run e dificuldade da noite, depois do
## _ready).
func set_battery_seconds(seconds: float) -> void:
	battery_seconds = seconds
	battery = FlashlightBattery.new(seconds)
	_announce_battery()


## Pilhas novas: a bateria volta cheia.
func recharge() -> void:
	battery.recharge()
	_announce_battery()


## Liga ou desliga o facho e, junto com ele, o atordoamento do LightStun.
func _set_on(on: bool) -> void:
	_beam.visible = on
	_light_stun.enabled = on


## Avisa o HUD da carga, só quando o percentual inteiro mudou.
func _announce_battery() -> void:
	if hud_events == null:
		return
	var percent: int = roundi(battery.ratio() * 100.0)
	if percent != _shown_percent:
		_shown_percent = percent
		hud_events.battery_changed.emit(battery.ratio())


## Mostra um aviso curto na tela, se houver HUD.
func _hint(text: String) -> void:
	if hud_events != null:
		hud_events.hint_requested.emit(text, empty_hint_seconds)
