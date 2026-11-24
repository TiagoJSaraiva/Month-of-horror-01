class_name RunOverScreen
extends CanvasLayer
## Tela de fim de run: a fala final dos clientes, quantas noites o jogador durou e o botão de
## nova run. Feita com componentes nativos do Godot: função antes de design.

signal new_run_requested

@onready var _message: Label = %Message
@onready var _nights: Label = %Nights
@onready var _new_run_button: Button = %NewRunButton


func _ready() -> void:
	hide()
	_new_run_button.pressed.connect(new_run_requested.emit)


func show_summary(message: String, nights_lasted: int) -> void:
	_message.text = message
	_nights.text = (
		"You lasted 1 night." if nights_lasted == 1 else "You lasted %d nights." % nights_lasted
	)
	show()
	_new_run_button.grab_focus()
