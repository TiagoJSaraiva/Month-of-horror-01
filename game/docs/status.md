# Status

## Onde paramos
- MVP em andamento, seguindo o roteiro de `docs/escopo-mvp.md`. Feitos M0 (fundação), M1 (noite e pedido), M2 (pesca), M3 (loop da run) e M4 (iluminação).
- Jogável hoje, tudo em greybox:
  - run de noites encadeadas, com bilhete na mesa e alfinete por resultado;
  - pedido crescente, pesca com isca e minijogo, entrega no freezer;
  - 3 vidas, passe livre secreto, tela de fim de run e nova run;
  - gerador na popa com combustível e quebras, 6 lâmpadas que queimam, luz de emergência, galões e lâmpadas de reposição na cabine, manutenção segurando E;
  - lanterna no F, com bateria recarregada na caixa de pilhas da mesa.
- Regras de cada sistema em `docs/sistemas/` (movimento, balanço, noite, pedido, mãos, pesca, run, iluminação).

## Próximo passo
- M5 Combate, com `/planejar`: revólver de 6 tiros (hitscan, recarga infinita), vida com regeneração, morte encerrando a run e o peixe-homem. Regras em `docs/escopo-mvp.md` (seções Inimigos e Combate e vida).
- O peixe-homem usa `BoatLighting.light_level` (já exposto, ainda sem ouvinte) e fica atordoado com a lanterna.

## Para validar jogando
- Input real através do `SubViewport`: mouse, E (inclusive segurado), Q, G, Tab e F. As capturas de tela acionaram as ações pelo código.
- Iluminação: escuridão da emergência, facho da lanterna (22°, 16 m), alcance das lâmpadas dos postes e desempenho com as luzes com sombra.
- Valores do M4: tanque de 150 s, quebra a cada ~240 s, cada lâmpada ~720 s, bateria de 90 s, segurar 1 a 4 s. Talvez seja manutenção demais para a noite 1.
- Bilhete e transições do M3: alfinete, leitura do texto, tempos do amanhecer e do título.
- Refinamento de valores fica para depois, por decisão do desenvolvedor.

## Limitações conhecidas
- A vara atravessa paredes, não há linha de pesca e o item carregado fica por cima da dica do HUD; o galão aparece grande nas mãos.
- Sem som: uma quebra do gerador na popa só é notada pela luz que apaga (áudio no M9).
- Falhas e bateria ainda não mudam com a noite (M7) nem com a tempestade (M6).
- Gaivotas no amanhecer ficam para o M9.
- Sair da run no meio de uma transição (menus do M8) vai exigir cuidado: `Run._on_night_night_finished` aguarda tweens e timers.

## Bloqueios
- Nenhum.

## Pendências de infraestrutura
- `config/icon` aponta para `res://icon.svg`, que não existe: o jogo abre com esse erro no console.
- `config/features` ainda diz "GL Compatibility" com o renderer em Forward+. Só o editor do Godot deve atualizar esse campo (abrir e salvar o projeto).
- Confirmar que o check falha nas sabotagens (teste, parse, formatação, lint).
