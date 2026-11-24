class_name Main
extends Node
## Cena raiz do jogo: liga a noite à interface e controla a captura do mouse.
## O menu de pausa (M8) vai assumir a captura do mouse.

@onready var _night: Night = %Night
@onready var _dawn_overlay: DawnOverlay = $DawnOverlay


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_night.night_finished.connect(_on_night_night_finished)


# Usa _input, e não _unhandled_input, porque o SubViewportContainer consome os cliques
# antes que eles cheguem à fase "unhandled".
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return
	var click := event as InputEventMouseButton
	if click != null and click.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# O clique que recaptura o mouse não deve virar ação de jogo (tiro, pesca).
		get_viewport().set_input_as_handled()


func _on_night_night_finished(_order: NightOrder) -> void:
	_dawn_overlay.play()
