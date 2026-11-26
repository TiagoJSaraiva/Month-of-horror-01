class_name FishingRod
extends Node3D
## Vara de pesca na mão direita: mira a água, lança, troca de isca e conduz a tentativa.
## As regras ficam em FishingAttempt; aqui entram só o input, o visual e as mensagens.

@export var hands: Hands
@export var hud_events: HudEvents
@export var baits: Array[BaitData] = []
## Multiplica a velocidade da captura no minijogo. Cartas e upgrades vão aumentar.
@export var fishing_power: float = 1.0
## Chance, de 0 a 1, de o peixe pescado vir em dobro (carta lendária).
@export var double_catch_chance: float = 0.0
## Quanto tempo, em segundos, as mensagens de resultado ficam na tela.
@export var result_hint_seconds: float = 2.5

var _bait_index: int = 0
var _attempt: FishingAttempt
var _rng := RandomNumberGenerator.new()

@onready var _model: Node3D = $Model
@onready var _aim: RayCast3D = $Aim
@onready var _bobber: Bobber = $Bobber


## Esconde a boia e liga os sinais. Sem Hands, HudEvents ou iscas, avisa e a vara não funciona.
func _ready() -> void:
	_rng.randomize()
	_bobber.hide()
	if hands == null or hud_events == null or baits.is_empty():
		push_warning("FishingRod sem Hands, HudEvents ou iscas: a vara não funciona.")
		return
	hands.changed.connect(_on_hands_changed)
	_on_hands_changed()
	hud_events.bait_changed.emit(_current_bait().display_name)


## Com a vara na mão, o botão primário lança ou fisga, o secundário desiste e a tecla de isca troca
## de isca.
func _unhandled_input(event: InputEvent) -> void:
	if hands == null or baits.is_empty() or not hands.state.is_tool_ready(HandsState.Tool.ROD):
		return
	if event.is_action_pressed(&"primary_action"):
		if _attempt == null:
			_try_cast()
		else:
			_attempt.hook()
	elif event.is_action_pressed(&"secondary_action") and _attempt != null:
		_attempt.cancel()
	elif event.is_action_pressed(&"cycle_bait") and _attempt == null:
		_bait_index = posmod(_bait_index + 1, baits.size())
		hud_events.bait_changed.emit(_current_bait().display_name)
	else:
		return
	get_viewport().set_input_as_handled()


## Avança a tentativa em andamento, com o botão primário como o de puxar no minijogo.
func _process(delta: float) -> void:
	if _attempt != null:
		_attempt.update(delta, Input.is_action_pressed(&"primary_action"))


## Lança a linha se a mira está na água. Senão, mostra um aviso.
func _try_cast() -> void:
	_aim.force_raycast_update()
	if not _aim.get_collider() is WaterSurface:
		hud_events.hint_requested.emit("Aim at the water to cast.", result_hint_seconds)
		return
	_attempt = FishingAttempt.new(_current_bait().fish, fishing_power, _rng)
	_attempt.state_changed.connect(_on_attempt_state_changed)
	hands.state.tool_busy = true
	_bobber.drop_at(_aim.get_collision_point())
	hud_events.hint_requested.emit("Waiting for a bite...", 0.0)


## Isca selecionada.
func _current_bait() -> BaitData:
	return baits[_bait_index]


## Mostra no HUD e na boia o que cada estado da tentativa pede do jogador.
func _on_attempt_state_changed(state: FishingAttempt.State) -> void:
	match state:
		FishingAttempt.State.BITING:
			_bobber.set_biting(true)
			hud_events.hint_requested.emit("Something's biting! Click to hook it.", 0.0)
		FishingAttempt.State.REELING:
			hud_events.hint_requested.emit("Hold the mouse button to reel.", 0.0)
			hud_events.minigame_started.emit(_attempt.minigame)
		FishingAttempt.State.CAUGHT:
			_finish("You caught a %s!" % _attempt.fish.display_name)
		FishingAttempt.State.ESCAPED:
			_finish("It got away...")
		FishingAttempt.State.CANCELLED:
			_finish("")


## Encerra a tentativa: recolhe a boia, libera as mãos, mostra a mensagem e entrega o peixe pescado,
## às vezes em dobro.
func _finish(message: String) -> void:
	var caught_fish: FishData = (
		_attempt.fish if _attempt.state == FishingAttempt.State.CAUGHT else null
	)
	if _attempt.minigame != null:
		hud_events.minigame_finished.emit()
	_attempt = null
	_bobber.pull_out()
	hands.state.tool_busy = false
	hud_events.hint_requested.emit(message, result_hint_seconds)
	# O peixe vai para as mãos só depois de a vara liberar as mãos.
	if caught_fish != null:
		var amount: int = 2 if _rng.randf() < double_catch_chance else 1
		hands.carry_item(caught_fish, amount)


## Mostra a vara só quando ela é a ferramenta na mão; guardá-la com a linha na água cancela a
## tentativa.
func _on_hands_changed() -> void:
	_model.visible = hands.state.is_tool_ready(HandsState.Tool.ROD)
	# Sacar o revólver com a linha na água recolhe a linha: o peixe em andamento se perde.
	if _attempt != null and hands.state.tool != HandsState.Tool.ROD:
		_attempt.cancel()
