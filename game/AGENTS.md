# AGENTS.md — Terror Month Game

Instruções para qualquer agente de IA (Claude Code, Codex, Gemini CLI e outros) que trabalhe neste repositório. Este arquivo é a fonte da verdade; `CLAUDE.md` e `GEMINI.md` apenas o importam.

## Projeto

- Jogo em **Godot 4.7** com **GDScript 2.0**. MVP em desenvolvimento.
- Ambiente: Windows, PowerShell. O executável do Godot está em `$env:GODOT_PATH`.
- O desenvolvedor lê e revisa todo o código. Legibilidade vale mais que esperteza.
- Idioma: responda e documente em **português**. Identificadores, nomes de arquivo e nomes de nós em **inglês**.

## Comece aqui

1. Confirme a versão do Godot: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-godot-version.ps1`. No Claude Code, um hook já faz isso ao abrir a sessão; nos demais agentes (Codex, Gemini CLI), rode você. Se der ERRO, pare e avise antes de ler ou editar qualquer arquivo do projeto.
2. Leia `docs/status.md`: onde paramos, próximo passo, bloqueios.
3. Antes de mexer em um sistema, leia `docs/arquitetura.md` e a nota do sistema em `docs/sistemas/`.
4. Antes de escrever GDScript, leia `docs/convencoes-gdscript.md`.
5. Antes de propor mudança estrutural, consulte `docs/decisoes/`.

## Fluxo de trabalho

Procedimentos detalhados em `.agents/fluxos/` (também expostos como comandos no Claude Code e no Gemini CLI):

| Fluxo | Quando |
|---|---|
| `inicio.md` | Início de sessão |
| `planejar.md` | Qualquer tarefa que crie sistema, cena ou mais de ~3 arquivos |
| `revisar.md` | Revisão de diff, a pedido |
| `fim.md` | Fim de sessão ou de tarefa: check, memória, revisão dos commits e push |

Regras gerais:
- Tarefa não trivial: **plano primeiro, código só após aprovação**.
- Mudanças pequenas e incrementais. Um passo verificável por vez.
- Não refatore o que não foi pedido; sugira no resumo.
- Dúvida real de design ou escopo: pergunte em vez de supor.
- Commits e push seguem a seção **Git** abaixo.

## Regras essenciais de GDScript

Detalhes e exemplos em `docs/convencoes-gdscript.md`. O mínimo inegociável:
- **Tipagem estática em tudo**: variáveis, parâmetros, retornos, arrays (`Array[Enemy]`).
- **Somente sintaxe do Godot 4** (`@export`, `@onready`, `await`, `signal.connect(callable)`). Nunca sintaxe do Godot 3.
- Ações de input semânticas (`move_left`, `jump`), nunca `ui_*` para gameplay.
- "Call down, signal up": pai chama filho; filho emite sinal. Sem `get_parent().get_parent()`.
- Um script, uma responsabilidade: comportamento novo nasce em componente próprio, e regras de jogo ficam em funções puras testáveis, fora do nó.
- Sem números mágicos: `@export` para ajuste por instância, constantes para valores globais.
- Comentários explicam **por quê**, não o quê.

## Verificação

Comandos (rodar a partir da raiz do projeto):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1 -Fix -Fast   # formata + check rápido
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1              # check completo
```

- `-Fix` aplica `gdformat` nos scripts do projeto (nunca em `addons/`).
- Durante a implementação: `-Fast` após cada passo relevante.
- **Antes de declarar uma tarefa concluída: check completo passando.**
- Nunca apague, pule ou enfraqueça um teste para o check passar. Se a falha não for sua ou não tiver solução clara, reporte.
- Linhas `ERROR: Remote Debugger ... port` na saída dos testes são ruído conhecido, não falha.

## Testes (gdUnit4)

- Toda mecânica nova: testes unitários das regras em `test/unit/`.
- No máximo um teste de cena por mecânica, para o comportamento principal, em `test/scenes/`.
- Testes de física e movimento verificam **faixas** de valores, nunca igualdade exata.
- Arquivos `<alvo>_test.gd`, funções `test_<comportamento>`.
- Game feel não é testável: descreva no resumo o que o desenvolvedor deve validar jogando.

## Git

Decisão `0019`. O repositório fica na pasta acima de `game/` (cobre `game/` e `notes/`).

