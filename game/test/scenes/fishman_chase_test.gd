extends GdUnitTestSuite
## Comportamento principal do peixe-homem: sai da água do lado de fora do casco, sobe pela
## amurada, atravessa o convés e a porta e tira vida do jogador dentro da cabine.

const NIGHT_SCENE := "res://night/night.tscn"
const INSIDE_CABIN := Vector3(0.0, 1.0, -4.5)
## Metade da largura do casco: quem sobe pela amurada começa além dela, na água.
const HULL_HALF_WIDTH := 2.5
const DECK_HEIGHT := 1.0
const POLL_MILLIS := 100
const TIMEOUT_MILLIS := 10000


func test_fishman_climbs_from_the_sea_and_hurts_the_player_in_the_cabin() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var player := runner.find_child("Player") as Player
	var navigation := runner.find_child("Navigation") as BoatNavigation
	var spawner := runner.find_child("FishmanSpawner") as FishmanSpawner
	# Sem falhas de manutenção, a luz não cai e nenhum outro peixe-homem sobe.
	var failures := runner.find_child("MaintenanceFailures") as MaintenanceFailures
	failures.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = INSIDE_CABIN
	var waited := 0
	while navigation.navigation_mesh.get_polygon_count() == 0 and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS

	var fishman: Fishman = spawner.spawn(spawner.climb_points()[0])

	assert_float(absf(fishman.global_position.x)).is_greater(HULL_HALF_WIDTH)
	assert_float(fishman.global_position.y).is_less(DECK_HEIGHT)
	waited = 0
	while player.health.state.current >= player.health.max_health and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS
	assert_float(player.health.state.current).is_less(player.health.max_health)
