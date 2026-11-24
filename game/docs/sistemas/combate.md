# Combate

## Propósito
Dar ao jogador vida e meios de se defender dos inimigos. A morte encerra a run.

## Componentes
- `components/health_state.gd`: `HealthState` (`RefCounted`), regras puras de dano, morte e regeneração.
- `components/health.gd`: `Health`, componente de vida usado pelo jogador e pelos inimigos. Emite `changed(current, maximum)`, `damaged(amount)` e `died`. Com `hud_events` definido (só no jogador), anuncia a vida (`health_changed`) e o dano (`player_damaged`) no HUD.
- `player/player.tscn`: o filho `Health` do `Player` tem 100 de vida, regenera 5 por segundo e espera 5 s. É público em `Player.health`.
- `ui/hud/damage_flash.gd`: `DamageFlash`, clarão vermelho na tela inteira a cada dano. A barra `Health` do HUD mostra a vida.
- `components/hurtbox.gd`: `Hurtbox` (`Area3D` na camada `hurtbox`), onde os tiros acertam. Repassa o dano ao `Health` ligado por `@export` e emite `hit(amount)`. O jogador não tem `Hurtbox`: os inimigos causam dano direto no `Health` dele.
- `weapons/revolver_state.gd`: `RevolverState` (`RefCounted`), regras de munição, cadência e recarga.
- `weapons/revolver.tscn` / `revolver.gd`: `Revolver`, filho da `Camera3D` do jogador. `Aim` é um RayCast de 40 m no centro da tela, nas camadas `world` e `hurtbox` e com áreas ligadas. `Model` greybox à direita, com `MuzzleFlash` (luz breve no disparo) e recuo. A munição vai para o HUD (`ammo_changed`).

## Regras
- Vida do jogador: 100. Depois de 5 s sem levar dano, regenera 5 por segundo até o máximo. Cada dano reinicia a espera.
- A regeneração conta só o trecho do passo de tempo que já passou da espera, para não depender da taxa de quadros.
- A vida não passa de zero, a morte acontece uma vez só e o dano depois dela é ignorado. Inimigos não regeneram (taxa 0).
- A morte do jogador encerra a run na hora (ver `docs/sistemas/run.md`).
- Revólver (só com ele na mão: tecla 2, ver `docs/sistemas/maos.md`):
  - 6 balas no tambor, 25 de dano por tiro, no mínimo 0,35 s entre tiros, um tiro por clique;
  - tiro instantâneo pela mira do centro da tela: acerta a primeira `Hurtbox` antes de uma parede;
  - R recarrega em 2 s e sempre enche o tambor (reserva infinita). Atirar sem bala começa a recarga. Não atira recarregando;
  - guardar o revólver interrompe a recarga, e as balas do tambor ficam;
  - o HUD mostra "Ammo: N/6" ou "Reloading...".

## Testes
- `test/unit/health_state_test.gd`: começa cheia, dano até zero, morte única, dano inválido ignorado, espera da regeneração, limite no máximo, dano novo reinicia a espera, taxa zero e morto não regeneram.
- `test/unit/revolver_state_test.gd`: começa cheio, tiro gasta bala, cadência, tambor vazio não atira, recarga leva o tempo e enche, cheio não recarrega, não atira recarregando, cancelar a recarga mantém as balas.
- `test/scenes/revolver_test.gd`: com o revólver na mão, três cliques matam um alvo de teste de 75 de vida na mira.
- Conferidos com captura de tela: barra de vida depois de dano, revólver na mão com a munição no HUD e a tela de morte.
