class_name Hud
extends CanvasLayer
## HUD em resolução nativa: mira, ação disponível, dicas e isca atual.
## Recebe tudo pelo HudEvents (decisão 0012).

const INTERACT_KEY_LABEL := "[E]"

@export var hud_events: HudEvents

@onready var _prompt: Label = $Prompt
@onready var _hint: Label = $Hint
@onready var _bait: Label = $Bait
@onready var _hint_timer: Timer = $HintTimer


func _ready() -> void:
	_prompt.text = ""
	_hint.text = ""
	_bait.text = ""
	_hint_timer.timeout.connect(_on_hint_timer_timeout)
	if hud_events == null:
		push_warning("Hud sem HudEvents: nada do mundo aparece na tela.")
		return
	hud_events.prompt_changed.connect(_on_hud_events_prompt_changed)
	hud_events.hint_requested.connect(_on_hud_events_hint_requested)
	hud_events.bait_changed.connect(_on_hud_events_bait_changed)


func _on_hud_events_prompt_changed(text: String) -> void:
	_prompt.text = "" if text.is_empty() else "%s %s" % [INTERACT_KEY_LABEL, text]


func _on_hud_events_hint_requested(text: String, seconds: float) -> void:
	_hint.text = text
	if seconds > 0.0:
		_hint_timer.start(seconds)
	else:
		_hint_timer.stop()


func _on_hud_events_bait_changed(bait_name: String) -> void:
	_bait.text = "Bait: %s" % bait_name


func _on_hint_timer_timeout() -> void:
	_hint.text = ""
