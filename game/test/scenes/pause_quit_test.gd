extends GdUnitTestSuite
## Comportamento principal da pausa: na noite, o Esc pausa o jogo e abre o menu; sair para o
## menu despausa, paga os pontos da run (os peixes entregues) e pede a volta ao menu principal.

const RUN_SCENE := "res://run/run.tscn"
const TEST_SAVE_PATH := "user://test_pause_quit_meta.cfg"
const MACKEREL: FishData = preload("res://fish/data/mackerel.tres")
const DELIVERED_FISH := 2


func before_test() -> void:
	MetaProgress.use_save_path(TEST_SAVE_PATH)


func after_test() -> void:
	# Um teste que falhe no meio não pode deixar a árvore pausada para os seguintes.
	Engine.get_main_loop().paused = false
	MetaProgress.use_save_path(MetaProgress.DEFAULT_SAVE_PATH)
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)


func test_pausing_and_quitting_pays_the_points() -> void:
	var runner: GdUnitSceneRunner = scene_runner(RUN_SCENE)
	var run := runner.scene() as Run
	var pause_menu := runner.find_child("PauseMenu") as PauseMenu
	# Array para a lambda alterar o contador por referência.
	var quit_count: Array[int] = [0]
	run.quit_to_menu_requested.connect(func() -> void: quit_count[0] += 1)
	var cards := runner.find_child("CardSelectionScreen") as CardSelectionScreen
	cards.card_buttons()[0].pressed.emit()
	await await_millis(100)
	run.current_night().order.deliver(MACKEREL, DELIVERED_FISH)

	# Com a árvore pausada, os timers do gdUnit4 param: o Esc vai direto para o Input e a espera
	# é por frames, que continuam com o jogo pausado.
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	Input.parse_input_event(escape)
	await run.get_tree().process_frame
	await run.get_tree().process_frame

	assert_bool(run.get_tree().paused).is_true()
	assert_bool(pause_menu.visible).is_true()

	(pause_menu.find_child("QuitButton") as Button).pressed.emit()

	assert_bool(run.get_tree().paused).is_false()
	assert_int(quit_count[0]).is_equal(1)
	assert_int(MetaProgress.state.points).is_equal(DELIVERED_FISH)
