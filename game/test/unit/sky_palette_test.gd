extends GdUnitTestSuite
## Mistura de paletas do céu: nas pontas dá cada paleta, no meio a média, inclusive a neblina.

var _dark: SkyPalette
var _bright: SkyPalette


func before_test() -> void:
	_dark = SkyPalette.new()
	_dark.sky_top = Color.BLACK
	_dark.ambient_energy = 0.0
	_dark.fog_density = 0.0
	_bright = SkyPalette.new()
	_bright.sky_top = Color.WHITE
	_bright.ambient_energy = 1.0
	_bright.fog_density = 0.1


func test_weight_zero_and_one_give_each_palette() -> void:
	assert_object(SkyPalette.mix(_dark, _bright, 0.0).sky_top).is_equal(Color.BLACK)
	assert_object(SkyPalette.mix(_dark, _bright, 1.0).sky_top).is_equal(Color.WHITE)


func test_half_weight_is_the_average() -> void:
	var middle: SkyPalette = SkyPalette.mix(_dark, _bright, 0.5)

	assert_float(middle.sky_top.r).is_equal_approx(0.5, 0.001)
	assert_float(middle.ambient_energy).is_equal_approx(0.5, 0.001)
	assert_float(middle.fog_density).is_equal_approx(0.05, 0.001)
