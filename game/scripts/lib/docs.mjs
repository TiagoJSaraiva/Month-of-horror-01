// Regras de documentação das funções (docs/decisoes/*-documentacao-em-toda-funcao.md):
// - checkDocs: toda função do jogo tem ## logo acima dela;
// - checkDocReview: função alterada em relação ao HEAD tem o ## alterado ou confirmado.
import { createHash } from "node:crypto";
import { existsSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { listGdFiles, projectRoot, readLines, run } from "./common.mjs";

const FUNC_PATTERN = /^(\s*)(?:static\s+)?func\s+(\w+)/;
const DOC_PATTERN = /^\s*##/;
const HUNK_PATTERN = /^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/;
// Pastas fora da regra: testes já se descrevem pelo nome test_<comportamento>.
const EXCLUDED = /^(addons|\.godot|test)\//;
const REVIEW_FILE = ".doc-review";

/** Devolve { ok, lines } com as funções sem ## logo acima, fora de test/ e addons/. */
export function checkDocs(root = projectRoot) {
    const missing = [];
    for (const path of listGdFiles(root, ["test/"])) {
        const lines = readLines(join(root, path));
        lines.forEach((line, i) => {
            if (FUNC_PATTERN.test(line) && (i === 0 || !DOC_PATTERN.test(lines[i - 1]))) {
                missing.push(`  ${path}:${i + 1}: ${line.trim()}`);
            }
        });
    }
    if (missing.length > 0) {
        return { ok: false, lines: [`Funções sem ## logo acima (${missing.length}):`, ...missing] };
    }
    return { ok: true, lines: ["Toda função do jogo tem ##."] };
}

const indentOf = (line) => line.length - line.trimStart().length;

/**
 * Linhas do arquivo atual (1 = primeira) tocadas pelo diff com o HEAD. Uma remoção marca a
 * linha que ficou logo antes dela, para contar como mudança da função onde aconteceu.
 */
function changedLines(root, path) {
    const changed = new Set();
    const { output } = run("git", ["-c", "core.quotepath=off", "diff", "-U0", "HEAD", "--", path], { cwd: root });
    for (const line of output.split(/\r?\n/)) {
        const match = line.match(HUNK_PATTERN);
        if (!match) {
            continue;
        }
        const start = Number(match[1]);
        const count = match[2] === undefined ? 1 : Number(match[2]);
        if (count === 0) {
            changed.add(Math.max(start, 1));
            continue;
        }
        for (let n = start; n < start + count; n++) {
            changed.add(n);
        }
    }
    return changed;
}

const bodyHash = (lines) =>
    createHash("sha256").update(lines.join("\n"), "utf8").digest("hex").toUpperCase();

/** Funções de um arquivo versionado cuja assinatura ou corpo mudou e cujo ## não mudou. */
function pendingFunctions(root, path) {
    const result = [];
    const changed = changedLines(root, path);
    if (changed.size === 0) {
        return result;
    }
    const lines = readLines(join(root, path));
    for (let i = 0; i < lines.length; i++) {
        const match = lines[i].match(FUNC_PATTERN);
        if (!match) {
            continue;
        }
        const indent = indentOf(lines[i]);
        // O corpo vai até a próxima linha não vazia com indentação igual ou menor.
        let bodyEnd = i;
        for (let j = i + 1; j < lines.length; j++) {
            if (lines[j].trim() === "") {
                continue;
            }
            if (indentOf(lines[j]) <= indent) {
                break;
            }
            bodyEnd = j;
        }
        let docStart = i;
        while (docStart > 0 && DOC_PATTERN.test(lines[docStart - 1])) {
            docStart--;
        }
        let functionChanged = false;
        for (let n = i + 1; n <= bodyEnd + 1; n++) {
            functionChanged ||= changed.has(n);
        }
        let docChanged = false;
        for (let n = docStart + 1; n <= i; n++) {
            docChanged ||= changed.has(n);
        }
        if (functionChanged && !docChanged) {
            result.push({
                key: `${path}::${match[2]}`,
                line: i + 1,
                hash: bodyHash(lines.slice(i, bodyEnd + 1)),
                doc: lines.slice(docStart, i),
            });
        }
    }
    return result;
}

/**
 * Devolve { ok, lines }. `reviewed` são chaves "<arquivo>::<função>" cujo ## foi revisado e
 * continua correto: o hash do corpo atual vai para .doc-review (ignorado pelo git), e mexer
 * de novo na função invalida a confirmação. Arquivos novos ficam de fora: o ## deles já é
 * exigido por checkDocs.
 */
export function checkDocReview(root = projectRoot, reviewed = []) {
    const keys = reviewed
        .flatMap((item) => item.split(","))
        .map((item) => item.trim().replaceAll("\\", "/"))
        .filter((item) => item !== "");
    const reviewFile = join(root, REVIEW_FILE);

    const { output } = run("git", ["-c", "core.quotepath=off", "diff", "--name-only", "--relative", "HEAD", "--", "*.gd"], { cwd: root });
    const paths = output
        .split(/\r?\n/)
        .map((path) => path.trim())
        .filter((path) => path !== "" && !EXCLUDED.test(path) && existsSync(join(root, path)));
    const pending = paths.flatMap((path) => pendingFunctions(root, path));

    const confirmed = new Set();
    if (existsSync(reviewFile)) {
        for (const entry of readLines(reviewFile)) {
            if (entry.trim() !== "") {
                confirmed.add(entry.trim());
            }
        }
    }

    const invalid = [];
    for (const key of keys) {
        const matching = pending.filter((fn) => fn.key === key);
        if (matching.length === 0) {
            invalid.push(key);
        }
        for (const fn of matching) {
            confirmed.add(`${fn.key} ${fn.hash}`);
        }
    }

    // Só ficam as confirmações que ainda valem para o diff atual.
    const stillValid = [];
    const unreviewed = [];
    const reviewedNow = [];
    for (const fn of pending) {
        const entry = `${fn.key} ${fn.hash}`;
        if (confirmed.has(entry)) {
            stillValid.push(entry);
            reviewedNow.push(fn.key);
        } else {
            unreviewed.push(fn);
        }
    }
    if (stillValid.length > 0) {
        writeFileSync(reviewFile, `${[...new Set(stillValid)].sort().join("\n")}\n`, "utf8");
    } else if (existsSync(reviewFile)) {
        rmSync(reviewFile);
    }

    const lines = [];
    if (invalid.length > 0) {
        lines.push(`Não são funções alteradas com o ## pendente: ${invalid.join(", ")}`);
    }
    if (unreviewed.length > 0) {
        lines.push(`Funções alteradas com o ## sem revisão (${unreviewed.length}):`);
        for (const fn of unreviewed) {
            lines.push(`  ${fn.key} (linha ${fn.line})`);
            for (const docLine of fn.doc) {
                lines.push(`      ${docLine.trim()}`);
            }
        }
        lines.push("Atualize o ## ou, se ele continua correto, confirme com:");
        const pendingKeys = [...new Set(unreviewed.map((fn) => fn.key))].sort().join(",");
        lines.push(`  node scripts/check-doc-review.mjs --reviewed "${pendingKeys}"`);
    }
    if (lines.length > 0) {
        return { ok: false, lines };
    }
    if (reviewedNow.length > 0) {
        lines.push(`## confirmados sem mudança: ${[...new Set(reviewedNow)].sort().join(", ")}`);
    }
    lines.push("Toda função alterada tem o ## revisado.");
    return { ok: true, lines };
}
