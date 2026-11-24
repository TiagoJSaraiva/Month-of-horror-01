extends GdUnitTestSuite
## Comportamento principal do peixe-homem: sobe pela amurada, atravessa o convés e a porta e
## tira vida do jogador dentro da cabine.

const NIGHT_SCENE := "res://night/night.tscn"
const INSIDE_CABIN := Vector3(0.0, 1.0, -4.5)
const POLL_MILLIS := 100
const TIMEOUT_MILLIS := 10000


func test_fishman_reaches_the_player_in_the_cabin_and_hurts_him() -> void:
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

	spawner.spawn(spawner.climb_points()[0])
	waited = 0
	while player.health.state.current >= player.health.max_health and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS

	assert_float(player.health.state.current).is_less(player.health.max_health)