- **Todo trabalho acontece direto na `main`.** Crie branch só a pedido explícito do desenvolvedor (ex.: testar uma feature à parte). Nela valem as mesmas regras de commit; merge na `main`, rebase e exclusão da branch também só a pedido.
- **Commit ao fim de cada módulo.** Módulo é uma unidade coerente e verificável: um componente com seus testes, uma cena com seu script, uma correção, uma configuração. Tarefa com várias partes independentes vira vários commits; não acumule a tarefa inteira num commit só, nem faça commit de passo quebrado.
- Antes de cada commit: `check.ps1 -Fix -Fast` passando (check completo se o módulo mexe em cena ou em teste de cena). Nunca faça commit com check falhando.
- Adicione os arquivos do módulo pelo nome (`git add <arquivos>`) e confira `git status` e `git diff --staged` antes do commit. Mudanças que não são suas ficam fora; cite-as no resumo.
- Script novo: inclua no mesmo commit o `.uid` que o check gerou para ele (ex.: `player.gd` e `player.gd.uid`). Sem ele, outro clone gera um UID diferente e as cenas que apontam para o script passam a dar aviso.
- Notas de `docs/` (sistemas, arquitetura, decisões) entram no mesmo commit do código que as motivou. `docs/status.md` é atualizado no `fim`.
- **Push só no fluxo `fim`**, e só da `main`: `git push origin main`.
- Proibido: `push --force`, alterar commits já enviados (`commit --amend`, `rebase`, `reset` sobre eles), `--no-verify`, enviar outras branches ao remoto.

### Mensagem de commit

```
<tipo>(<escopo>): <resumo>

<corpo opcional>
```

- **tipo**: `feat` (mecânica, cena ou conteúdo novo), `fix` (correção de bug), `refactor` (estrutura muda, comportamento não), `perf`, `test` (só testes), `docs` (só `docs/` ou instruções de agente), `assets` (arte, som, fontes), `chore` (configuração, scripts, `project.godot`, ferramentas).
- **escopo**: sistema ou área afetada, em minúsculas (`player`, `combate`, `hud`, `input`, `status`). Omita se a mudança for transversal: `chore: atualiza gdUnit4`.
- **resumo**: em português, verbo no presente (`adiciona`, `corrige`, `remove`), minúsculo, sem ponto final, até 72 caracteres.
- **corpo**: só quando o porquê não é óbvio (motivo, efeito para quem joga, limitação conhecida). Linhas de até 72 caracteres, separado do resumo por uma linha em branco.
- **Sem rodapé de coautoria** (`Co-Authored-By`), assinatura de ferramenta ou menção ao agente.

Exemplos:

```
feat(player): adiciona pulo com coyote time e buffer de input

Janela de 0,1 s após sair da plataforma, exposta em @export para
ajuste no editor.
```

```
fix(hud): corrige barra de vida que não atualizava após cura
test(combate): cobre dano zero e dano maior que a vida
docs(status): registra fim da sessão do sistema de pulo
```

## Memória do projeto (`docs/`)

A memória entre sessões é a pasta `docs/`, versionada com o código.

| Arquivo | Conteúdo | Atualizar quando |
|---|---|---|
| `status.md` | Estado atual, próximo passo, bloqueios | Fim de toda sessão |
| `arquitetura.md` | Cenas, autoloads, sinais, input map, camadas de colisão | Mudou algum desses |
| `sistemas/<sistema>.md` | Como um sistema funciona e suas regras | Criou ou alterou o sistema |
| `decisoes/NNNN-titulo.md` | Decisão não trivial: contexto, escolha, alternativas | Tomou uma decisão estrutural |

Regras:
- Notas curtas, factuais e atuais. Prefira **editar** uma nota a criar outra.
- Registre o que é verdade sobre o projeto, não o histórico de tentativas.
- Atualize a nota no mesmo passo da mudança que a tornou desatualizada.
- Uma decisão aceita só muda com uma nova decisão que a substitua (marque a antiga como substituída).
- Ao criar ou alterar uma regra, convenção ou decisão, confira se ela contradiz `AGENTS.md`, `docs/convencoes-gdscript.md` ou uma decisão aceita. Se contradisser, não aplique: aponte o conflito ao desenvolvedor e decidam juntos (resolver pode exigir uma nova decisão em `docs/decisoes/`).

## Arquivos do Godot: cuidados

- `addons/` e `.godot/`: **não editar**. São de terceiros e cache, respectivamente.
- Arquivos `.uid` e `.import`: versionados. Ao mover ou renomear um script, mova o `.uid` junto (`git mv`). Não crie nem edite `.uid` à mão; o Godot os gera no próximo import (o check faz isso).
- `.tscn` e `.tres`: edições pequenas e cuidadosas. Ao referenciar recursos, use `path`; nunca invente valores `uid://`.
- `project.godot`: pode alterar input map, autoloads e nomes de camadas, sempre citando no resumo. **Nunca** altere `config/features` (versão do Godot).

## Ferramentas opcionais

- Se houver um MCP `godot` disponível (configurado para o Claude Code em `.mcp.json`), use-o para rodar o projeto e ler o console após mudanças em cenas. Sem ele, peça ao desenvolvedor para rodar e reportar.
