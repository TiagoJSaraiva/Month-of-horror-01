extends GdUnitTestSuite
## Comportamento principal da run: um pedido não cumprido custa uma vida e, depois da seleção
## de cartas, a próxima noite começa com o pedido maior e o bilhete de aviso na mesa.

const RUN_SCENE: String = "res://run/run.tscn"
const SHORT_NIGHT_SECONDS: float = 0.3
const SHORT_TRANSITION_SECONDS: float = 0.05
const POLL_MILLIS: int = 50
const TIMEOUT_MILLIS: int = 4000


func test_unfinished_order_costs_a_life_and_starts_the_next_night() -> void:
	var runner: GdUnitSceneRunner = scene_runner(RUN_SCENE)
	var run: Run = runner.scene() as Run
	_shorten_transitions(runner, run)
	var cards: CardSelectionScreen = runner.find_child("CardSelectionScreen") as CardSelectionScreen
	cards.card_buttons()[0].pressed.emit()
	var clock: NightClock = run.current_night().find_child("NightClock") as NightClock
	clock.duration_seconds = SHORT_NIGHT_SECONDS

	# Entre as noites há outra seleção: escolhe a primeira carta e espera a noite 2.
	var waited: int = 0
	while (
		(run.current_night() == null or run.current_night().night_number < 2)
		and waited < TIMEOUT_MILLIS
	):
		if cards.visible:
			cards.card_buttons()[0].pressed.emit()
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS

	var night: Night = run.current_night()
	assert_int(night.night_number).is_equal(2)
	assert_int(run.state.failures).is_equal(1)
	assert_int(night.order.missing_total()).is_equal(OrderRules.fish_count(2))
	assert_int(night.table_note_pin).is_equal(RunRules.Pin.YELLOW)


func _shorten_transitions(runner: GdUnitSceneRunner, run: Run) -> void:
	run.dawn_hold_seconds = SHORT_TRANSITION_SECONDS
	var overlay: TransitionOverlay = runner.find_child("TransitionOverlay") as TransitionOverlay
	overlay.dawn_fade_seconds = SHORT_TRANSITION_SECONDS
	overlay.message_fade_seconds = SHORT_TRANSITION_SECONDS
	overlay.cover_seconds = SHORT_TRANSITION_SECONDS
	overlay.title_hold_seconds = SHORT_TRANSITION_SECONDS
	overlay.reveal_seconds = SHORT_TRANSITION_SECONDS
