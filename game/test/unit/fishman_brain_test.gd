extends GdUnitTestSuite
## Peixe-homem: sobe, persegue, prepara o golpe, acerta só se o alvo continua perto, fica
## atordoado com imunidade depois, foge quando a luz volta e morto ignora tudo.

const FAR: float = 10.0
const NEAR: float = 1.0

var _brain: FishmanBrain
## Golpes que acertaram. Array para a lambda alterar por referência.
var _hits: Array[int] = [0]


func before_test() -> void:
	_brain = FishmanBrain.new()
	_hits = [0]
	_brain.attack_landed.connect(func() -> void: _hits[0] += 1)


func test_starts_climbing_and_then_chases() -> void:
	assert_int(_brain.state).is_equal(FishmanBrain.State.CLIMBING)

	_brain.update(_brain.climb_seconds, FAR)

	assert_int(_brain.state).is_equal(FishmanBrain.State.CHASING)
	assert_bool(_brain.is_moving()).is_true()


func test_close_target_starts_the_windup() -> void:
	_climb()

	_brain.update(0.1, NEAR)

	assert_int(_brain.state).is_equal(FishmanBrain.State.WINDING_UP)
	assert_bool(_brain.is_moving()).is_false()


func test_attack_lands_when_the_target_stays_close() -> void:
	_climb()
	_brain.update(0.1, NEAR)

	_brain.update(_brain.windup_seconds, NEAR)

	assert_int(_hits[0]).is_equal(1)
	assert_int(_brain.state).is_equal(FishmanBrain.State.RECOVERING)


func test_attack_misses_when_the_target_moved_away() -> void:
	_climb()
	_brain.update(0.1, NEAR)

	_brain.update(_brain.windup_seconds, FAR)

	assert_int(_hits[0]).is_equal(0)
	assert_int(_brain.state).is_equal(FishmanBrain.State.RECOVERING)


func test_recovers_and_chases_again() -> void:
	_climb()
	_brain.update(0.1, NEAR)
	_brain.update(_brain.windup_seconds, NEAR)

	_brain.update(_brain.recover_seconds, FAR)

	assert_int(_brain.state).is_equal(FishmanBrain.State.CHASING)


func test_stun_interrupts_the_windup() -> void:
	_climb()
	_brain.update(0.1, NEAR)

	assert_bool(_brain.stun()).is_true()
	_brain.update(_brain.windup_seconds, NEAR)

	assert_int(_hits[0]).is_equal(0)
	assert_int(_brain.state).is_equal(FishmanBrain.State.STUNNED)


func test_stun_lasts_its_duration() -> void:
	_climb()
	_brain.stun()

	_brain.update(_brain.stun_seconds - 0.1, FAR)
	assert_int(_brain.state).is_equal(FishmanBrain.State.STUNNED)

	_brain.update(0.2, FAR)
	assert_int(_brain.state).is_equal(FishmanBrain.State.CHASING)


func test_immunity_blocks_a_new_stun_until_it_ends() -> void:
	_climb()
	_brain.stun()
	_brain.update(_brain.stun_seconds, FAR)

	assert_bool(_brain.stun()).is_false()
	_brain.update(_brain.stun_immunity_seconds, FAR)
	assert_bool(_brain.stun()).is_true()


func test_cannot_be_stunned_while_climbing_or_fleeing() -> void:
	assert_bool(_brain.stun()).is_false()

	_brain.flee()

	assert_bool(_brain.stun()).is_false()


func test_light_coming_back_makes_it_flee() -> void:
	_climb()

	_brain.flee()
	_brain.update(1.0, NEAR)

	assert_int(_brain.state).is_equal(FishmanBrain.State.FLEEING)
	assert_bool(_brain.is_moving()).is_true()
	assert_int(_hits[0]).is_equal(0)


func test_dead_ignores_everything() -> void:
	_climb()

	_brain.kill()
	_brain.update(5.0, NEAR)
	_brain.flee()

	assert_int(_brain.state).is_equal(FishmanBrain.State.DEAD)
	assert_bool(_brain.stun()).is_false()
	assert_int(_hits[0]).is_equal(0)


func _climb() -> void:
	_brain.update(_brain.climb_seconds, FAR)
