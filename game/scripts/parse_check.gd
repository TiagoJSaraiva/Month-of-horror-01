extends SceneTree
## Etapa de parse do check (docs/decisoes/*-parse-unico-com-autoloads.md). Compila cada script
## recebido depois de "--", já com os autoloads registrados, e sai com 1 se algum não compilar.
## Fica em scripts/ (ignorado pelo Godot) porque não faz parte do jogo.


## Compila os scripts recebidos na linha de comando, lista os que falharem e sai com o código do
## resultado.
func _initialize() -> void:
	var paths: PackedStringArray = OS.get_cmdline_user_args()
	var failed: PackedStringArray = []
	for path: String in paths:
		# Ignora o cache: cada script é compilado de novo, mesmo que já tenha sido carregado.
		var script: Script = (
			ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Script
		)
		if script == null or not script.can_instantiate():
			failed.append(path)
	for path: String in failed:
		printerr("Não compilou: %s" % path)
	print("Scripts compilados: %d de %d" % [paths.size() - failed.size(), paths.size()])
	quit(1 if not failed.is_empty() else 0)
