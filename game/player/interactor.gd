class_name Interactor
extends RayCast3D
## Mira de interação do jogador: acha o Interactable à frente, anuncia a ação disponível no
## HUD e a executa com E.

@export var hands: Hands
@export var hud_events: HudEvents

var _focused: Interactable
var _prompt: String = ""


func _ready() -> void:
	if hands == null or hud_events == null:
		push_warning("Interactor sem Hands ou HudEvents: a interação não funciona.")
		set_physics_process(false)
		set_process_unhandled_input(false)


func _physics_process(_delta: float) -> void:
	var target := get_collider() as Interactable
	var prompt: String = target.get_prompt(hands) if target != null else ""
	_focused = target if not prompt.is_empty() else null
	if prompt != _prompt:
		_prompt = prompt
		hud_events.prompt_changed.emit(prompt)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and _focused != null:
		_focused.interact(hands)
		get_viewport().set_input_as_handled()
