# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 a M9: fundação, noite e pedido, pesca, loop da run, iluminação, combate, tempestade, cartas e dificuldade, meta e menus, mar e céu. O roteiro do MVP está completo.
- Jogável hoje, com o barco e os personagens em greybox:
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
  - menu principal, pausa no Esc, pontos no fim da run e upgrades permanentes salvos em `user://meta_progress.cfg`;
  - céu do addon Sky3D seguindo o relógio da noite (estrelas, Via Láctea, lua cheia, amanhecer) e fechando na tempestade, e oceano com ondas do addon Boujie Water Shader, ambos provisórios (decisão 0016).
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação, combate, inimigos, tempestade, cartas, dificuldade, meta).
- Infraestrutura alinhada ao `godot-template`: sem o fluxo multiagente (0017), parse que compila todos os scripts com os autoloads (0018), check reprovando gdtoolkit ausente, branch só a pedido do desenvolvedor (0019) ferramentas em Node para Windows e Linux, com o caminho do Godot no `.env` local (0020), e colaboração por fork com `/configurar`, `/colaborar`, `/integrar` e CI no GitHub Actions (0021). Esta máquina está configurada como dono.
- `##` em toda função do jogo (0022): as 292 funções que faltavam foram documentadas, e o check reprova função sem `##` ou alterada com o `##` sem revisão. Os textos foram escritos lendo cada corpo, mas não passaram por revisão do desenvolvedor: corrija no diff o que estiver impreciso.

## Próximo passo
- Em tarefa própria (com `/planejar`), adotar a regra do `godot-template` de tipo sempre explícito, sem `:=` (decisão 0012 do modelo): migrar o código sistema por sistema e só no fim ligar a verificação, com uma decisão nova, senão o check reprova o projeto. Com `gdscript/warnings/inferred_declaration=2`, 80 dos 132 scripts reprovam (cerca de 200 ocorrências). No fim, ligar o aviso no `project.godot` e trazer do modelo o texto de tipagem de `docs/convencoes-gdscript.md`, que hoje contradiz a si mesmo.
- Teste intermitente: `test/scenes/card_selection_test.gd` (`test_choosing_a_card_equips_it_and_starts_the_first_night`) falhou uma vez na suíte completa e passou nas repetições, isolado e na suíte. Investigar a dependência de tempo antes que ele reprove um pull request no CI.
- Jogar o MVP inteiro de ponta a ponta e decidir com o desenvolvedor o que vem depois: refinar valores, ou começar o que ficou fora do MVP (assets no lugar da greybox, áudio, gaivotas no amanhecer; ver `docs/escopo-mvp.md`).
- As decisões 0011 e 0014 ainda citam o M9 como o marco dos assets. Se os assets ficarem para depois do MVP, registrar uma nova decisão que atualize esse prazo.
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
- Mar e céu: o mar sem água no convés, inclusive com o balanço forte; a boia com as ondas (a física da água é um plano fixo em y = 0 e as ondas sobem e descem até 0,35 m); o céu ao longo da noite e na tempestade; o desempenho do oceano.
- Refinamento de valores fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- O peixe-homem não reage ao levar tiro, e o voador escuro só fica bem visível no aviso (olhos grandes).
- `enemies/fishman/fishman.gd` e `enemies/flyer/flyer.gd` passaram de 200 linhas. Sugestão: tirar o voo e a subida pela amurada para componentes próprios.
- A área seca da chuva está fixa nas medidas do interior da cabine (`night/rain_drop.gdshader`). Se a cabine mudar, atualizar.
- No `.tscn`, o `Transform3D` guarda a base por linhas. Rotações escritas à mão precisam ser conferidas rodando a cena; isso causou o bug corrigido em `25ce483`.
- O console mostra, a cada noite, um aviso sobre a malha de navegação ler as formas CSG. É esperado enquanto o barco for CSG (decisão 0014).
- A vara atravessa paredes, não há linha de pesca e o item carregado fica por cima da dica do HUD; o galão aparece grande nas mãos.
- Sem som (fora do MVP).
- Durante a noite não há onde ver as cartas equipadas (só na seleção); o diário seria um bom lugar.
- O pool tem só 9 cartas: os slots enchem na noite 4 e as seleções encolhem conforme o pool esvazia.
- Gaivotas no amanhecer ficaram para depois do MVP.
- A textura da Via Láctea do Sky3D é CC BY 4.0 e exige crédito no jogo (`docs/assets.md`); ainda não há tela de créditos.
- Os plugins dos addons não estão ativados em `project.godot`: as classes funcionam sem eles, mas os nós não aparecem com ícone e ajuda próprios no editor.
- `SkyDriver.environment()` não é usado por ninguém; pode sair.
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
