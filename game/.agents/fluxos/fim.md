# Fluxo: fim de sessão ou de tarefa

1. Confira o estado: `git status -sb`.
   - Na `main`: siga todos os passos. Numa branch criada a pedido do desenvolvedor: siga os passos 1 a 4 e não faça push (o passo 5 é só da `main`); diga no resumo em que branch ficaram os commits.
   - Mudanças desta sessão ainda sem commit: faça o commit do módulo correspondente (modelo na seção **Git** de `AGENTS.md`).
   - Mudanças que não são suas: não inclua; cite no resumo.
2. Rode o check completo:
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check.ps1`
   Se falhar, corrija em um commit próprio ou reporte. **Com check falhando não há push.**
3. Atualize a memória em `docs/`:
   - `status.md`: onde paramos, próximo passo, bloqueios.
   - `arquitetura.md`, `sistemas/` e `decisoes/`: o que tiver ficado pendente (o normal é já terem ido no commit do módulo).
   Commit: `docs(status): <resumo da sessão>`.
4. Revise os commits ainda não enviados:
   - Liste: `git log --oneline origin/main..HEAD` (sem remoto: os commits desta sessão).
   - Em cada commit (`git show --stat <hash>`): mensagem no modelo, sem rodapé de coautoria, escopo coerente com o módulo, nenhum arquivo indevido (`.godot/`, relatórios, segredos, binários sem motivo).
   - Diff total (`git diff origin/main...HEAD`) pelas categorias de `revisar.md`.
   - Bug real ou arquivo indevido: corrija em novo commit e volte ao passo 2.
   - Mensagem fora do modelo: corrija com `git commit --amend` se for o último commit; senão, cite no resumo.
   - As demais categorias não bloqueiam o push: relate no resumo.
5. Push: `git push origin main` (na primeira vez, `git push -u origin main`).
   - Sem remoto `origin`: não faça push; avise.
   - Rejeitado porque o remoto tem commits novos: `git pull --rebase origin main`. Com conflito, `git rebase --abort` e reporte. Sem conflito, rode o check completo de novo e repita o push.
   - Nunca use `--force`.
6. Responda com:
   - Resumo das mudanças de código (arquivos e propósito).
   - Arquivos de `docs/` alterados.
   - Commits enviados (hash curto e título), ou o motivo de não ter enviado.
   - Pontos da revisão que não bloquearam o push.
   - O que o desenvolvedor deve validar jogando (game feel, visual).
