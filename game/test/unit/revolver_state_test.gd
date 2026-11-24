extends GdUnitTestSuite
## Revólver: cada tiro gasta uma bala, a cadência separa os tiros e a recarga leva tempo e
## enche o tambor.

const CAPACITY := 6
const FIRE_INTERVAL := 0.35
const RELOAD_SECONDS := 2.0

var _revolver: RevolverState


func before_test() -> void:
	_revolver = RevolverState.new(CAPACITY, FIRE_INTERVAL, RELOAD_SECONDS)


func test_starts_loaded() -> void:
	assert_int(_revolver.loaded).is_equal(CAPACITY)
	assert_bool(_revolver.can_fire()).is_true()


func test_firing_spends_a_bullet() -> void:
	assert_bool(_revolver.fire()).is_true()

	assert_int(_revolver.loaded).is_equal(CAPACITY - 1)


func test_fire_interval_separates_shots() -> void:
	_revolver.fire()

	assert_bool(_revolver.fire()).is_false()
	_revolver.update(FIRE_INTERVAL)
	assert_bool(_revolver.fire()).is_true()


func test_empty_cylinder_does_not_fire() -> void:
	for i: int in CAPACITY:
		_revolver.fire()
		_revolver.update(FIRE_INTERVAL)

	assert_int(_revolver.loaded).is_equal(0)
	assert_bool(_revolver.fire()).is_false()


func test_reload_takes_time_and_fills_the_cylinder() -> void:
	_revolver.fire()

	assert_bool(_revolver.start_reload()).is_true()
	_revolver.update(RELOAD_SECONDS - 0.1)
	assert_bool(_revolver.is_reloading()).is_true()
	assert_int(_revolver.loaded).is_equal(CAPACITY - 1)

	_revolver.update(0.2)
	assert_bool(_revolver.is_reloading()).is_false()
	assert_int(_revolver.loaded).is_equal(CAPACITY)


func test_full_cylinder_does_not_reload() -> void:
	assert_bool(_revolver.start_reload()).is_false()


func test_cannot_fire_while_reloading() -> void:
	_revolver.fire()
	_revolver.update(FIRE_INTERVAL)
	_revolver.start_reload()

	assert_bool(_revolver.fire()).is_false()


func test_cancel_reload_keeps_the_bullets() -> void:
	_revolver.fire()
	_revolver.start_reload()

	_revolver.cancel_reload()
	_revolver.update(RELOAD_SECONDS)

	assert_bool(_revolver.is_reloading()).is_false()
	assert_int(_revolver.loaded).is_equal(CAPACITY - 1)
