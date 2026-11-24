extends GdUnitTestSuite
## Comportamento principal da morte: o jogador sem vida encerra a run na hora, com a tela de
## fim de run de morte, e os peixes entregues naquela noite viram pontos.

const RUN_SCENE := "res://run/run.tscn"
const SHORT_TRANSITION_SECONDS := 0.05
const LETHAL_DAMAGE := 1000.0
## Save próprio do teste, para não mexer no progresso do jogador.
const TEST_SAVE_PATH := "user://test_player_death_meta.cfg"
const MACKEREL: FishData = preload("res://fish/data/mackerel.tres")
const DELIVERED_FISH := 3


func before_test() -> void:
	MetaProgress.use_save_path(TEST_SAVE_PATH)


func after_test() -> void:
	MetaProgress.use_save_path(MetaProgress.DEFAULT_SAVE_PATH)
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)


func test_player_death_ends_the_run() -> void:
	var runner: GdUnitSceneRunner = scene_runner(RUN_SCENE)
	var run := runner.scene() as Run
	var overlay := runner.find_child("TransitionOverlay") as TransitionOverlay
	overlay.cover_seconds = SHORT_TRANSITION_SECONDS
	var run_over_screen := runner.find_child("RunOverScreen") as RunOverScreen
	# Array para a lambda alterar o contador por referência.
	var run_over_count: Array[int] = [0]
	run.run_over.connect(func() -> void: run_over_count[0] += 1)
	var cards := runner.find_child("CardSelectionScreen") as CardSelectionScreen
	cards.card_buttons()[0].pressed.emit()
	await await_millis(100)
	var player := run.current_night().find_child("Player") as Player
	run.current_night().order.deliver(MACKEREL, DELIVERED_FISH)

	player.health.damage(LETHAL_DAMAGE)
	await await_millis(300)

	assert_bool(run.state.died).is_true()
	assert_bool(run.state.is_over()).is_true()
	assert_int(run_over_count[0]).is_equal(1)
	assert_bool(run_over_screen.visible).is_true()
	assert_str((run_over_screen.find_child("Title") as Label).text).is_equal(Run.DEATH_TITLE)
	# Nenhuma noite cumprida; 1 ponto por peixe entregue.
	assert_int(MetaProgress.state.points).is_equal(DELIVERED_FISH)
