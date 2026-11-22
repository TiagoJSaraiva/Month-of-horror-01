@AGENTS.md

## Específico do Gemini CLI

- Fluxos disponíveis como comandos: `/inicio`, `/planejar`, `/revisar`, `/fim`, `/multiagente`.
- Não há hook de início: rode a checagem de versão descrita em `.agents/fluxos/inicio.md`.
- `/multiagente`: se a versão do Gemini CLI em uso não oferecer subagentes com escolha de modelo, avise e não execute o fluxo.
