extends GdUnitTestSuite
## Regras do movimento horizontal do jogador.

const MAX_SPEED: float = 3.5
const ACCELERATION: float = 20.0
const DECELERATION: float = 25.0
const DELTA: float = 1.0 / 60.0
const TOLERANCE: float = 0.001


func test_accelerates_toward_wish_direction() -> void:
	var velocity: Vector3 = _step(Vector3.ZERO, Vector3.FORWARD, DELTA)

	assert_float(-velocity.z).is_between(TOLERANCE, ACCELERATION * DELTA + TOLERANCE)
	assert_float(absf(velocity.x)).is_less(TOLERANCE)


func test_reaches_but_never_exceeds_max_speed() -> void:
	var velocity: Vector3 = Vector3.ZERO
	for _frame: int in 120:
		velocity = _step(velocity, Vector3.FORWARD, DELTA)
		assert_float(velocity.length()).is_less_equal(MAX_SPEED + TOLERANCE)

	assert_float(velocity.length()).is_between(MAX_SPEED - TOLERANCE, MAX_SPEED + TOLERANCE)


func test_diagonal_input_is_not_faster() -> void:
	var velocity: Vector3 = Vector3.ZERO
	for _frame: int in 120:
		velocity = _step(velocity, Vector3(1.0, 0.0, -1.0), DELTA)

	assert_float(velocity.length()).is_less_equal(MAX_SPEED + TOLERANCE)


func test_decelerates_to_stop_without_input() -> void:
	var velocity: Vector3 = Vector3(0.0, 0.0, -MAX_SPEED)
	for _frame: int in 60:
		velocity = _step(velocity, Vector3.ZERO, DELTA)

	assert_float(velocity.length()).is_less(TOLERANCE)


func test_large_delta_does_not_overshoot_target() -> void:
	var velocity: Vector3 = _step(Vector3.ZERO, Vector3.FORWARD, 10.0)

	assert_float(velocity.length()).is_between(MAX_SPEED - TOLERANCE, MAX_SPEED + TOLERANCE)


func test_ignores_vertical_components() -> void:
	var velocity: Vector3 = _step(Vector3(0.0, -5.0, 0.0), Vector3(0.0, 1.0, -1.0), DELTA)

	assert_float(velocity.y).is_equal(0.0)


func _step(current: Vector3, wish_direction: Vector3, delta: float) -> Vector3:
	return MovementRules.next_horizontal_velocity(
		current, wish_direction, MAX_SPEED, ACCELERATION, DECELERATION, delta
	)
