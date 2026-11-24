# 0017 — Git: commits por módulo e push no fim, sem multiagente

- **Data**: 2026-11
- **Status**: substituída por 0019

## Contexto
A 0007 criou, junto com os commits por módulo, o fluxo `multiagente`: subagentes em paralelo, cada um em branch e worktree próprias, revisados e integrados na `main` por um orquestrador. Na prática ele não se mostrou necessário: gasta mais tempo e tokens (prompt completo para cada subagente, revisão de cada branch, import do projeto do zero em cada worktree) e não ganha precisão em relação a um agente trabalhando direto na `main`.

## Decisão
- Trabalho direto na `main`, sem branches. O agente faz um commit ao fim de cada módulo, com check passando, no modelo `<tipo>(<escopo>): <resumo>` descrito em `AGENTS.md`, sem rodapé de coautoria.
- O fluxo `fim` revisa os commits não enviados e faz push da `main` se o check e a revisão passarem. Nunca `--force`.
- O fluxo `multiagente` sai do projeto: `.agents/fluxos/multiagente.md`, os comandos `/multiagente`, o tipo de commit `merge` e o tratamento de `.worktrees/` no `.gitignore` e no `check.ps1`.

## Alternativas descartadas
- **Manter o multiagente como opcional**: instruções que ninguém usa continuam ocupando contexto e exigindo manutenção (o `check.ps1`, por exemplo, deixava de verificar formatação e lint dentro das worktrees).
- **Branch por tarefa com pull request**: processo pesado para um desenvolvedor só.
- **Um commit por sessão**: mistura módulos e dificulta reverter uma parte.

## Consequências
Tarefas grandes são feitas em sequência, módulo a módulo, pelo fluxo normal. O histórico mostra cada módulo separado e o remoto fica em dia ao fim de cada sessão. O check e a revisão do `fim` continuam sendo a barreira antes do push.
