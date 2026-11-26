extends GdUnitTestSuite
## Comportamento principal do movimento: segurar move_forward faz o jogador andar para frente.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")
const FLOOR_SIZE: Vector3 = Vector3(50.0, 1.0, 50.0)
const WORLD_LAYER: int = 1


func test_walks_forward_while_holding_move_forward() -> void:
	var runner: GdUnitSceneRunner = scene_runner(auto_free(_create_world()))
	var player: Player = runner.find_child("Player") as Player
	# Deixa o jogador assentar no chão antes de medir.
	await await_millis(200)
	var start: Vector3 = player.global_position

	runner.simulate_action_press("move_forward")
	await await_millis(1000)
	runner.simulate_action_release("move_forward")

	var moved: Vector3 = player.global_position - start
	# A 3,5 m/s, cerca de 3 m em 1 s; a faixa absorve a imprecisão do tempo real.
	assert_float(-moved.z).is_between(2.0, 4.5)
	assert_float(absf(moved.x)).is_less(0.1)
	assert_float(player.global_position.y).is_between(-0.05, 0.1)


func _create_world() -> Node3D:
	var world: Node3D = Node3D.new()
	var floor_body: StaticBody3D = StaticBody3D.new()
	floor_body.collision_layer = WORLD_LAYER
	var floor_shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = FLOOR_SIZE
	floor_shape.shape = box
	floor_shape.position = Vector3(0.0, -FLOOR_SIZE.y / 2.0, 0.0)
	floor_body.add_child(floor_shape)
	world.add_child(floor_body)
	var player: Player = PLAYER_SCENE.instantiate() as Player
	world.add_child(player)
	return world
