extends GdUnitTestSuite
## Comportamento principal da noite: ao amanhecer, a noite termina e o jogador congela.

const NIGHT_SCENE := "res://night/night.tscn"
const SHORT_NIGHT_SECONDS := 0.5
const SIGNAL_TIMEOUT_MS := 3000


func test_dawn_finishes_night_and_freezes_player() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var night := runner.scene() as Night
	var clock := runner.find_child("NightClock") as NightClock
	var player := runner.find_child("Player") as Player
	clock.duration_seconds = SHORT_NIGHT_SECONDS

	await runner.await_signal("night_finished", [night.order], SIGNAL_TIMEOUT_MS)

	# O pedido foi gerado com as espécies configuradas na cena.
	assert_int(night.order.missing_total()).is_equal(OrderRules.fish_count(night.night_number))
	var frozen_at: Vector3 = player.global_position
	runner.simulate_action_press("move_forward")
	await await_millis(500)
	runner.simulate_action_release("move_forward")
	assert_vector(player.global_position).is_equal_approx(frozen_at, Vector3.ONE * 0.01)
