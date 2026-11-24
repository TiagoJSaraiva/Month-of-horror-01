extends GdUnitTestSuite
## Bateria da lanterna: gasta com a luz acesa, avisa uma vez quando acaba e só volta cheia
## com pilhas novas.

const CAPACITY := 90.0

var _battery: FlashlightBattery


func before_test() -> void:
	_battery = FlashlightBattery.new(CAPACITY)


func test_starts_full() -> void:
	assert_bool(_battery.is_full()).is_true()
	assert_bool(_battery.is_empty()).is_false()
	assert_float(_battery.ratio()).is_equal_approx(1.0, 0.001)


func test_drain_lowers_the_charge() -> void:
	assert_bool(_battery.drain(45.0)).is_false()

	assert_float(_battery.ratio()).is_equal_approx(0.5, 0.001)
	assert_bool(_battery.is_full()).is_false()


func test_runs_out_once_and_never_goes_below_zero() -> void:
	assert_bool(_battery.drain(60.0)).is_false()
	assert_bool(_battery.drain(60.0)).is_true()
	assert_bool(_battery.drain(60.0)).is_false()

	assert_bool(_battery.is_empty()).is_true()
	assert_float(_battery.charge_seconds).is_equal(0.0)


func test_new_batteries_fill_the_charge() -> void:
	_battery.drain(CAPACITY)

	_battery.recharge()

	assert_bool(_battery.is_full()).is_true()
	assert_float(_battery.ratio()).is_equal_approx(1.0, 0.001)


func test_zero_capacity_is_always_empty() -> void:
	var empty := FlashlightBattery.new(0.0)

	assert_bool(empty.is_empty()).is_true()
	assert_float(empty.ratio()).is_equal(0.0)
	assert_bool(empty.drain(1.0)).is_false()
