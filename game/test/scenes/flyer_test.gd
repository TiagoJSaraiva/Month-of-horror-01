extends GdUnitTestSuite
## Comportamento principal do voador: chega ao barco, circula, avisa e mergulha no jogador à
## vista no convés aberto, tirando vida.

const NIGHT_SCENE := "res://night/night.tscn"
const PLAYER_ON_DECK := Vector3(0.0, 1.0, 3.0)
const POLL_MILLIS := 100
const TIMEOUT_MILLIS := 10000


func test_flyer_dives_at_the_player_in_the_open() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var player := runner.find_child("Player") as Player
	var spawner := runner.find_child("FlyerSpawner") as FlyerSpawner
	var failures := runner.find_child("MaintenanceFailures") as MaintenanceFailures
	failures.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = PLAYER_ON_DECK
	# Chega perto e rápido, circula pouco e sempre escolhe o jogador.
	spawner.spawn_distance = 9.0
	var flyer: Flyer = spawner.spawn()
	flyer.cruise_speed = 10.0
	flyer.circle_seconds_min = 0.2
	flyer.circle_seconds_max = 0.3
	flyer.player_chance = 1.0

	var waited := 0
	while player.health.state.current >= player.health.max_health and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS

	assert_float(player.health.state.current).is_less(player.health.max_health)
