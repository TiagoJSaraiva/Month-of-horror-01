# Fluxo: início de sessão

1. Confirme a versão do Godot e o papel desta máquina:
   `node scripts/inicio-sessao.mjs`
   (no Claude Code, um hook já roda isso ao abrir a sessão). Se der ERRO, pare e avise. Papel não configurado: proponha `/configurar` antes de qualquer trabalho.
2. Confira o git: `git status -sb`. Avise se houver mudanças sem commit ou commits não enviados.
   - Dono: avise se a branch não for `main`.
   - Colaborador: avise se estiver na `main` (proponha `/colaborar`).
3. Leia `docs/status.md` e as notas que ele citar. **Colaborador**: leia também a missão da branch (`docs/branches/<branch>/missao.md`).
4. Responda em até 5 linhas: estado atual (colaborador: da missão), próximo passo, bloqueios, dúvidas abertas (inclua os avisos do git).
5. Não escreva nem altere código neste fluxo.
