# Fluxo: início de sessão

1. Confirme a versão do Godot:
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-godot-version.ps1`
   (no Claude Code, um hook já roda isso ao abrir a sessão). Se der ERRO, pare e avise.
2. Confira o git: `git status -sb` e `git worktree list`. Avise se a branch não for `main`, se houver mudanças sem commit, commits não enviados ou worktrees em `.worktrees/` (sessão `multiagente` interrompida).
3. Leia `docs/status.md` e as notas que ele citar.
4. Responda em até 5 linhas: estado atual, próximo passo, bloqueios, dúvidas abertas (inclua os avisos do git).
5. Não escreva nem altere código neste fluxo.
