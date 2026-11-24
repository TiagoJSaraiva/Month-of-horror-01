@AGENTS.md

## Específico do Claude Code

- Fluxos disponíveis como comandos: `/inicio`, `/planejar`, `/revisar`, `/fim`.
- O hook `SessionStart` (`.claude/settings.json`) roda a checagem de versão do Godot ao abrir a sessão; se ela acusar ERRO, avise antes de qualquer outra coisa.
- MCP `godot` (`.mcp.json`) disponível para rodar o projeto e ler o console.
- A atribuição automática de commits está desligada em `.claude/settings.json` (`attribution`). Mesmo assim, nunca escreva `Co-Authored-By` nem assinatura na mensagem.
