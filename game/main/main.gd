class_name Main
extends Node
## Cena raiz: começa uma run, recomeça quando o jogador pede e controla a captura do mouse.
## Os menus (M8) entram aqui; a captura do mouse durante o jogo vai para o menu de pausa.

@export var run_scene: PackedScene

var _run: Run
## Com um menu aberto, o clique pertence ao menu e não recaptura o mouse.
var _menu_open: bool = false


func _ready() -> void:
	_start_run()


# Usa _input, e não _unhandled_input, porque o SubViewportContainer consome os cliques
# antes que eles cheguem à fase "unhandled".
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return
	var click := event as InputEventMouseButton
	if _menu_open or click == null or not click.pressed:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# O clique que recaptura o mouse não deve virar ação de jogo (tiro, pesca).
		get_viewport().set_input_as_handled()


func _start_run() -> void:
	_run = run_scene.instantiate() as Run
	_run.run_over.connect(_open_menu)
	_run.menu_opened.connect(_open_menu)
	_run.menu_closed.connect(_close_menu)
	_run.new_run_requested.connect(_on_run_new_run_requested)
	# Antes de entrar na árvore: a Run já pode abrir a seleção de cartas no _ready dela.
	_close_menu()
	add_child(_run)


func _open_menu() -> void:
	_menu_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _close_menu() -> void:
	_menu_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_run_new_run_requested() -> void:
	_run.queue_free()
	_start_run()
