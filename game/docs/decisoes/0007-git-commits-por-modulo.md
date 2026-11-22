# 0007 — Git: commits por módulo, push no fim e multiagente

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Antes, o agente nunca fazia commit: só sugeria uma mensagem no `fim`. O histórico ficava com poucos commits grandes, montados à mão. Também faltava um jeito de dividir tarefas grandes entre vários agentes em paralelo.

## Decisão
- Trabalho direto na `main`. O agente faz um commit ao fim de cada módulo, com check passando, no modelo `<tipo>(<escopo>): <resumo>` descrito em `AGENTS.md`, sem rodapé de coautoria.
- O fluxo `fim` revisa os commits não enviados e faz push da `main` se o check e a revisão passarem. Nunca `--force`.
- O fluxo `multiagente` (a pedido) distribui tarefas a subagentes, cada um em branch `agente/<slug>` e worktree em `game/.worktrees/`. O orquestrador revisa, testa e faz merge `--no-ff` na `main`; as branches são apagadas localmente e nunca vão ao remoto.

## Alternativas descartadas
- **Branch por tarefa com pull request**: processo pesado para um desenvolvedor só.
- **Um commit por sessão**: mistura módulos e dificulta reverter uma parte.
- **Subagentes na mesma pasta, sem worktree**: edições e checks paralelos se atropelam.

## Consequências
O histórico mostra cada módulo separado e o remoto fica em dia ao fim de cada sessão. O agente passa a ter permissão de commit e push, então o check e a revisão do `fim` são a barreira antes do push. Cada worktree importa o projeto do zero no primeiro check, o que deixa o primeiro check de cada subagente mais lento.
