class_name Run
extends Node
## Uma run: cria cada noite, avalia o pedido no amanhecer, passa para a próxima noite e
## encerra a run na terceira falha. As regras ficam em RunState e RunRules (decisão 0013).

signal run_over
signal new_run_requested

@export var night_scene: PackedScene
@export var note_lines: NoteLines
## Tempo parado na tela do amanhecer antes de seguir, em segundos.
@export var dawn_hold_seconds: float = 3.0

var state := RunState.new()

var _night: Night

@onready var _hud: Hud = $Hud
@onready var _night_viewport: SubViewport = $LowResView/SubViewport
@onready var _transition: TransitionOverlay = $TransitionOverlay
@onready var _run_over_screen: RunOverScreen = $RunOverScreen


func _ready() -> void:
	_run_over_screen.new_run_requested.connect(new_run_requested.emit)
	_start_night()


## Noite em andamento.
func current_night() -> Night:
	return _night


func _start_night() -> void:
	var kind: RunRules.NoteKind = RunRules.note_kind(state.last_outcome, state.failures)
	_night = night_scene.instantiate() as Night
	_night.night_number = state.night_number
	_night.table_note_text = note_lines.text_for(kind)
	_night.table_note_pin = RunRules.pin_for(kind)
	_night.night_finished.connect(_on_night_night_finished)
	_night_viewport.add_child(_night)
	_hud.reset()
	_transition.reveal("NIGHT %d" % state.night_number)


func _on_night_night_finished(order: NightOrder) -> void:
	_hud.hide()
	await _transition.play_dawn()
	await get_tree().create_timer(dawn_hold_seconds).timeout
	state.finish_night(order.missing_total())
	if state.is_over():
		_run_over_screen.show_summary(note_lines.run_over, state.night_number)
		run_over.emit()
		return
	await _transition.cover()
	# A noite antiga sai no fim do frame; a nova entra já coberta pela tela preta.
	_night.queue_free()
	_start_night()
