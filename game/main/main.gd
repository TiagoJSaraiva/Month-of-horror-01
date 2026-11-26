class_name Main
extends Node
## Cena raiz: abre no menu principal, troca entre o menu, a tela de upgrades e a run, e controla
## a captura do mouse (solto em qualquer menu, preso durante a noite).

@export var run_scene: PackedScene

var _run: Run
## Com um menu aberto, o clique pertence ao menu e não recaptura o mouse.
var _menu_open: bool = false

@onready var _main_menu: MainMenu = $MainMenu
@onready var _upgrades_screen: UpgradesScreen = $UpgradesScreen


## Liga os botões do menu principal e da tela de upgrades e abre o menu principal.
func _ready() -> void:
	_main_menu.new_run_requested.connect(_on_main_menu_new_run_requested)
	_main_menu.upgrades_requested.connect(_on_main_menu_upgrades_requested)
	_main_menu.quit_requested.connect(get_tree().quit)
	_upgrades_screen.back_requested.connect(_show_main_menu)
	_show_main_menu()


## Se o mouse estiver solto e nenhum menu aberto, um clique fora dos menus o recaptura (depois de
## trocar de janela, por exemplo) e não chega ao jogo. O Esc fica com o menu de pausa da Run. Usa
## _input, e não _unhandled_input, porque o SubViewportContainer consome os cliques antes da fase
## "unhandled".
func _input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if _menu_open or click == null or not click.pressed:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# O clique que recaptura o mouse não deve virar ação de jogo (tiro, pesca).
		get_viewport().set_input_as_handled()


## Mostra o menu principal, escondendo a tela de upgrades, e solta o mouse.
func _show_main_menu() -> void:
	_upgrades_screen.hide()
	_main_menu.open()
	_open_menu()


## Cria a Run, liga os sinais dela e a coloca na árvore com o mouse capturado.
func _start_run() -> void:
	_main_menu.hide()
	_run = run_scene.instantiate() as Run
	_run.run_over.connect(_open_menu)
	_run.menu_opened.connect(_open_menu)
	_run.menu_closed.connect(_close_menu)
	_run.new_run_requested.connect(_on_run_new_run_requested)
	_run.main_menu_requested.connect(_on_run_main_menu_requested)
	_run.quit_to_menu_requested.connect(_on_run_main_menu_requested)
	# Antes de entrar na árvore: a Run já pode abrir a seleção de cartas no _ready dela.
	_close_menu()
	add_child(_run)


## Libera a Run atual, se houver.
func _end_run() -> void:
	if _run != null:
		_run.queue_free()
		_run = null


## Marca um menu como aberto e solta o mouse.
func _open_menu() -> void:
	_menu_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Marca os menus como fechados e captura o mouse.
func _close_menu() -> void:
	_menu_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Começa uma run nova a partir do menu principal.
func _on_main_menu_new_run_requested() -> void:
	_start_run()


## Troca o menu principal pela tela de upgrades.
func _on_main_menu_upgrades_requested() -> void:
	_main_menu.hide()
	_upgrades_screen.open()


## Descarta a run atual e começa outra.
func _on_run_new_run_requested() -> void:
	_end_run()
	_start_run()


## Descarta a run atual e volta ao menu principal.
func _on_run_main_menu_requested() -> void:
	_end_run()
	_show_main_menu()
