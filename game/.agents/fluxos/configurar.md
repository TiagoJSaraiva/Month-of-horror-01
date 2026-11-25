# Fluxo: configurar esta máquina

Uma vez por máquina (pode repetir sem risco). Deixa a máquina pronta para o papel de **dono** ou de **colaborador**. Não altera arquivos versionados: o papel fica em `git config projeto.papel` e o caminho do Godot no `.env`, ambos fora do git.

1. Rode o diagnóstico: `node scripts/configurar.mjs` e mostre o resultado ao desenvolvedor.
2. Papel não configurado: pergunte se esta máquina é do **dono** do projeto (trabalha no repositório original, na `main`) ou de um **colaborador** (trabalha no próprio fork e contribui por pull request). Grave com `node scripts/configurar.mjs --papel <dono|colaborador>`.
3. Corrija o que é do projeto, confirmando cada passo com o desenvolvedor:
   - **Godot**: use um executável sugerido no diagnóstico ou peça o caminho; grave com `node scripts/configurar.mjs --godot "<caminho>"`. Godot ausente: indique a 4.7.x no site oficial (no Linux, o executável, não o Flatpak) e espere a instalação.
   - **gdtoolkit**: rode o comando que o diagnóstico mostra (pergunte antes).
   - **Colaborador**: `origin` deve ser o fork dele. Peça a URL do repositório original, grave com `node scripts/configurar.mjs --upstream <url>` e rode `git fetch upstream`.
   - **Identidade do git** ausente: peça nome e e-mail e rode `git config --global user.name "<nome>"` e `git config --global user.email "<e-mail>"` (pergunte antes: é configuração global).
4. Programas ausentes (Node 18+, Python 3, Git): mostre o comando do sistema dele e pergunte antes de rodar. Nunca instale nada sem confirmação.
   - Windows: `winget install OpenJS.NodeJS.LTS`, `winget install Python.Python.3.12`, `winget install Git.Git`.
   - Linux (Debian/Ubuntu): `sudo apt install nodejs python3 python3-pip git`; em outras distribuições, o gerenciador equivalente.
5. Repita o diagnóstico até aparecer "Máquina pronta". Depois rode o check completo: `node scripts/check.mjs`.
6. Lembre, se ele usa VS Code: o caminho do Godot da extensão godot-tools vai nas configurações de **usuário** (`godotTools.editorPath.godot4`), não no workspace.
7. Responda com o papel configurado, o que foi corrigido e o próximo passo: colaborador, `/colaborar`; dono, `/inicio`.
