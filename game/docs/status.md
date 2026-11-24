# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 a M7: fundação, noite e pedido, pesca, loop da run, iluminação, combate, tempestade, cartas e dificuldade.
- Jogável hoje, tudo em greybox:
  - run de noites encadeadas, com bilhete na mesa e alfinete por resultado;
  - pedido crescente, pesca com isca e minijogo, entrega no freezer;
  - 3 vidas, passe livre secreto, tela de fim de run e nova run;
  - gerador, 6 lâmpadas, luz de emergência e manutenção segurando E;
  - lanterna no F, que atordoa, com a bateria recarregada na caixa de pilhas da mesa;
  - vida com regeneração e morte encerrando a run;
  - revólver no 2 (vara no 1);
  - peixe-homem que sobe no escuro, persegue pelo barco todo, foge quando a luz volta e morre com 3 tiros;
  - tempestade a partir da noite 2: balanço forte, chuva, relâmpagos, céu fechado, mais falhas e voadores que mergulham no jogador e nas lâmpadas;
  - seleção de cartas antes da noite 1 e entre as noites (9 cartas, 3 slots, 3 rerolls), com os bônus valendo na noite seguinte;
  - dificuldade crescendo a cada noite.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação, combate, inimigos, tempestade, cartas, dificuldade).

## Próximo passo
- M8 Meta e menus, com `/planejar`: pontos no fim da run (10 por noite cumprida + 1 por peixe entregue), upgrades permanentes (vida, dano e poder da vara, +10% por nível até 5), save só da meta-progressão (autoload `MetaProgress`, com nota de decisão), menu principal e pausa. Regras em `docs/escopo-mvp.md` (seção Meta-progressão).
- Os upgrades permanentes devem somar no `PlayerStats` junto com as cartas.

## Para validar jogando
- Input real através do `SubViewport`: mouse, E (inclusive segurado), Q, G, Tab, F, 1, 2 e R. As capturas de tela acionaram as ações pelo código.
- Tempestade:
  - para forçar: `first_night` = 1 e `chance` = 1 em `night/storm_settings.tres`; para começar cedo, também `start_window_min` e `start_window_max` = 0;
  - conferir o balanço 3×, a chuva na baixa resolução e o voador (visibilidade no escuro, tempo de aviso de 0,6 s, acertá-lo a tiro).
- Combate: ritmo do peixe-homem, atordoamento com o rosto no centro do facho, fuga com a luz de volta, peixe-homem prendendo o jogador na porta.
- Iluminação: escuridão da emergência, alcance das lâmpadas dos postes, desempenho com as luzes com sombra e carga de manutenção na noite 1.
- Cartas: clicar nas cartas, no reroll e na troca com o mouse; conferir os efeitos na noite seguinte.
- Dificuldade: como ela sobe ao longo de várias noites (valores em `docs/sistemas/dificuldade.md`).
- Refinamento de valores fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- O peixe-homem não reage ao levar tiro, e o voador escuro só fica bem visível no aviso (olhos grandes).
- `enemies/fishman/fishman.gd` e `enemies/flyer/flyer.gd` passaram de 200 linhas. Sugestão: tirar o voo e a subida pela amurada para componentes próprios.
- A área seca da chuva está fixa nas medidas do interior da cabine (`night/rain_drop.gdshader`). Se a cabine mudar (M9), atualizar.
- No `.tscn`, o `Transform3D` guarda a base por linhas. Rotações escritas à mão precisam ser conferidas rodando a cena; isso causou o bug corrigido em `25ce483`.
- O console mostra, a cada noite, um aviso sobre a malha de navegação ler as formas CSG. É esperado até o M9 (decisão 0014).
- A vara atravessa paredes, não há linha de pesca e o item carregado fica por cima da dica do HUD; o galão aparece grande nas mãos.
- Sem som (M9).
- Durante a noite não há onde ver as cartas equipadas (só na seleção); o diário seria um bom lugar.
- O pool tem só 9 cartas: os slots enchem na noite 4 e as seleções encolhem conforme o pool esvazia.
- Gaivotas no amanhecer ficam para o M9.
- Sair da run no meio de uma transição (menus do M8) vai exigir cuidado: a `Run` aguarda tweens e timers no amanhecer e na morte.
- Commits com comando encadeado: só fazer commit se o check terminar com código 0 (o primeiro commit do M7 entrou quebrado e foi refeito antes do push).

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
