extends GdUnitTestSuite
## Comportamento principal da entrega: com um peixe nas mãos, mirar o freezer e apertar E
## entrega o peixe ao pedido e esvazia as mãos.

const NIGHT_SCENE := "res://night/night.tscn"
const MACKEREL: FishData = preload("res://fish/data/mackerel.tres")
## Um passo à frente do freezer, dentro da cabine.
const IN_FRONT_OF_FREEZER := Vector3(-0.1, 1.0, -4.8)


func test_storing_the_carried_fish_delivers_it() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var night := runner.scene() as Night
	var player := runner.find_child("Player") as Player
	var camera := runner.find_child("Camera3D") as Camera3D
	var freezer := runner.find_child("Freezer") as Freezer
	player.global_position = IN_FRONT_OF_FREEZER
	await await_millis(100)
	camera.look_at(freezer.global_position)
	player.hands.carry_item(MACKEREL)
	# Dá tempo de a mira de interação achar o freezer.
	await await_millis(200)

	runner.simulate_action_pressed("interact")
	await runner.await_input_processed()

	assert_int(night.order.delivered_count(MACKEREL)).is_equal(1)
	assert_bool(player.hands.state.is_carrying()).is_false()
