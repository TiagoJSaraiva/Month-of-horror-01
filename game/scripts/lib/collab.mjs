// Regras de colaboração por fork e pull request (docs/decisoes/*-colaboracao-por-fork.md).
//
// O papel da máquina fica fora do git, em `git config projeto.papel` (dono | colaborador), e
// pode ser sobrescrito por variáveis de ambiente, como no GitHub Actions:
//   PROJETO_PAPEL   papel (dono | colaborador)
//   PROJETO_BRANCH  nome da branch (no CI o HEAD do pull request fica solto)
//   PROJETO_BASE    referência da main de origem (padrão: upstream/main ou origin/main)
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { projectRoot, run } from "./common.mjs";

export const BRANCH_PATTERN = /^(feat|fix|refactor|perf|test|docs|assets|chore)\/[a-z0-9]+(-[a-z0-9]+)*$/;
export const MAX_BRANCH_LENGTH = 50;
export const COMMIT_PATTERN = /^(feat|fix|refactor|perf|test|docs|assets|chore|merge)(\([a-z0-9-]+\))?: \S/;

// Tipos de commit aceitos em cada tipo de branch: o próprio tipo, mais testes e documentação.
// É a barreira mecânica do propósito único: uma branch fix/ não recebe feat.
export const ALLOWED_COMMITS = {
    feat: ["feat", "test", "docs", "assets"],
    fix: ["fix", "test", "docs"],
    refactor: ["refactor", "test", "docs"],
    perf: ["perf", "test", "docs"],
    test: ["test", "docs"],
    docs: ["docs"],
    assets: ["assets", "docs"],
    chore: ["chore", "docs"],
};

// Arquivos que o colaborador não altera (caminhos relativos à pasta do projeto): a memória e as
// instruções compartilhadas, as ferramentas, que rodam na máquina de quem integra, e o código de
// terceiros. A branch pode liberar algum em "Arquivos protegidos autorizados" na missão; quem
// integra revê o pedido. Fora da pasta do projeto, só notes/ é livre.
const PROTECTED = [
    /^docs\/status\.md$/,
    /^docs\/decisoes\//,
    /^docs\/branches\//,
    /^AGENTS\.md$/,
    /^CLAUDE\.md$/,
    /^GEMINI\.md$/,
    /^\.agents\//,
    /^\.claude\//,
    /^\.gemini\//,
    /^\.mcp\.json$/,
    /^scripts\//,
    /^addons\//,
    /^requirements\.txt$/,
    /^\.gitignore$/,
    /^\.editorconfig$/,
];

/** Saída de um comando git (sem a quebra de linha final), ou "" se ele falhar. */
export function git(args, cwd = projectRoot) {
    const { status, output } = run("git", args, { cwd });
    return status === 0 ? output.trim() : "";
}

/** Papel desta máquina: "dono", "colaborador" ou "" (não configurado). */
export function currentRole(root = projectRoot) {
    return process.env.PROJETO_PAPEL || git(["config", "--get", "projeto.papel"], root);
}

/** Nome da branch atual ("" com o HEAD solto). */
export function currentBranch(root = projectRoot) {
    return process.env.PROJETO_BRANCH || git(["branch", "--show-current"], root);
}

/** Referência da main de origem: upstream/main num fork, origin/main no repositório do dono. */
export function baseRef(root = projectRoot) {
    if (process.env.PROJETO_BASE) {
        return process.env.PROJETO_BASE;
    }
    return git(["remote"], root).split(/\s+/).includes("upstream") ? "upstream/main" : "origin/main";
}

/** Devolve a mensagem de erro do nome de branch, ou "" se ele for válido. */
export function branchNameError(name) {
    if (name.length > MAX_BRANCH_LENGTH) {
        return `o nome tem ${name.length} caracteres; o máximo é ${MAX_BRANCH_LENGTH}.`;
    }
    if (!BRANCH_PATTERN.test(name)) {
        return "use <tipo>/<descrição-em-kebab-case>, com tipo feat, fix, refactor, perf, test, docs, assets ou chore e só letras minúsculas sem acento, números e hífen (ex.: fix/corrige-pulo-duplo).";
    }
    return "";
}

/** Pasta da branch dentro do projeto: docs/branches/<tipo>/<descrição>. */
export const branchDir = (branch) => `docs/branches/${branch}`;

