class_name RunOverScreen
extends CanvasLayer
## Tela de fim de run: o motivo (acordo quebrado ou morte), a fala final dos clientes, quantas
## noites o jogador sobreviveu, os pontos ganhos e os botões de nova run e de menu principal.
## Feita com componentes nativos do Godot: função antes de design.

signal new_run_requested
signal main_menu_requested

@onready var _title: Label = %Title
@onready var _message: Label = %Message
@onready var _nights: Label = %Nights
@onready var _points: Label = %Points
@onready var _new_run_button: Button = %NewRunButton
@onready var _main_menu_button: Button = %MainMenuButton


## Começa escondida e liga os botões aos sinais.
func _ready() -> void:
	hide()
	_new_run_button.pressed.connect(new_run_requested.emit)
	_main_menu_button.pressed.connect(main_menu_requested.emit)


## Mostra o motivo do fim, a fala final, as noites vividas e os pontos ganhos.
func show_summary(title: String, message: String, nights_survived: int, points: int) -> void:
	_title.text = title
	_message.text = message
	_nights.text = _nights_text(nights_survived)
	_points.text = "Points earned: %d" % points
	show()
	_new_run_button.grab_focus()


## Devolve a frase com as noites sobrevividas, no singular para uma noite.
func _nights_text(nights_survived: int) -> String:
	if nights_survived <= 0:
		return "You didn't survive a single night."
	if nights_survived == 1:
		return "You lasted 1 night."
	return "You lasted %d nights." % nights_survived
