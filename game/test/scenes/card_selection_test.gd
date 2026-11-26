extends GdUnitTestSuite
## Comportamento principal da seleção de cartas: a run começa na seleção, sem noite; escolher
## uma carta a equipa, fecha a tela e começa a noite 1.

const RUN_SCENE: String = "res://run/run.tscn"


func test_choosing_a_card_equips_it_and_starts_the_first_night() -> void:
	var runner: GdUnitSceneRunner = scene_runner(RUN_SCENE)
	var run: Run = runner.scene() as Run
	var cards: CardSelectionScreen = runner.find_child("CardSelectionScreen") as CardSelectionScreen
	# Array para a lambda alterar o contador por referência.
	var closed: Array[int] = [0]
	run.menu_closed.connect(func() -> void: closed[0] += 1)
	await await_millis(50)

	assert_bool(cards.visible).is_true()
	assert_object(run.current_night()).is_null()
	assert_int(cards.card_buttons().size()).is_equal(3)

	cards.card_buttons()[0].pressed.emit()
	await await_millis(50)

	assert_bool(cards.visible).is_false()
	assert_int(run.state.equipped.size()).is_equal(1)
	assert_int(run.state.card_pool.size()).is_equal(8)
	assert_object(run.current_night()).is_not_null()
	assert_int(closed[0]).is_equal(1)
