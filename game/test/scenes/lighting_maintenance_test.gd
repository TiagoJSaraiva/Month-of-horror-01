extends GdUnitTestSuite
## Comportamento principal da iluminação: sem combustível, o barco fica só com a luz de
## emergência; segurando E no gerador com o galão nas mãos, a luz volta.

const NIGHT_SCENE: String = "res://night/night.tscn"
const FUEL_CAN: ItemData = preload("res://items/data/fuel_can.tres")
## Um passo à frente do gerador, na popa.
const IN_FRONT_OF_GENERATOR: Vector3 = Vector3(0.0, 1.0, 5.0)
const SHORT_REFUEL_SECONDS: float = 0.2


func test_refueling_the_empty_generator_brings_the_light_back() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var player: Player = runner.find_child("Player") as Player
	var camera: Camera3D = runner.find_child("Camera3D") as Camera3D
	var lighting: BoatLighting = runner.find_child("Lighting") as BoatLighting
	var generator: Generator = runner.find_child("Generator") as Generator
	var emergency_lights: Node3D = runner.find_child("EmergencyLights") as Node3D
	# Sem sorteio de falhas, para nada quebrar no meio do teste.
	var failures: MaintenanceFailures = (
		runner.find_child("MaintenanceFailures") as MaintenanceFailures
	)
	failures.process_mode = Node.PROCESS_MODE_DISABLED
	generator.refuel_seconds = SHORT_REFUEL_SECONDS

	generator.state.consume(generator.state.capacity_seconds)

	assert_float(lighting.light_level).is_equal(0.0)
	assert_bool(emergency_lights.visible).is_true()

	player.global_position = IN_FRONT_OF_GENERATOR
	await await_millis(100)
	camera.look_at(generator.global_position + Vector3.UP * 0.4)
	player.hands.carry_item(FUEL_CAN)
	# Dá tempo de a mira de interação achar o gerador.
	await await_millis(200)

	runner.simulate_action_press("interact")
	await await_millis(int(SHORT_REFUEL_SECONDS * 1000.0) + 300)
	runner.simulate_action_release("interact")
	await runner.await_input_processed()

	assert_float(lighting.light_level).is_equal_approx(1.0, 0.001)
	assert_bool(emergency_lights.visible).is_false()
	assert_bool(player.hands.state.is_carrying()).is_false()
