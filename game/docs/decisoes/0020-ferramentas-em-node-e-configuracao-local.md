# 0020 — Ferramentas em Node e configuração local, para Windows e Linux

- **Data**: 2026-11
- **Status**: aceita (atualiza as ferramentas citadas em 0002 e 0018)

## Contexto
O projeto deve aceitar colaboradores em Windows e Linux. Todo o ferramental assumia Windows PowerShell 5.1: o hook e os comandos chamavam `powershell`, que não existe no Linux; o `.mcp.json` usava `cmd /c npx`; os scripts filtravam caminhos com `\` e chamavam o `runtest.cmd`. Além disso, o caminho do Godot desta máquina estava escrito no `.code-workspace` versionado, e não havia `.gitattributes` nem versão fixa do gdtoolkit.

## Decisão
- **Ferramentas em Node** (mínimo 18, só módulos nativos, sem `npm install`): `scripts/check.mjs`, `check-godot-version.mjs`, `check-doc-review.mjs`, `mcp-godot.mjs` e as regras em `scripts/lib/`. O comando `node` tem o mesmo nome em Windows e Linux, e o Node já era exigido pelo MCP do Godot. As etapas e as regras do check não mudam (0018); mudam os comandos: `node scripts/check.mjs [--fix] [--fast]`.
- **Configuração local em `.env`** (ignorado pelo git; modelo versionado em `.env.example`): `GODOT_PATH`. Uma variável de ambiente com o mesmo nome vale mais que o `.env`. Hook, check e MCP leem o mesmo valor. Nenhum caminho de máquina vai para arquivo versionado: o caminho do Godot no VS Code fica nas configurações de usuário de cada pessoa (`godotTools.editorPath.godot4`).
- **Hook e MCP multiplataforma**: o hook chama `node "${CLAUDE_PROJECT_DIR}/scripts/check-godot-version.mjs"` (no Windows ele roda no Git Bash); o `.mcp.json` chama `node scripts/mcp-godot.mjs`, que carrega o `.env` e inicia o `npx` com shell só no Windows.
- **`.gitattributes`** na raiz do repositório: texto guardado com LF; `.sh` sempre LF e `.cmd`/`.bat` sempre CRLF.
- **gdtoolkit com versão exata** em `requirements.txt`; o check avisa quando a versão instalada é outra.
- **Godot 4.7.x de qualquer fonte** (Steam, site oficial): o check compara só a versão (0002). No Linux, `GODOT_PATH` aponta para o executável baixado do site; o Godot via Flatpak não serve, porque não é um arquivo executável.
- `rendering_device/driver.windows="d3d12"` continua no `project.godot` (ver alternativas).

Validado no Windows (Godot 4.7.2 da Steam) e no Linux (Ubuntu 24.04 no WSL, Godot 4.7.2 oficial): check completo, a bateria de sabotagens, o hook chamado de outra pasta e o MCP respondendo pelo script de partida.

## Alternativas descartadas
- **PowerShell 7 (`pwsh`) em todos os sistemas**: obrigaria todos, inclusive no Windows, a instalar o `pwsh`; o Node já estava em todas as máquinas.
- **Scripts em Python** (já exigido pelo gdtoolkit): o comando muda entre sistemas (`python` no Windows, `python3` no Linux), o que quebra o hook e o `.mcp.json` versionados.
- **D3D12 só nesta máquina, via `override.cfg` ignorado pelo git**: testado; quando o editor salva as configurações do projeto, o valor do `override.cfg` é gravado de volta no `project.godot` e vazaria no próximo commit. O D3D12 fica para todos: só afeta Windows com os renderizadores Forward+ e Mobile, e é bem suportado nas placas atuais.

## Consequências
Pré-requisitos iguais nos dois sistemas: Godot 4.7.x, Node 18+, Python com o gdtoolkit fixado e Git. No Linux, o `pip install` global costuma ser bloqueado (PEP 668); o README mostra a instalação por usuário. Comandos e instruções passam a citar `node scripts/...`. Os textos das decisões 0002 e 0018 ainda citam os scripts `.ps1` antigos; vale o nome atual registrado aqui.
