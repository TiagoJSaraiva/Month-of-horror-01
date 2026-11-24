# 0019 — Git: branch só a pedido do desenvolvedor

- **Data**: 2026-11
- **Status**: aceita (substitui 0017)

## Contexto
A 0017 manteve o trabalho direto na `main` e proibiu branches. O desenvolvedor quer poder testar uma feature à parte, sem misturá-la na `main` antes de decidir, como fez no the-beacon (branches `teste/*` com versões de demonstração para avaliação).

## Decisão
- Trabalho direto na `main`. O agente só cria branch a pedido explícito do desenvolvedor. Na branch valem as mesmas regras de commit; merge na `main`, rebase e exclusão da branch também só a pedido.
- O agente faz um commit ao fim de cada módulo, com check passando, no modelo `<tipo>(<escopo>): <resumo>` descrito em `AGENTS.md`, sem rodapé de coautoria.
- O fluxo `fim` revisa os commits não enviados e faz push da `main` se o check e a revisão passarem. Numa branch, o `fim` faz tudo menos o push. Nunca `--force`.
- Continua sem o fluxo `multiagente` (0017).

## Alternativas descartadas
- **Manter a proibição**: o agente recusaria trabalhar numa branch de teste, e o desenvolvedor teria de gerenciá-la sozinho.
- **Branch por tarefa com pull request**: processo pesado para um desenvolvedor só.

## Consequências
A `main` continua sendo o padrão, e uma branch é sempre uma escolha explícita do desenvolvedor. O que está numa branch não vai ao remoto pelo agente: o desenvolvedor decide se ela é integrada, enviada ou apagada.
