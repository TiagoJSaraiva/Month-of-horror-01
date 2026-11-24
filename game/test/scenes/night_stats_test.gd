extends GdUnitTestSuite
## Comportamento principal dos bônus: uma noite criada com cartas equipadas aplica os efeitos
## ao jogador e ao barco (vida, tambor, tempo de manutenção).

const NIGHT_SCENE := "res://night/night.tscn"
const TOUGH_SKIN: CardData = preload("res://cards/data/tough_skin.tres")
const EXTENDED_CYLINDER: CardData = preload("res://cards/data/extended_cylinder.tres")
const QUICK_FIX: CardData = preload("res://cards/data/quick_fix.tres")


func test_equipped_cards_change_the_player_and_the_boat() -> void:
	# Criada à mão para receber os bônus antes do _ready; auto_free a libera no fim do teste.
	var night := auto_free((load(NIGHT_SCENE) as PackedScene).instantiate()) as Night
	night.player_stats = PlayerStats.from_cards([TOUGH_SKIN, EXTENDED_CYLINDER, QUICK_FIX])
	var runner: GdUnitSceneRunner = scene_runner(night)
	var player := runner.find_child("Player") as Player
	var revolver := runner.find_child("Revolver") as Revolver
	var generator := runner.find_child("Generator") as Generator
	var bulb := runner.find_child("CabinBulb") as Bulb
	await await_millis(50)

	assert_float(player.health.max_health).is_equal_approx(120.0, 0.001)
	assert_float(player.health.state.current).is_equal_approx(120.0, 0.001)
	assert_int(revolver.state.capacity).is_equal(9)
	assert_int(revolver.state.loaded).is_equal(9)
	# Mãos livres: o gerador oferece o conserto, de 4 s pela metade.
	assert_float(generator.get_hold_seconds(player.hands)).is_equal_approx(2.0, 0.001)
	assert_float(bulb.get_hold_seconds(player.hands)).is_equal_approx(1.0, 0.001)
