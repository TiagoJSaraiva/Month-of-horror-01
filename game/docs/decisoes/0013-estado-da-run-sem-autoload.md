# 0013 — Estado da run na cena Run, sem autoload

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A run atravessa várias noites. Cada noite é uma cena nova (`Night`), mas o número da noite, as falhas e o passe livre precisam sobreviver à troca. Ao fim da run tudo volta ao zero, e o M8 vai somar menus e meta-progressão salva.

## Decisão
- O estado vive em `RunState` (`RefCounted`), que pertence à cena `Run`.
- A `Run` cria cada `Night` dentro do `SubViewport` e passa para baixo o que a noite precisa (`night_number` e o bilhete) antes de ela entrar na árvore. A noite avisa o fim por sinal (`night_finished`).
- Uma run nova é uma `Run` nova: a `Main` libera a anterior e instancia outra, sem reset manual de estado.
- O único autoload previsto continua sendo o `MetaProgress` (M8), para o que é salvo entre runs.

## Alternativas descartadas
- **Autoload `RunState`**: estado global escondido, acessível de qualquer lugar. Reiniciar a run exigiria limpar campo por campo, e os testes dependeriam de um singleton.
- **Guardar o estado na `Main`**: a `Main` vai cuidar de menus (M8). Misturar o fluxo da run com ela daria dois motivos de mudança ao mesmo script.

## Consequências
- Testes de regra usam `RunState.new()`, e o teste de cena carrega `run/run.tscn` sozinho.
- O que a noite precisa saber da run chega por propriedade antes do `_ready`. Inimigos e cartas (M5, M7) seguem o mesmo caminho: a `Run` lê e repassa.
- A `Run` também é dona da interface da partida (`Hud`, transições, fim de run), já que é ela quem conduz o fluxo.
