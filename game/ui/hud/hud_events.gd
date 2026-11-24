class_name HudEvents
extends Resource
## Canal entre o mundo 3D (dentro do SubViewport) e o HUD em resolução nativa (decisão 0012).
## Quem emite e o HUD recebem o mesmo .tres por @export. Só passa apresentação por aqui:
## nenhuma regra de jogo depende destes sinais.

# Os sinais são emitidos pelos componentes do mundo, nunca por esta classe.
@warning_ignore_start("unused_signal")

## Ação disponível no que está na mira; texto vazio esconde.
signal prompt_changed(text: String)
## Mensagem curta embaixo da tela. Com [param seconds] 0, fica até a próxima mensagem.
signal hint_requested(text: String, seconds: float)
signal bait_changed(bait_name: String)
## O HUD desenha o minijogo lendo o modelo até receber minigame_finished.
signal minigame_started(minigame: FishingMinigame)
signal minigame_finished
## Texto do bilhete da mesa, mostrado até note_closed.
signal note_opened(text: String)
signal note_closed
## Progresso, de 0 a 1, da ação que exige segurar E. 0 esconde a barra.
signal hold_progress_changed(ratio: float)
## Carga da bateria da lanterna, de 0 a 1.
signal battery_changed(ratio: float)
## Vida do jogador.
signal health_changed(current: float, maximum: float)
## O jogador levou dano: o HUD pisca em vermelho.
signal player_damaged

@warning_ignore_restore("unused_signal")
