class_name Hud
extends CanvasLayer
## HUD em resolução nativa: mira, ação disponível e progresso de segurar E, dicas, isca atual,
## bateria da lanterna, minijogo de pesca e bilhete da mesa. Recebe tudo pelo HudEvents
## (decisão 0012).

const INTERACT_KEY_LABEL := "[E]"

@export var hud_events: HudEvents

@onready var _prompt: Label = $Prompt
@onready var _hold_bar: ProgressBar = $HoldBar
@onready var _hint: Label = $Hint
@onready var _bait: Label = $Bait
@onready var _battery_bar: ProgressBar = $Battery/Bar
@onready var _hint_timer: Timer = $HintTimer
@onready var _minigame_view: FishingMinigameView = $FishingMinigameView
@onready var _note_panel: Control = $NotePanel
@onready var _note_text: Label = $NotePanel/NoteText


func _ready() -> void:
	_bait.text = ""
	reset()
	_hint_timer.timeout.connect(_on_hint_timer_timeout)
	if hud_events == null:
		push_warning("Hud sem HudEvents: nada do mundo aparece na tela.")
		return
	hud_events.prompt_changed.connect(_on_hud_events_prompt_changed)
	hud_events.hint_requested.connect(_on_hud_events_hint_requested)
	hud_events.bait_changed.connect(_on_hud_events_bait_changed)
	hud_events.minigame_started.connect(_minigame_view.show_minigame)
	hud_events.minigame_finished.connect(_minigame_view.hide_minigame)
	hud_events.note_opened.connect(_on_hud_events_note_opened)
	hud_events.note_closed.connect(_note_panel.hide)
	hud_events.hold_progress_changed.connect(_on_hud_events_hold_progress_changed)
	hud_events.battery_changed.connect(_on_hud_events_battery_changed)


## Limpa o que sobrou da noite anterior e mostra o HUD. A isca é mantida: a vara da nova
## noite a anuncia de novo.
func reset() -> void:
	_prompt.text = ""
	_hold_bar.hide()
	_hint.text = ""
	_hint_timer.stop()
	_minigame_view.hide_minigame()
	_note_panel.hide()
	show()


func _on_hud_events_prompt_changed(text: String) -> void:
	_prompt.text = "" if text.is_empty() else "%s %s" % [INTERACT_KEY_LABEL, text]


func _on_hud_events_hold_progress_changed(ratio: float) -> void:
	_hold_bar.value = ratio
	_hold_bar.visible = ratio > 0.0


func _on_hud_events_hint_requested(text: String, seconds: float) -> void:
	_hint.text = text
	if seconds > 0.0:
		_hint_timer.start(seconds)
	else:
		_hint_timer.stop()


func _on_hud_events_bait_changed(bait_name: String) -> void:
	_bait.text = "Bait: %s" % bait_name


func _on_hud_events_battery_changed(ratio: float) -> void:
	_battery_bar.value = ratio


func _on_hud_events_note_opened(text: String) -> void:
	_note_text.text = text
	_note_panel.show()


func _on_hint_timer_timeout() -> void:
	_hint.text = ""
