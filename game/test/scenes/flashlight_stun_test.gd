extends GdUnitTestSuite
## Comportamento principal do atordoamento: com a lanterna acesa apontada para o rosto, o
## peixe-homem que vem pelo convés fica atordoado.

const NIGHT_SCENE := "res://night/night.tscn"
## No convés, na mesma linha do primeiro ponto de subida (PortFore, em x = -2 e z = 1,5).
const PLAYER_ON_DECK := Vector3(1.0, 1.0, 1.5)
const FACE_HEIGHT := 1.65
const POLL_MILLIS := 50
const TIMEOUT_MILLIS := 5000


func test_light_in_the_face_stuns_the_fishman() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var player := runner.find_child("Player") as Player
	var camera := runner.find_child("Camera3D") as Camera3D
	var spawner := runner.find_child("FishmanSpawner") as FishmanSpawner
	var failures := runner.find_child("MaintenanceFailures") as MaintenanceFailures
	failures.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = PLAYER_ON_DECK
	var point: Marker3D = spawner.climb_points()[0]
	var fishman: Fishman = spawner.spawn(point)
	var waited := 0
	while fishman.brain.state == FishmanBrain.State.CLIMBING and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS
	camera.look_at(fishman.global_position + Vector3.UP * FACE_HEIGHT)

	runner.simulate_action_pressed("toggle_flashlight")
	await await_millis(150)

	assert_int(fishman.brain.state).is_equal(FishmanBrain.State.STUNNED)
