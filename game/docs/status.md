# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 (fundação), M1 (noite e pedido), M2 (pesca), M3 (loop da run), M4 (iluminação) e M5 (combate).
- Jogável hoje, tudo em greybox:
  - run de noites encadeadas, com bilhete na mesa e alfinete por resultado;
  - pedido crescente, pesca com isca e minijogo, entrega no freezer;
  - 3 vidas, passe livre secreto, tela de fim de run e nova run;
  - gerador, 6 lâmpadas, luz de emergência e manutenção segurando E;
  - lanterna no F, que atordoa, com a bateria recarregada na caixa de pilhas da mesa;
  - vida com regeneração e morte encerrando a run;
  - revólver no 2 (vara no 1);
  - peixe-homem que sobe no escuro, persegue pelo barco todo, foge quando a luz volta e morre com 3 tiros.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação, combate, inimigos).

## Próximo passo
- M6 Tempestade, com `/planejar`: evento a partir da noite 2, balanço forte, chuva, céu de tempestade (mais uma `SkyPalette`), falhas de manutenção mais frequentes e o voador, que mergulha no jogador e ataca as lâmpadas (`Bulb.burn_out()`). Regras em `docs/escopo-mvp.md` (seções Tempestade e Inimigos).
- Se o prazo apertar, a tempestade é a primeira candidata a corte ou simplificação.

## Para validar jogando
- Input real através do `SubViewport`: mouse, E (inclusive segurado), Q, G, Tab, F, 1, 2 e R. As capturas de tela acionaram as ações pelo código.
- Combate:
  - peixe-homem a 2,6 m/s (o jogador anda a 3,5), golpe com 0,6 s de preparação e 20 de dano;
  - surgimento a cada 20 s logo abaixo do limiar e a cada 6 s no escuro total, no máximo 3 a bordo;
  - atordoamento com o rosto perto do centro do facho; fuga com a luz de volta; peixe-homem prendendo o jogador na porta da cabine.
- Iluminação: escuridão da emergência, facho da lanterna, alcance das lâmpadas dos postes, desempenho com as luzes com sombra e carga de manutenção na noite 1.
- Bilhete e transições do M3.
- Refinamento de valores fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- O peixe-homem não reage ao levar tiro (sem tranco nem sangue); só se nota o acerto quando ele cai no terceiro.
- `enemies/fishman/fishman.gd` passou de 200 linhas. Sugestão: tirar a subida e a fuga pela amurada para um componente próprio.
- O console mostra, a cada noite, um aviso sobre a malha de navegação ler as formas CSG. É esperado até o M9 (decisão 0014).
- A vara atravessa paredes, não há linha de pesca e o item carregado fica por cima da dica do HUD; o galão aparece grande nas mãos.
- Sem som (M9). Falhas, bateria e inimigos ainda não mudam com a noite (M7).
- Gaivotas no amanhecer ficam para o M9.
- Sair da run no meio de uma transição (menus do M8) vai exigir cuidado: a `Run` aguarda tweens e timers no amanhecer e na morte.

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
