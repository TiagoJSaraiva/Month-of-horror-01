extends GdUnitTestSuite
## Comportamento principal da navegação: depois de montada a malha, existe caminho do convés
## aberto até dentro da cabine, passando pela porta.

const NIGHT_SCENE: String = "res://night/night.tscn"
const ON_DECK: Vector3 = Vector3(0.0, 1.0, 3.0)
const INSIDE_CABIN: Vector3 = Vector3(0.0, 1.0, -4.5)
## Plano da porta da cabine (parede de trás, em z = -2.275) e meia largura do vão.
const DOOR_Z: float = -2.275
const DOOR_HALF_WIDTH: float = 0.5
const ARRIVAL_TOLERANCE: float = 0.5
const POLL_MILLIS: int = 50
const TIMEOUT_MILLIS: int = 3000


func test_path_goes_from_the_deck_into_the_cabin() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var navigation: BoatNavigation = runner.find_child("Navigation") as BoatNavigation
	var waited: int = 0
	while navigation.navigation_mesh.get_polygon_count() == 0 and waited < TIMEOUT_MILLIS:
		await await_millis(POLL_MILLIS)
		waited += POLL_MILLIS
	# O mapa de navegação só incorpora a malha nova no frame de física seguinte.
	await await_millis(100)

	var map: RID = navigation.get_navigation_map()
	var path: PackedVector3Array = NavigationServer3D.map_get_path(map, ON_DECK, INSIDE_CABIN, true)

	assert_int(path.size()).is_greater(1)
	var arrival: Vector3 = path[path.size() - 1]
	(
		assert_float(
			Vector2(arrival.x, arrival.z).distance_to(Vector2(INSIDE_CABIN.x, INSIDE_CABIN.z))
		)
		. is_less(ARRIVAL_TOLERANCE)
	)
	assert_bool(_crosses_the_door(path)).is_true()


func _crosses_the_door(path: PackedVector3Array) -> bool:
	for i: int in range(1, path.size()):
		var from: Vector3 = path[i - 1]
		var to: Vector3 = path[i]
		if (from.z - DOOR_Z) * (to.z - DOOR_Z) > 0.0:
			continue
		var t: float = (
			inverse_lerp(from.z, to.z, DOOR_Z) if not is_equal_approx(from.z, to.z) else 0.0
		)
		var x_at_door: float = lerpf(from.x, to.x, t)
		if absf(x_at_door) <= DOOR_HALF_WIDTH:
			return true
	return false
