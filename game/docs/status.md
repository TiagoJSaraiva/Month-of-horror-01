# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 a M6: fundação, noite e pedido, pesca, loop da run, iluminação, combate e tempestade.
- Jogável hoje, tudo em greybox:
  - run de noites encadeadas, com bilhete na mesa e alfinete por resultado;
  - pedido crescente, pesca com isca e minijogo, entrega no freezer;
  - 3 vidas, passe livre secreto, tela de fim de run e nova run;
  - gerador, 6 lâmpadas, luz de emergência e manutenção segurando E;
  - lanterna no F, que atordoa, com a bateria recarregada na caixa de pilhas da mesa;
  - vida com regeneração e morte encerrando a run;
  - revólver no 2 (vara no 1);
  - peixe-homem que sobe no escuro, persegue pelo barco todo, foge quando a luz volta e morre com 3 tiros;
  - tempestade a partir da noite 2: balanço forte, chuva, relâmpagos, céu fechado, mais falhas e voadores que mergulham no jogador e nas lâmpadas.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação, combate, inimigos, tempestade).

## Próximo passo
- M7 Cartas e dificuldade, com `/planejar`:
  - seleção de 3 cartas no início da run e entre as noites, com raridades, rerolls e slots;
  - a curva de dificuldade por noite (pedido, inimigos, falhas, bateria, chance e duração da tempestade).
- Regras em `docs/escopo-mvp.md` (seções Cartas e Dificuldade). Os ajustes que a curva vai mexer já estão em `@export` ou Resource (`StormSettings`, `MaintenanceFailures`, spawners, `Flashlight.battery_seconds`).

## Para validar jogando
- Input real através do `SubViewport`: mouse, E (inclusive segurado), Q, G, Tab, F, 1, 2 e R. As capturas de tela acionaram as ações pelo código.
- Tempestade:
  - para forçar: `first_night` = 1 e `chance` = 1 em `night/storm_settings.tres`; para começar cedo, também `start_window_min` e `start_window_max` = 0;
  - conferir o balanço 3×, a chuva na baixa resolução e o voador (visibilidade no escuro, tempo de aviso de 0,6 s, acertá-lo a tiro).
- Combate: ritmo do peixe-homem, atordoamento com o rosto no centro do facho, fuga com a luz de volta, peixe-homem prendendo o jogador na porta.
- Iluminação: escuridão da emergência, alcance das lâmpadas dos postes, desempenho com as luzes com sombra e carga de manutenção na noite 1.
- Refinamento de valores fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- O peixe-homem não reage ao levar tiro, e o voador escuro só fica bem visível no aviso (olhos grandes).
- `enemies/fishman/fishman.gd` e `enemies/flyer/flyer.gd` passaram de 200 linhas. Sugestão: tirar o voo e a subida pela amurada para componentes próprios.
- A área seca da chuva está fixa nas medidas do interior da cabine (`night/rain_drop.gdshader`). Se a cabine mudar (M9), atualizar.
- No `.tscn`, o `Transform3D` guarda a base por linhas. Rotações escritas à mão precisam ser conferidas rodando a cena; isso causou o bug corrigido em `25ce483`.
- O console mostra, a cada noite, um aviso sobre a malha de navegação ler as formas CSG. É esperado até o M9 (decisão 0014).
- A vara atravessa paredes, não há linha de pesca e o item carregado fica por cima da dica do HUD; o galão aparece grande nas mãos.
- Sem som (M9). Falhas, bateria, inimigos e tempestade ainda não mudam com a noite (M7).
- Gaivotas no amanhecer ficam para o M9.
- Sair da run no meio de uma transição (menus do M8) vai exigir cuidado: a `Run` aguarda tweens e timers no amanhecer e na morte.

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
