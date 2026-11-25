# 0018 — Pipeline de verificação com parse numa única execução, com autoloads

- **Data**: 2026-11
- **Status**: aceita (substitui 0005); ferramentas atualizadas pela 0020

## Contexto
A 0005 fazia o parse com `godot --headless --import`. Uma sabotagem mostrou que o `--import` só atualiza cache e `.uid`: ele não compila scripts que nenhuma cena usa. Um erro de tipo (`var x: int = "texto"`) ou uma declaração sem tipo num script ainda não usado passava pelo check completo.

O the-beacon, criado a partir de uma versão anterior deste modelo, já tinha resolvido isso. Primeiro tentou `godot --headless --check-only --script` em cada `.gd` (decisão 0007 de lá), mas esse modo não registra os autoloads: todo script que usa um deles acusa "Identifier not found", embora funcione no jogo. A solução que ficou (decisão 0013 de lá) é um script headless comum, que registra os autoloads e também acusa erros de compilação.

## Decisão
`scripts/check.ps1` encadeia: versão do Godot → gdtoolkit instalado → `gdformat --check` → `gdlint` → parse → testes gdUnit4. `-Fast` roda só `test/unit`; `-Fix` formata antes. Check completo é obrigatório antes de concluir uma tarefa. godot-mcp complementa com execução do jogo e leitura do console.

O parse roda `--import` e depois `scripts/parse_check.gd` (fora do `res://`, porque `scripts/` tem `.gdignore`), que recebe todos os `res://*.gd` do projeto depois de `--`, carrega cada um ignorando o cache e sai com código 1 se algum não compilar. A busca por `SCRIPT ERROR|Parse Error|Failed to load script` na saída continua como reforço. O parse pega erros de compilação (sintaxe, tipos, identificadores e métodos inexistentes em código tipado), não erros de execução.

Validado por sabotagem: `var x: int = "texto"` num script que nenhuma cena usa reprova o parse, e um script que usa um autoload compila.

## Alternativas descartadas
- **Só `--import`** (0005): não compila scripts não usados.
- **`--check-only` por arquivo**: não registra os autoloads e custa uma inicialização do Godot por script.
- **GUT**: mais simples, mas sem o scene runner de input simulado do gdUnit4.
- **Só rodar o jogo**: pega erros apenas no caminho executado.

## Consequências
Uma inicialização do Godot para todos os scripts. Os `_ready` dos autoloads rodam durante o parse: um autoload não deve gravar nada ao iniciar. Um script novo em `scripts/` não entra no parse; ele é ferramenta, não jogo. Testes de cena são mais lentos e frágeis: no máximo um por mecânica, com asserções por faixa.
