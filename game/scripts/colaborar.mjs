// Cria a branch de uma contribuição a partir da main do repositório original (fluxo colaborar).
// Uso: node scripts/colaborar.mjs --branch <tipo>/<descricao>
// Cria a branch a partir de upstream/main (sem depender de o fork estar atualizado) e o esqueleto
// da missão em docs/branches/<tipo>/<descricao>/missao.md, que o agente preenche com o colaborador.
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { projectRoot as root, run } from "./lib/common.mjs";
import { branchDir, branchNameError, currentRole, git } from "./lib/collab.mjs";

function fail(message) {
    console.log(`ERRO: ${message}`);
    process.exit(1);
}

const args = process.argv.slice(2);
const branchIndex = args.indexOf("--branch");
const branch = branchIndex >= 0 ? args[branchIndex + 1] ?? "" : "";
if (branch === "") {
    fail("informe a branch: node scripts/colaborar.mjs --branch <tipo>/<descricao>");
}
if (currentRole(root) !== "colaborador") {
    fail("esta máquina não está no papel colaborador (rode /configurar). O dono cria branch só quando quer testar algo à parte, pela regra de Git do AGENTS.md.");
}
const nameError = branchNameError(branch);
if (nameError) {
    fail(`nome '${branch}' inválido: ${nameError}`);
}
// Compara conteúdo (git diff), não o git status: arquivos que o Godot regrava com outro final
// de linha aparecem no status sem nenhuma mudança real.
if (run("git", ["diff", "--quiet", "HEAD"], { cwd: root }).status !== 0) {
    fail("há mudanças sem commit. Termine ou guarde o trabalho atual antes de começar outra contribuição.");
}
if (git(["rev-parse", "--verify", "--quiet", `refs/heads/${branch}`], root) !== "") {
    fail(`a branch ${branch} já existe nesta máquina. Para continuar nela: git switch ${branch}`);
}

const fetched = run("git", ["fetch", "upstream"], { cwd: root });
if (fetched.status !== 0) {
    fail(`não consegui buscar o repositório original (git fetch upstream):\n${fetched.output.trim()}`);
}
const switched = run("git", ["switch", "--no-track", "-c", branch, "upstream/main"], { cwd: root });
if (switched.status !== 0) {
    fail(`não consegui criar a branch:\n${switched.output.trim()}`);
}

const dir = join(root, branchDir(branch));
mkdirSync(dir, { recursive: true });
const missionFile = join(dir, "missao.md");
if (!existsSync(missionFile)) {
    writeFileSync(missionFile, `# Missão da branch ${branch}

Uma branch, um propósito: o que não couber nesta missão vai para outra branch.

## Objetivo
(uma ou duas frases: o que muda para quem joga ou para o projeto)

## Inclui
- (o que esta branch entrega)

## Não inclui
- (o que fica de fora, mesmo que pareça relacionado)

## Pastas
- (pastas do projeto que a branch deve alterar, ex.: player/, test/unit/)

## Arquivos protegidos autorizados
- (nenhum)

## Estado
(atualizado no /fim: o que está feito e o que falta)

## Decisões propostas
- (nenhuma; cada uma em decisoes/<titulo>.md nesta pasta, sem número)

## Validar jogando
- (atualizado no /fim)
`, "utf8");
}
console.log(`OK: branch ${branch} criada a partir de upstream/main (${git(["rev-parse", "--short", "upstream/main"], root)})`);
console.log(`OK: missão em ${branchDir(branch)}/missao.md — preencha antes do primeiro commit`);
