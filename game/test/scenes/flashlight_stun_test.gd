extends GdUnitTestSuite
## Comportamento principal do atordoamento: com a lanterna acesa apontada para o rosto, o
## peixe-homem que vem pelo convés fica atordoado.

const NIGHT_SCENE: String = "res://night/night.tscn"
## No convés, na mesma linha do primeiro ponto de subida (PortFore, em x = -2 e z = 1,5).
const PLAYER_ON_DECK: Vector3 = Vector3(1.0, 1.0, 1.5)
const FACE_HEIGHT: float = 1.65
const POLL_MILLIS: int = 50
const TIMEOUT_MILLIS: int = 5000


func test_light_in_the_face_stuns_the_fishman() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var player: Player = runner.find_child("Player") as Player
	var camera: Camera3D = runner.find_child("Camera3D") as Camera3D
	var spawner: FishmanSpawner = runner.find_child("FishmanSpawner") as FishmanSpawner
	var failures: MaintenanceFailures = (
		runner.find_child("MaintenanceFailures") as MaintenanceFailures
	)
	failures.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = PLAYER_ON_DECK
	var point: Marker3D = spawner.climb_points()[0]
	var fishman: Fishman = spawner.spawn(point)
	var waited: int = 0
	while fishman.brain.state == FishmanBrain.State.CLIMBING and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS
	camera.look_at(fishman.global_position + Vector3.UP * FACE_HEIGHT)

	runner.simulate_action_pressed("toggle_flashlight")
	await await_millis(150)

	assert_int(fishman.brain.state).is_equal(FishmanBrain.State.STUNNED)
