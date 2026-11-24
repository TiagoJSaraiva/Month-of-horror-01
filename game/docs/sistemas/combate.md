# Combate

## Propósito
Dar ao jogador vida e meios de se defender dos inimigos. A morte encerra a run.

## Componentes
- `components/health_state.gd`: `HealthState` (`RefCounted`), regras puras de dano, morte e regeneração.
- `components/health.gd`: `Health`, componente de vida usado pelo jogador e pelos inimigos. Emite `changed(current, maximum)`, `damaged(amount)` e `died`. Com `hud_events` definido (só no jogador), anuncia a vida (`health_changed`) e o dano (`player_damaged`) no HUD.
- `player/player.tscn`: o filho `Health` do `Player` tem 100 de vida, regenera 5 por segundo e espera 5 s. É público em `Player.health`.
- `ui/hud/damage_flash.gd`: `DamageFlash`, clarão vermelho na tela inteira a cada dano. A barra `Health` do HUD mostra a vida.

## Regras
- Vida do jogador: 100. Depois de 5 s sem levar dano, regenera 5 por segundo até o máximo. Cada dano reinicia a espera.
- A regeneração conta só o trecho do passo de tempo que já passou da espera, para não depender da taxa de quadros.
- A vida não passa de zero, a morte acontece uma vez só e o dano depois dela é ignorado. Inimigos não regeneram (taxa 0).
- A morte do jogador encerra a run na hora (ver `docs/sistemas/run.md`).

## Testes
- `test/unit/health_state_test.gd`: começa cheia, dano até zero, morte única, dano inválido ignorado, espera da regeneração, limite no máximo, dano novo reinicia a espera, taxa zero e morto não regeneram.
