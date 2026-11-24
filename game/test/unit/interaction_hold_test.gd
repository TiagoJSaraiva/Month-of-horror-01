extends GdUnitTestSuite
## Segurar a interação: completa uma única vez ao atingir a duração e zera ao cancelar.

var _hold: InteractionHold


func before_test() -> void:
	_hold = InteractionHold.new()


func test_starts_inactive() -> void:
	assert_bool(_hold.is_active()).is_false()
	assert_bool(_hold.advance(1.0)).is_false()


func test_progress_grows_while_held() -> void:
	_hold.start(2.0)

	assert_bool(_hold.advance(0.5)).is_false()

	assert_bool(_hold.is_active()).is_true()
	assert_float(_hold.ratio()).is_equal_approx(0.25, 0.001)


func test_completes_once_when_duration_is_reached() -> void:
	_hold.start(1.0)

	assert_bool(_hold.advance(0.6)).is_false()
	assert_bool(_hold.advance(0.6)).is_true()
	assert_bool(_hold.advance(0.6)).is_false()
	assert_bool(_hold.is_active()).is_false()
	assert_float(_hold.ratio()).is_equal_approx(1.0, 0.001)


func test_cancel_resets_progress() -> void:
	_hold.start(1.0)
	_hold.advance(0.5)

	_hold.cancel()

	assert_bool(_hold.is_active()).is_false()
	assert_float(_hold.ratio()).is_equal(0.0)
	assert_bool(_hold.advance(1.0)).is_false()


func test_zero_duration_completes_on_first_advance() -> void:
	_hold.start(0.0)

	assert_bool(_hold.advance(0.0)).is_true()
