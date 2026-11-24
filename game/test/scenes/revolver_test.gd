extends GdUnitTestSuite
## Comportamento principal do revólver: com ele na mão, cada clique acerta o alvo na mira, e
## três tiros matam um alvo de 75 de vida.

const NIGHT_SCENE := "res://night/night.tscn"
const PLAYER_ON_DECK := Vector3(0.0, 1.0, 1.0)
const TARGET_POSITION := Vector3(0.0, 2.2, 4.0)
const TARGET_HEALTH := 75.0
const SHOTS_TO_KILL := 3
## Um pouco mais que a cadência do revólver (0,35 s).
const MILLIS_BETWEEN_SHOTS := 450


func test_three_shots_kill_a_target_in_the_aim() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var night := runner.scene() as Night
	var player := runner.find_child("Player") as Player
	var camera := runner.find_child("Camera3D") as Camera3D
	var revolver := runner.find_child("Revolver") as Revolver
	var target_health := _add_target(night)
	player.global_position = PLAYER_ON_DECK
	player.hands.state.select_tool(HandsState.Tool.REVOLVER)
	await await_millis(100)
	camera.look_at(TARGET_POSITION)
	# Dá tempo de o alvo entrar no espaço de física.
	await await_millis(200)

	for shot: int in SHOTS_TO_KILL:
		runner.simulate_action_pressed("primary_action")
		await await_millis(MILLIS_BETWEEN_SHOTS)

	assert_bool(target_health.is_dead()).is_true()
	assert_int(revolver.state.loaded).is_equal(revolver.capacity - SHOTS_TO_KILL)


# Alvo de teste: uma Hurtbox de 1×2×1 m ligada a um Health, na frente do jogador.
func _add_target(night: Night) -> Health:
	var health := Health.new()
	health.max_health = TARGET_HEALTH
	var hurtbox := Hurtbox.new()
	hurtbox.health = health
	hurtbox.collision_layer = PhysicsLayers.HURTBOX
	hurtbox.collision_mask = 0
	hurtbox.monitoring = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 2.0, 1.0)
	shape.shape = box
	hurtbox.add_child(shape)
	hurtbox.add_child(health)
	night.add_child(hurtbox)
	hurtbox.global_position = TARGET_POSITION
	return health
