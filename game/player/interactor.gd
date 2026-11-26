class_name Interactor
extends RayCast3D
## Mira de interação do jogador: acha o Interactable à frente, anuncia a ação disponível no
## HUD e a executa com E. Ações demoradas exigem segurar E sem tirar a mira do alvo; o
## progresso vai para o HUD. Avisa o objeto quando a mira sai dele.

const HOLD_PROMPT_FORMAT := "%s (hold)"

@export var hands: Hands
@export var hud_events: HudEvents

## Interactable na mira, tenha ação disponível ou não.
var _target: Interactable
## Interactable na mira com ação disponível.
var _focused: Interactable
var _prompt: String = ""
var _hold := InteractionHold.new()
## Alvo da ação sendo segurada. Outro alvo com o mesmo texto (outra lâmpada) não continua.
var _hold_target: Interactable


## Desliga a mira quando falta Hands ou HudEvents.
func _ready() -> void:
	if hands == null or hud_events == null:
		push_warning("Interactor sem Hands ou HudEvents: a interação não funciona.")
		set_physics_process(false)
		set_process_unhandled_input(false)


## Acha o Interactable na mira, avisa o alvo anterior que perdeu o foco, atualiza a dica no HUD e
## avança a ação segurada.
func _physics_process(delta: float) -> void:
	var target := get_collider() as Interactable
	if target != _target:
		# O alvo anterior pode ter sido liberado (um peixe pego do convés, por exemplo).
		if is_instance_valid(_target):
			_target.focus_exited()
		_target = target
	var prompt: String = target.get_prompt(hands) if target != null else ""
	_focused = target if not prompt.is_empty() else null
	if prompt != _prompt:
		_prompt = prompt
		hud_events.prompt_changed.emit(_prompt_text())
	_update_hold(delta)


## A tecla E executa a ação do alvo na hora ou, se ela exige segurar, começa a contar o tempo.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"interact") or _focused == null:
		return
	var hold_seconds: float = _focused.get_hold_seconds(hands)
	if hold_seconds <= 0.0:
		_focused.interact(hands)
	else:
		_hold.start(hold_seconds)
		_hold_target = _focused
	get_viewport().set_input_as_handled()


## Devolve a dica do HUD, com "(hold)" se a ação exige segurar; vazia sem alvo.
func _prompt_text() -> String:
	if _focused == null:
		return ""
	if _focused.get_hold_seconds(hands) > 0.0:
		return HOLD_PROMPT_FORMAT % _prompt
	return _prompt


## Avança a ação segurada e atualiza o progresso no HUD; cancela se E foi solto ou o alvo mudou, e
## executa ao completar.
func _update_hold(delta: float) -> void:
	if not _hold.is_active():
		return
	# Soltar E, tirar a mira do alvo ou a ação deixar de existir cancelam o progresso.
	if _focused == null or _focused != _hold_target or not Input.is_action_pressed(&"interact"):
		_hold.cancel()
		_hold_target = null
		hud_events.hold_progress_changed.emit(0.0)
		return
	if _hold.advance(delta):
		_hold_target = null
		hud_events.hold_progress_changed.emit(0.0)
		_focused.interact(hands)
	else:
		hud_events.hold_progress_changed.emit(_hold.ratio())
