# Fluxo: multiagente

Você é o **orquestrador**: planeja, distribui tarefas a subagentes que trabalham em paralelo (cada um na própria branch e worktree), revisa diffs, analisa erros, testa e integra na `main`. Você não implementa as tarefas.

## 1. Pré-condições

- **Modelo dos subagentes**: deve vir no pedido (ex.: `/multiagente sonnet: implementar pulo e HUD`). Se não vier, pergunte qual usar (ex.: Haiku 5.5, Sonnet 5.5) e pare até a resposta. Não escolha por conta própria.
- Se a sua ferramenta não consegue criar subagentes com o modelo pedido, avise e pare.
- Você deve estar na `main` com a árvore limpa (`git status`). Mudanças pendentes suas: commit do módulo. Mudanças de outra origem: pare e pergunte.
- Rode o check completo na `main`. Se falhar, reporte e pare: os subagentes herdariam a falha.

## 2. Plano

Siga `planejar.md` e acrescente a divisão em tarefas:

- Para cada tarefa: nome curto (`<slug>`, minúsculas e hífen), objetivo, arquivos que ela cria ou altera (posse exclusiva), testes e commits previstos.
- Duas tarefas da mesma rodada **nunca** alteram o mesmo arquivo. Arquivos compartilhados (`project.godot`, autoloads, input map, camadas, `docs/arquitetura.md`, `docs/status.md`) ficam com uma única tarefa ou com você, na integração.
- Tarefa que depende de outra vai para a rodada seguinte, depois do merge da anterior.
- No máximo 4 subagentes por rodada.
- O que não for paralelizável: diga, e proponha fazer pelo fluxo normal.

Pare e aguarde aprovação.

## 3. Worktrees

Para cada tarefa, a partir de `game/` na pasta principal:

```powershell
if (-not (Test-Path .worktrees)) { New-Item -ItemType Directory .worktrees | Out-Null }
if (-not (Test-Path .worktrees/.gdignore)) { New-Item -ItemType File .worktrees/.gdignore | Out-Null }
git worktree add .worktrees/<slug> -b agente/<slug> main
```

O projeto do subagente fica em `game/.worktrees/<slug>/game`. `.worktrees/` está no `.gitignore` e é ignorado pelo `check.ps1`; o `.gdignore` impede o editor do Godot de importar as cópias.

## 4. Subagentes

Um por tarefa, em paralelo, com o modelo pedido. O subagente não vê esta conversa: o prompt precisa ser completo.

- **Pasta de trabalho**: o caminho absoluto de `.worktrees/<slug>/game`. Todo comando e toda edição acontecem lá, nunca na pasta principal.
- Leia `AGENTS.md` e `docs/convencoes-gdscript.md` dessa pasta e siga-os.
- A tarefa: objetivo, arquivos sob sua posse, testes esperados, commits previstos e o trecho do plano que importa.
- Commits na branch `agente/<slug>` ao fim de cada módulo, no modelo de `AGENTS.md`, com `check.ps1 -Fix -Fast` passando antes. Ao terminar: check completo na worktree.
- Proibido: push, merge, trocar de branch, alterar arquivos fora da tarefa, editar `docs/status.md`. Precisou de arquivo fora do escopo ou tem dúvida de design: pare e relate.
- Relatório final: commits (hash curto e título), arquivos alterados, resultado do check, dúvidas e o que validar jogando.

## 5. Revisão de cada branch

Quando um subagente termina:

1. `git log --oneline main..agente/<slug>` e `git diff main...agente/<slug>`.
2. Revise pelas categorias de `revisar.md`. Confira também se só arquivos da tarefa mudaram e se as mensagens seguem o modelo.
3. Rode o check completo na worktree; não confie só no relatório.
4. Problema encontrado: devolva ao **mesmo** subagente (com o contexto dele) uma lista objetiva do que corrigir. Você não corrige o código da tarefa.
5. Duas rodadas de correção sem resolver: pare essa tarefa e reporte ao desenvolvedor.

## 6. Integração na `main`

Na pasta principal, uma branch aprovada por vez, na ordem de dependência:

```powershell
git merge --no-ff agente/<slug> -m "merge(<escopo>): <resumo da tarefa>"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1 -Fast
```

- Conflito: resolva preservando a intenção dos dois lados. Se envolver decisão de design, `git merge --abort` e pergunte.
- Check falhando após o merge: analise. Ajuste pequeno de integração (ex.: duas tarefas registrando a mesma ação de input) pode ser seu, em commit `fix(<escopo>): ...`. Algo maior volta para um subagente.
- Rodada seguinte: crie as novas worktrees a partir da `main` já integrada (passo 3).

## 7. Encerramento

1. Siga `fim.md` por completo: check, memória, revisão dos commits e push da `main`.
2. Limpe as tarefas integradas, mesmo que o push tenha falhado:
   ```powershell
   git worktree remove .worktrees/<slug>
   git branch -d agente/<slug>
   git worktree prune
   ```
   - `worktree remove` recusou: veja `git -C .worktrees/<slug> status --short`. Só cache ou relatório: repita com `--force`. Trabalho não integrado: mantenha e reporte.
   - `branch -d` recusou (branch não integrada): não force; reporte.
   - Tarefa não integrada: mantenha worktree e branch e reporte.
3. Confirme que nenhuma branch `agente/*` foi para o remoto: `git ls-remote --heads origin "agente/*"` deve vir vazio.
4. Responda com: tarefas e modelo usado, commits integrados, problemas achados na revisão, o que ficou pendente e o que validar jogando.
