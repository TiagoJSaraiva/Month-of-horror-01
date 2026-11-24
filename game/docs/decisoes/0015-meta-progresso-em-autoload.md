# 0015 — Meta-progressão num autoload com save em ConfigFile

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Os pontos e os upgrades permanentes (M8) sobrevivem entre as runs e entre as sessões do jogo. A `Run` é recriada a cada run (decisão 0013), e o menu principal, a tela de upgrades e a `Run` precisam ler e mudar o mesmo progresso. O escopo já previa um único autoload para isso.

## Decisão
- O autoload `MetaProgress` (`autoload/meta_progress.gd`) guarda um `MetaState` e a lista de upgrades. É o único autoload do projeto e não guarda nada de uma run em andamento.
- As regras ficam em `MetaState` e `MetaRules` (`RefCounted`), testáveis sem o autoload.
- O save é um `ConfigFile` em `user://meta_progress.cfg`, gravado a cada mudança (ganhar pontos, comprar um nível), com uma chave de versão. Arquivo ausente, de outra versão ou inválido começa do zero.
- `use_save_path(path)` troca o arquivo; os testes usam um caminho próprio.

## Alternativas descartadas
- **`MetaProgress` como nó da `Main`**: a referência teria de descer até a `Run` e as telas por várias camadas.
- **Save em JSON**: exigiria converter tipos e validar à mão; o `ConfigFile` é nativo, legível e já lida com números.

## Consequências
- Qualquer cena pode ler o progresso sem receber referência, mas só a `Run` (pontos) e a tela de upgrades (compras) o mudam.
- O jogo grava no disco do jogador a cada compra e no fim de cada run.
- Um save por run, se vier depois do MVP, deve entrar como outra decisão, sem misturar com este autoload.
