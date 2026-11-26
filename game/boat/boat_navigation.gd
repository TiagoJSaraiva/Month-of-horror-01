class_name BoatNavigation
extends NavigationRegion3D
## Malha de navegação do barco, montada ao carregar a partir dos corpos estáticos do grupo
## boat_navigation (casco, cabine, freezer, caixas e gerador). Os inimigos andam por ela até o
## jogador, inclusive dentro da cabine (decisão 0014).

signal baked


## Um frame depois de entrar na árvore, monta a malha a partir dos corpos do barco e emite baked
## quando terminar.
func _ready() -> void:
	bake_finished.connect(baked.emit)
	# As formas CSG montam a colisão numa chamada adiada depois de entrar na árvore: espera um
	# frame antes de ler a geometria.
	await get_tree().process_frame
	bake_navigation_mesh(false)
