class_name RunOverScreen
extends CanvasLayer
## Tela de fim de run: o motivo (acordo quebrado ou morte), a fala final dos clientes, quantas
## noites o jogador sobreviveu e o botão de nova run. Feita com componentes nativos do Godot:
## função antes de design.

signal new_run_requested

@onready var _title: Label = %Title
@onready var _message: Label = %Message
@onready var _nights: Label = %Nights
@onready var _new_run_button: Button = %NewRunButton


func _ready() -> void:
	hide()
	_new_run_button.pressed.connect(new_run_requested.emit)


func show_summary(title: String, message: String, nights_survived: int) -> void:
	_title.text = title
	_message.text = message
	_nights.text = _nights_text(nights_survived)
	show()
	_new_run_button.grab_focus()


func _nights_text(nights_survived: int) -> String:
	if nights_survived <= 0:
		return "You didn't survive a single night."
	if nights_survived == 1:
		return "You lasted 1 night."
	return "You lasted %d nights." % nights_survived
