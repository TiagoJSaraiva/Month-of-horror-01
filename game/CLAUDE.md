@AGENTS.md

## Específico do Claude Code

- Fluxos disponíveis como comandos: `/inicio`, `/planejar`, `/revisar`, `/fim`, `/multiagente`.
- O hook `SessionStart` (`.claude/settings.json`) roda a checagem de versão do Godot ao abrir a sessão; se ela acusar ERRO, avise antes de qualquer outra coisa.
- MCP `godot` (`.mcp.json`) disponível para rodar o projeto e ler o console.
- A atribuição automática de commits está desligada em `.claude/settings.json` (`attribution`). Mesmo assim, nunca escreva `Co-Authored-By` nem assinatura na mensagem.
- `/multiagente`: crie os subagentes com a ferramenta `Agent`, passando `model` (`haiku`, `sonnet` ou `opus`) e `run_in_background: true`, um por tarefa, todos na mesma mensagem. **Não** use `isolation: "worktree"`: a worktree é criada pelo fluxo em `.worktrees/<slug>`. Para devolver correções, use `SendMessage` ao mesmo subagente.
