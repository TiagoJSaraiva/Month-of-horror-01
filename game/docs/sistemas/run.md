# Run

## Propósito
Encadear as noites de uma run, avaliar cada pedido no amanhecer, contar as vidas e encerrar a run na terceira falha ou com a morte do jogador.

## Componentes
- `run/run.tscn` / `run.gd`: `Run`, dona do `RunState` (decisão 0013). Cria cada `Night` no `SubViewport`, conduz as transições e mostra o fim de run. Filhos: `Hud`, `LowResView` → `SubViewport`, `TransitionOverlay` e `RunOverScreen`. `current_night()` devolve a noite em andamento.
- `run/run_rules.gd`: `RunRules`, regras puras. Enums `Outcome` (`NONE`, `COMPLETED`, `FREE_PASS`, `FAILED`), `NoteKind` (`INTRO`, `COMPLETED`, `FREE_PASS`, `FIRST_WARNING`, `LAST_WARNING`) e `Pin` (`BLUE`, `YELLOW`, `RED`).
- `run/run_state.gd`: `RunState` (`RefCounted`), estado de uma run: `night_number`, `failures`, `free_pass_used`, `last_outcome` e `died`.
- `run/note_lines.gd` + `run/note_lines.tres`: `NoteLines` (Resource), as falas dos clientes, uma por situação.
- `night/table_note.tscn` / `table_note.gd`: `TableNote` (`Interactable`), bilhete na mesa da cabine, colocado pela `Night` com `show_note(text, pin)`.
  - Alfinete sem sombreamento na cor do resultado, com "!" ou "!!" flutuando por cima (`Label3D` virado para a câmera).
  - E lê ("Read note") e guarda ("Put down note"). O texto aparece no `NotePanel` do HUD, pelo canal `HudEvents`, e fecha sozinho quando a mira sai do bilhete.
  - Texto vazio deixa a mesa sem bilhete, como quando a `Night` roda fora de uma run.
- `ui/run_over/run_over_screen.tscn` / `.gd`: `RunOverScreen` (`CanvasLayer`, camada 2), com o título ("THE DEAL IS OFF" ou "YOU DIED"), a fala final, as noites sobrevividas e o botão "Start a new run".

## Regras
- 3 vidas por run (`RunState.MAX_FAILURES`). Cada pedido não cumprido custa 1 vida, e o jogo segue para a próxima noite. As falhas não precisam ser seguidas; na terceira, a run acaba e a noite não avança.
- Passe livre secreto: na primeira noite em que falta **exatamente 1** peixe, a noite conta como cumprida (`FREE_PASS`) e não custa vida. Só vale uma vez por run.
- Bilhete do início da noite, a partir do resultado da noite anterior:
  - noite 1: abertura, alfinete azul;
  - cumpriu: azul;
  - passe livre: azul, com a fala própria;
  - falhou, com 1 falha somada: amarelo "!";
  - falhou, com 2 falhas somadas: vermelho "!!".
- Se a última noite foi cumprida, o alfinete é azul mesmo com falhas antigas.
- Morte: o jogador sem vida encerra a run na hora, sem avaliar o pedido. A `Night` congela `Actors` e a `Lighting`, para o relógio (o amanhecer não chega mais) e emite `player_died`. Uma trava faz valer só o primeiro fim da noite, amanhecer ou morte.
- Noites sobrevividas (`RunRules.nights_survived`): no acordo quebrado, conta a noite atual; na morte, não. Zero mostra "You didn't survive a single night.".
- Fluxo:
  1. Começo de cada noite: a `Run` cria a `Night` com `night_number` e o bilhete, limpa o HUD (`Hud.reset()`) e mostra "NIGHT N" sobre a tela preta, que some em seguida.
  2. Amanhecer: esconde o HUD, toca `play_dawn()` e espera `dawn_hold_seconds` (3 s).
  3. Avalia o pedido com `state.finish_night(order.missing_total())`.
  4. Se a run acabou, mostra a `RunOverScreen` com "THE DEAL IS OFF" e a fala `run_over`, e emite `run_over`.
  5. Senão, cobre a tela de preto, libera a noite antiga e começa a próxima.
- Na morte: esconde o HUD, marca `state.die()`, cobre a tela de preto e mostra a `RunOverScreen` com "YOU DIED" e a fala `death`.
- Nova run: o botão emite `new_run_requested`, e a `Main` troca a `Run` inteira por uma nova.

## Sinais
- `Night.night_finished(order)` → `Run._on_night_night_finished`.
- `Player.health.died` → `Night._on_player_health_died` → `Night.player_died` → `Run._on_night_player_died`.
- `Run.run_over` → `Main._on_run_run_over`: solta o mouse e impede que o clique o recapture.
- `RunOverScreen.new_run_requested` → `Run.new_run_requested` → `Main._on_run_new_run_requested`.
- Pelo canal `HudEvents`: `note_opened(text)` e `note_closed`, emitidos pelo `TableNote`.

## Testes
- `test/unit/run_rules_test.gd`: avaliação com 0, 1 e 2 peixes faltando, com e sem passe; bilhete e alfinete de cada situação; `NoteLines.text_for`; noites sobrevividas no acordo quebrado e na morte.
- `test/unit/run_state_test.gd`: início, noite cumprida, passe livre único e sem custo, 3 falhas fora de sequência encerram a run, noite não avança no fim, último resultado guardado e morte encerrando a run na noite atual.
- `test/scenes/run_loop_test.gd`: com noite curta e transições curtas, um pedido não entregue vira 1 falha e a noite 2 começa com pedido de 4 peixes e alfinete amarelo.
- `test/scenes/player_death_test.gd`: zerar a vida do jogador encerra a run com a tela "YOU DIED" e emite `run_over` uma vez.
- Conferidos com captura de tela: o bilhete com alfinete amarelo, o painel aberto, o título "NIGHT 1", a tela de fim de run o botão de nova run voltando à noite 1 e a tela de morte.
