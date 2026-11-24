class_name LightStun
extends ShapeCast3D
## Parte do facho da lanterna que atordoa: enquanto ligado (enabled), avisa os LightSensor que
## alcança até stun_range metros, se nenhuma parede estiver no caminho. A lanterna liga e
## desliga junto com a luz.

@export var stun_range: float = 8.0


func _ready() -> void:
	target_position = Vector3(0.0, 0.0, -stun_range)


func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	force_shapecast_update()
	for i: int in get_collision_count():
		var sensor := get_collider(i) as LightSensor
		if sensor != null and _can_see(sensor.global_position):
			sensor.expose_to_light()


func _can_see(point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position, point, PhysicsLayers.WORLD)
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
