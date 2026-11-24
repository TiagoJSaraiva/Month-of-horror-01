extends GdUnitTestSuite
## Voador: chega, circula, escolhe o alvo à vista, avisa, mergulha, volta e circula de novo;
## vai embora com o fim da tempestade e morto ignora tudo.

const CIRCLE_SECONDS := 2.0
const PLAYER_CHANCE := 0.5

var _brain: FlyerBrain


func before_test() -> void:
	_brain = FlyerBrain.new()


func test_arrives_and_starts_circling() -> void:
	assert_int(_brain.state).is_equal(FlyerBrain.State.ARRIVING)

	_brain.arrived(CIRCLE_SECONDS)

	assert_int(_brain.state).is_equal(FlyerBrain.State.CIRCLING)


func test_circles_before_warning() -> void:
	_brain.arrived(CIRCLE_SECONDS)

	_update(CIRCLE_SECONDS - 0.1, true, false)
	assert_int(_brain.state).is_equal(FlyerBrain.State.CIRCLING)

	_update(0.2, true, false)
	assert_int(_brain.state).is_equal(FlyerBrain.State.WARNING)
	assert_int(_brain.target).is_equal(FlyerBrain.Target.PLAYER)


func test_keeps_circling_without_targets_in_sight() -> void:
	_brain.arrived(CIRCLE_SECONDS)

	_update(CIRCLE_SECONDS, false, false)

	assert_int(_brain.state).is_equal(FlyerBrain.State.CIRCLING)
	assert_int(_brain.target).is_equal(FlyerBrain.Target.NONE)


func test_dives_after_the_warning() -> void:
	_brain.arrived(CIRCLE_SECONDS)
	_update(CIRCLE_SECONDS, false, true)

	_update(_brain.warning_seconds, false, true)

	assert_int(_brain.state).is_equal(FlyerBrain.State.DIVING)
	assert_int(_brain.target).is_equal(FlyerBrain.Target.BULB)


func test_returns_and_circles_again_after_the_dive() -> void:
	_brain.arrived(CIRCLE_SECONDS)
	_update(CIRCLE_SECONDS, true, false)
	_update(_brain.warning_seconds, true, false)

	_brain.dive_finished()
	assert_int(_brain.state).is_equal(FlyerBrain.State.RETURNING)

	_brain.returned(CIRCLE_SECONDS)
	assert_int(_brain.state).is_equal(FlyerBrain.State.CIRCLING)


func test_pick_target_prefers_what_is_in_sight() -> void:
	assert_int(FlyerBrain.pick_target(true, false, 0.9, PLAYER_CHANCE)).is_equal(
		FlyerBrain.Target.PLAYER
	)
	assert_int(FlyerBrain.pick_target(false, true, 0.1, PLAYER_CHANCE)).is_equal(
		FlyerBrain.Target.BULB
	)
	assert_int(FlyerBrain.pick_target(false, false, 0.1, PLAYER_CHANCE)).is_equal(
		FlyerBrain.Target.NONE
	)


func test_pick_target_rolls_when_both_are_in_sight() -> void:
	assert_int(FlyerBrain.pick_target(true, true, 0.2, PLAYER_CHANCE)).is_equal(
		FlyerBrain.Target.PLAYER
	)
	assert_int(FlyerBrain.pick_target(true, true, 0.8, PLAYER_CHANCE)).is_equal(
		FlyerBrain.Target.BULB
	)


func test_leaves_from_any_state() -> void:
	_brain.arrived(CIRCLE_SECONDS)
	_update(CIRCLE_SECONDS, true, false)

	_brain.leave()

	assert_int(_brain.state).is_equal(FlyerBrain.State.LEAVING)


func test_dead_ignores_everything() -> void:
	_brain.arrived(CIRCLE_SECONDS)

	_brain.kill()
	_update(CIRCLE_SECONDS, true, true)
	_brain.leave()
	_brain.returned(CIRCLE_SECONDS)

	assert_int(_brain.state).is_equal(FlyerBrain.State.DEAD)


func _update(delta: float, player_visible: bool, bulb_visible: bool) -> void:
	_brain.update(delta, player_visible, bulb_visible, 0.0, PLAYER_CHANCE)
