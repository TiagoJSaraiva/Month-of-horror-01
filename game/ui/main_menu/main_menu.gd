class_name MainMenu
extends CanvasLayer
## Menu principal: nova run, upgrades e sair, com os pontos guardados. O título é o nome do
## projeto. Feito com componentes nativos do Godot: função antes de design.

signal new_run_requested
signal upgrades_requested
signal quit_requested

@onready var _title: Label = %Title
@onready var _points: Label = %Points
@onready var _new_run_button: Button = %NewRunButton
@onready var _upgrades_button: Button = %UpgradesButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_title.text = str(ProjectSettings.get_setting("application/config/name"))
	_new_run_button.pressed.connect(new_run_requested.emit)
	_upgrades_button.pressed.connect(upgrades_requested.emit)
	_quit_button.pressed.connect(quit_requested.emit)


## Mostra o menu com os pontos atuais.
func open() -> void:
	_points.text = "Points: %d" % MetaProgress.state.points
	show()
	_new_run_button.grab_focus()
