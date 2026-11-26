class_name Bobber
extends Node3D
## Boia da linha. Acompanha a altura da água, que sobe e desce com o balanço, e afunda
## enquanto o peixe morde.

## Quanto a boia afunda na mordida, em metros.
@export var bite_depth: float = 0.12
## Até quantos metros acima e abaixo da boia procurar a superfície da água.
@export var probe_range: float = 3.0

var _biting: bool = false


## Acompanha a superfície da água sob a boia, afundada em bite_depth durante a mordida; sem água na
## faixa probe_range, mantém a altura.
func _physics_process(_delta: float) -> void:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * probe_range,
		global_position + Vector3.DOWN * probe_range,
		PhysicsLayers.WATER
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var surface: Vector3 = hit["position"]
	global_position.y = surface.y - (bite_depth if _biting else 0.0)


## Joga a boia no ponto e a mostra, sem mordida.
func drop_at(point: Vector3) -> void:
	global_position = point
	_biting = false
	show()


## Liga ou desliga o afundamento da mordida.
func set_biting(biting: bool) -> void:
	_biting = biting


## Recolhe a boia: encerra a mordida e a esconde.
func pull_out() -> void:
	_biting = false
	hide()
