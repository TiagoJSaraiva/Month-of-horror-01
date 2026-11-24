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

@warning_ignore_restore("unused_signal")
