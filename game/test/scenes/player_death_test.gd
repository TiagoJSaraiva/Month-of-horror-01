extends GdUnitTestSuite
## Comportamento principal da morte: o jogador sem vida encerra a run na hora, com a tela de
## fim de run de morte.

const RUN_SCENE := "res://run/run.tscn"
const SHORT_TRANSITION_SECONDS := 0.05
const LETHAL_DAMAGE := 1000.0


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

	player.health.damage(LETHAL_DAMAGE)
	await await_millis(300)

	assert_bool(run.state.died).is_true()
	assert_bool(run.state.is_over()).is_true()
	assert_int(run_over_count[0]).is_equal(1)
	assert_bool(run_over_screen.visible).is_true()
	assert_str((run_over_screen.find_child("Title") as Label).text).is_equal(Run.DEATH_TITLE)
