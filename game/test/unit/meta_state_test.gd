extends GdUnitTestSuite
## Estado salvo entre as runs: pontos, compra de níveis, percentual por atributo e save que
## sobrevive a recarregar e começa do zero quando o arquivo falta ou está estragado.

const SAVE_PATH := "user://test_meta_state.cfg"

var _health: UpgradeData
var _meta: MetaState


func before_test() -> void:
	_health = UpgradeData.new()
	_health.id = &"health"
	_health.stat = StatModifier.Stat.MAX_HEALTH
	_meta = MetaState.new()


func after_test() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func test_buying_spends_points_and_raises_the_level() -> void:
	_meta.add_points(70)

	assert_bool(_meta.buy(_health)).is_true()
	assert_bool(_meta.buy(_health)).is_true()

	assert_int(_meta.level(_health)).is_equal(2)
	assert_int(_meta.points).is_equal(10)
	assert_bool(_meta.buy(_health)).is_false()


func test_levels_add_percent_to_the_stat() -> void:
	_meta.add_points(200)
	for i: int in 3:
		_meta.buy(_health)

	var percents: Dictionary = _meta.percents([_health])

	assert_float(percents[StatModifier.Stat.MAX_HEALTH]).is_equal_approx(30.0, 0.001)


func test_level_stops_at_the_maximum() -> void:
	_meta.add_points(10000)
	for i: int in 10:
		_meta.buy(_health)

	assert_int(_meta.level(_health)).is_equal(_health.max_level)


func test_save_and_load_keep_points_and_levels() -> void:
	_meta.add_points(65)
	_meta.buy(_health)

	assert_int(_meta.save(SAVE_PATH)).is_equal(OK)
	var loaded: MetaState = MetaState.load_from(SAVE_PATH)

	assert_int(loaded.points).is_equal(45)
	assert_int(loaded.level(_health)).is_equal(1)


func test_missing_file_starts_from_zero() -> void:
	var loaded: MetaState = MetaState.load_from("user://does_not_exist.cfg")

	assert_int(loaded.points).is_equal(0)
	assert_int(loaded.level(_health)).is_equal(0)


func test_broken_file_starts_from_zero() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("this is [not a config ===")
	file.close()

	var loaded: MetaState = MetaState.load_from(SAVE_PATH)

	assert_int(loaded.points).is_equal(0)
