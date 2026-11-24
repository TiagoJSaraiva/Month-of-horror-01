class_name PauseMenu
extends CanvasLayer
## Menu de pausa: continuar ou sair para o menu principal (conta como derrota, e os pontos da
## run são pagos). Continua processando com o jogo pausado, por isso é ele quem ouve o Esc; a
## Run decide se a pausa pode abrir.

signal toggle_requested
signal resume_requested
signal quit_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(resume_requested.emit)
	_quit_button.pressed.connect(quit_requested.emit)


# Usa _input porque o SubViewportContainer da Run consome os eventos antes da fase "unhandled".
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		toggle_requested.emit()
		get_viewport().set_input_as_handled()


func open() -> void:
	show()
	_resume_button.grab_focus()


func close() -> void:
	hide()
