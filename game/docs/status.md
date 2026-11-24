# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 a M8: fundação, noite e pedido, pesca, loop da run, iluminação, combate, tempestade, cartas e dificuldade, meta e menus.
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
  - dificuldade crescendo a cada noite;
  - menu principal, pausa no Esc, pontos no fim da run e upgrades permanentes salvos em `user://meta_progress.cfg`.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação, combate, inimigos, tempestade, cartas, dificuldade, meta).

## Próximo passo
- M9 Mar, céu e assets, com `/planejar`, o último marco do MVP: oceano e céu definitivos (lua e estrelas), assets CC0 no lugar da greybox (barco, peixes, inimigos, objetos), áudio (chuva, vento, trovão, gerador, inimigos) e gaivotas no amanhecer. Regras em `docs/escopo-mvp.md` (seção Mundo e visual) e nas decisões 0009 e 0011 (registro de assets em `docs/assets.md`).
- Ao trocar o barco por asset: refazer a área seca da chuva (`night/rain_drop.gdshader`) e conferir a malha de navegação (decisão 0014).

## Para validar jogando
- Input real através do `SubViewport`: mouse, E (inclusive segurado), Q, G, Tab, F, 1, 2 e R. As capturas de tela acionaram as ações pelo código.
- Tempestade:
  - para forçar: `first_night` = 1 e `chance` = 1 em `night/storm_settings.tres`; para começar cedo, também `start_window_min` e `start_window_max` = 0;
  - conferir o balanço 3×, a chuva na baixa resolução e o voador (visibilidade no escuro, tempo de aviso de 0,6 s, acertá-lo a tiro).
- Combate: ritmo do peixe-homem, atordoamento com o rosto no centro do facho, fuga com a luz de volta, peixe-homem prendendo o jogador na porta.
- Iluminação: escuridão da emergência, alcance das lâmpadas dos postes, desempenho com as luzes com sombra e carga de manutenção na noite 1.
- Cartas: clicar nas cartas, no reroll e na troca com o mouse; conferir os efeitos na noite seguinte.
- Dificuldade: como ela sobe ao longo de várias noites (valores em `docs/sistemas/dificuldade.md`).
- Meta: o fluxo menu → run → pausa → fim de run → menu, compras de upgrade, e fechar e reabrir o jogo para ver o progresso salvo.
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
- A pausa só abre com a noite em andamento, porque a `Run` aguarda tweens e timers no amanhecer, na morte e entre as noites.
- Testes de cena com a árvore pausada precisam esperar por frames: os timers do gdUnit4 param junto.
- Não há menu de configurações (volume, sensibilidade do mouse).
- Commits com comando encadeado: só fazer commit se o check terminar com código 0 (o primeiro commit do M7 entrou quebrado e foi refeito antes do push).

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