/** Itens de lista ("- item") de uma seção "## Título" da missão, sem crases. */
export function missionList(text, title) {
    const section = text.split(/\r?\n## /).find((part) => part.startsWith(title));
    if (!section) {
        return [];
    }
    return section
        .split(/\r?\n/)
        .slice(1)
        .filter((line) => /^\s*-\s+\S/.test(line))
        .map((line) => line.replace(/^\s*-\s+/, "").replaceAll("`", "").trim())
        .filter((item) => item !== "" && !item.startsWith("("));
}

/** Primeira linha de texto de uma seção da missão. */
export function missionFirstLine(text, title) {
    const section = text.split(/\r?\n## /).find((part) => part.startsWith(title));
    return section?.split(/\r?\n/).slice(1).find((line) => line.trim() !== "")?.trim() ?? "";
}

/**
 * Arquivos alterados desde a base (commits, mudanças preparadas ou não e arquivos novos), com
 * caminho relativo à raiz do repositório. `prefix` é a pasta do projeto no repositório (ex.: game/).
 */
function changedFiles(root, mergeBase) {
    const prefix = git(["rev-parse", "--show-prefix"], root);
    const top = git(["rev-parse", "--show-toplevel"], root);
    const tracked = git(["-c", "core.quotepath=off", "diff", "--name-only", mergeBase], top).split(/\r?\n/);
    const untracked = git(["-c", "core.quotepath=off", "ls-files", "--others", "--exclude-standard", "--full-name"], top).split(/\r?\n/);
    const files = [...new Set([...tracked, ...untracked])].filter((path) => path !== "");
    return { prefix, files };
}

/**
 * Verifica a branch de um colaborador. Devolve { ok, lines }: falha com branch na main, nome fora
 * do padrão, missão ausente, arquivo protegido alterado sem autorização ou commit de tipo que a
 * branch não aceita; só avisa sobre arquivos fora das pastas declaradas na missão.
 */
export function checkCollaboration(root = projectRoot) {
    const role = currentRole(root);
    if (role === "") {
        return { ok: true, lines: ["AVISO: papel desta máquina não configurado (rode /configurar). Regras de colaborador não verificadas."] };
    }
    if (role === "dono") {
        return { ok: true, lines: ["Papel: dono. Regras de colaborador não se aplicam."] };
    }
    if (role !== "colaborador") {
        return { ok: false, lines: [`Papel desconhecido: '${role}'. Use dono ou colaborador (/configurar).`] };
    }

    const branch = currentBranch(root);
    if (branch === "" || branch === "main") {
        return { ok: false, lines: ["Colaborador não trabalha na main nem com o HEAD solto. Crie a branch da tarefa com /colaborar."] };
    }
    const nameError = branchNameError(branch);
    if (nameError) {
        return { ok: false, lines: [`Branch '${branch}' fora do padrão: ${nameError}`] };
    }
    const base = baseRef(root);
    const mergeBase = git(["merge-base", "HEAD", base], root);
    if (mergeBase === "") {
        return { ok: false, lines: [`Não achei a base '${base}'. Rode git fetch upstream (ou git fetch origin).`] };
    }

    const dir = branchDir(branch);
    const missionPath = join(root, dir, "missao.md");
    if (!existsSync(missionPath)) {
        return { ok: false, lines: [`Missão da branch ausente: ${dir}/missao.md. O /colaborar a cria.`] };
    }
    const mission = readFileSync(missionPath, "utf8");
    const folders = missionList(mission, "Pastas");
    const authorized = missionList(mission, "Arquivos protegidos autorizados");

    const lines = [`Papel: colaborador | branch: ${branch} | base: ${base}`];
    const violations = [];
    const outside = [];
    const { prefix, files } = changedFiles(root, mergeBase);
    for (const file of files) {
        if (!file.startsWith(prefix)) {
            // Fora da pasta do projeto: só notes/ é livre.
            if (!file.startsWith("notes/") && !authorized.includes(`../${file}`)) {
                violations.push(`../${file}`);
            }
            continue;
        }
        const path = file.slice(prefix.length);
        if (path.startsWith(`${dir}/`)) {
            continue;
        }
        if (PROTECTED.some((pattern) => pattern.test(path))) {
            if (!authorized.includes(path)) {
                violations.push(path);
            }
            continue;
        }
        if (folders.length > 0 && !folders.some((folder) => path.startsWith(folder))) {
            outside.push(path);
        }
    }

    const allowed = ALLOWED_COMMITS[branch.split("/")[0]];
    const badCommits = [];
    for (const line of git(["log", "--no-merges", "--format=%h %s", `${mergeBase}..HEAD`], root).split(/\r?\n/).filter(Boolean)) {
        const [hash, ...rest] = line.split(" ");
        const subject = rest.join(" ");
        const type = subject.match(COMMIT_PATTERN)?.[1];
        if (!type) {
            badCommits.push(`${hash} fora do modelo <tipo>(<escopo>): <resumo>: ${subject}`);
        } else if (!allowed.includes(type)) {
            badCommits.push(`${hash} tipo '${type}' não cabe numa branch ${branch.split("/")[0]}/ (aceita: ${allowed.join(", ")}): ${subject}`);
        }
    }

    if (violations.length > 0) {
        lines.push(`Arquivos protegidos alterados sem autorização na missão (${violations.length}):`);
        violations.forEach((path) => lines.push(`  ${path}`));
        lines.push("Desfaça a mudança ou, se ela é parte da missão, liste o arquivo em \"Arquivos protegidos autorizados\" na missão; quem integra revê o pedido.");
    }
    if (badCommits.length > 0) {
        lines.push(`Commits que a branch não aceita (${badCommits.length}):`);
        badCommits.forEach((item) => lines.push(`  ${item}`));
        if (badCommits.some((item) => item.includes("não cabe numa branch"))) {
            lines.push("Uma branch tem um único propósito: o que não cabe nela vai para outra branch.");
        }
        if (badCommits.some((item) => item.includes("fora do modelo"))) {
            lines.push("Mensagens seguem o modelo da seção Git do AGENTS.md; corrija o último commit ainda não enviado com git commit --amend.");
        }
    }
    if (outside.length > 0) {
        lines.push(`AVISO: arquivos fora das pastas da missão (${outside.length}); confirme que fazem parte dela:`);
        outside.forEach((path) => lines.push(`  ${path}`));
    }
    return { ok: violations.length === 0 && badCommits.length === 0, lines };
}
