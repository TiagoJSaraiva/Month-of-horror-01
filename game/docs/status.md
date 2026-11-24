# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 (fundação), M1 (noite e pedido), M2 (pesca) e M3 (loop da run).
- Jogável hoje, tudo em greybox:
  - run de noites encadeadas, com bilhete na mesa e alfinete por resultado;
  - pedido crescente, pesca com isca e minijogo, entrega no freezer;
  - 3 vidas, passe livre secreto, tela de fim de run e nova run.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run).

## Próximo passo
- M4 Iluminação, com `/planejar`: gerador, 6 lâmpadas, luz de emergência, lanterna com pilhas da cabine, reparos segurando a interação. Regras em `docs/escopo-mvp.md` (seção Iluminação).
- No plano do M4, decidir como as pilhas da lanterna são trocadas.

## Para validar jogando
- Input real através do `SubViewport`: mouse, E, Q, G e Tab. As capturas de tela acionaram as ações pelo código.
- Bilhete: visibilidade do alfinete ao entrar na cabine e leitura do texto.
- Tempos das transições: 3 s no amanhecer, 1 s de tela preta, título "NIGHT N" por 1,5 s.
- Refinamento de valores (pesca, balanço, tempos) fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- A vara atravessa paredes, não há linha de pesca e o peixe carregado fica por cima da dica do HUD.
- Gaivotas no amanhecer ficam para o M9.
- Sair da run no meio de uma transição (menus do M8) vai exigir cuidado: `Run._on_night_night_finished` aguarda tweens e timers.

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
