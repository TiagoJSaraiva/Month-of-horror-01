// Funções compartilhadas pelos scripts de verificação. Só módulos nativos do Node (mínimo: 18),
// para rodar igual no Windows e no Linux sem npm install.
import { spawnSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

/** Pasta do projeto Godot (a que tem project.godot). */
export const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");

export const isWindows = process.platform === "win32";

/**
 * Carrega o .env da raiz do projeto. Uma variável já definida no ambiente vale mais que o
 * .env, para quem preferir configurá-la no sistema.
 */
export function loadEnv(root = projectRoot) {
    const file = join(root, ".env");
    if (!existsSync(file)) {
        return;
    }
    for (const raw of readFileSync(file, "utf8").split(/\r?\n/)) {
        const line = raw.trim();
        if (line === "" || line.startsWith("#")) {
            continue;
        }
        const equals = line.indexOf("=");
        if (equals < 1) {
            continue;
        }
        const key = line.slice(0, equals).trim();
        let value = line.slice(equals + 1).trim();
        const quoted = value.length >= 2 && (value[0] === '"' || value[0] === "'") && value.at(-1) === value[0];
        if (quoted) {
            value = value.slice(1, -1);
        }
        if (!process.env[key]) {
            process.env[key] = value;
        }
    }
}

/** Lê um arquivo de texto como linhas, sem BOM e aceitando LF ou CRLF. */
export function readLines(path) {
    const text = readFileSync(path, "utf8").replace(/^﻿/, "");
    const lines = text.split(/\r?\n/);
    // Um arquivo terminado em quebra de linha não tem uma última linha vazia de verdade.
    if (lines.length > 0 && lines.at(-1) === "") {
        lines.pop();
    }
    return lines;
}

/** Caminho relativo à raiz, sempre com "/" (o mesmo formato do git e do res://). */
export function toProjectPath(absolutePath, root = projectRoot) {
    return relative(root, absolutePath).split(sep).join("/");
}

/**
 * Scripts .gd do projeto, como caminhos relativos com "/". Pula addons de terceiros e pastas
 * ocultas (.godot, .git...). `exclude` recebe prefixos extras a pular (ex.: "test/").
 */
export function listGdFiles(root = projectRoot, exclude = []) {
    const result = [];
    const walk = (dir) => {
        for (const entry of readdirSync(dir, { withFileTypes: true })) {
            if (entry.name.startsWith(".")) {
                continue;
            }
            const full = join(dir, entry.name);
            if (entry.isDirectory()) {
                if (entry.name !== "addons") {
                    walk(full);
                }
            } else if (entry.name.endsWith(".gd")) {
                const path = toProjectPath(full, root);
                if (!exclude.some((prefix) => path.startsWith(prefix))) {
                    result.push(path);
                }
            }
        }
    };
    walk(root);
    return result.sort();
}

/**
 * Executa um programa e devolve { status, output }. `shell` só é preciso no Windows para
 * .cmd (ex.: npx), que o Node não executa diretamente.
 */
export function run(command, args, options = {}) {
    const result = spawnSync(command, args, {
        cwd: options.cwd ?? projectRoot,
        encoding: "utf8",
        env: options.env ?? process.env,
        shell: options.shell ?? false,
        stdio: options.inherit ? "inherit" : "pipe",
        maxBuffer: 64 * 1024 * 1024,
    });
    if (result.error) {
        return { status: null, output: "", error: result.error };
    }
    const output = options.inherit ? "" : `${result.stdout ?? ""}${result.stderr ?? ""}`;
    return { status: result.status, output };
}

/** Divide uma lista em blocos, para não estourar o limite de linha de comando do Windows. */
export function chunks(items, size = 100) {
    const result = [];
    for (let i = 0; i < items.length; i += size) {
        result.push(items.slice(i, i + size));
    }
    return result;
}

const colors = { red: 31, green: 32, yellow: 33, cyan: 36, gray: 90 };

/** Texto colorido no terminal (ignorado quando a saída não é um terminal). */
export function paint(color, text) {
    if (!process.stdout.isTTY) {
        return text;
    }
    return `\u001b[${colors[color]}m${text}\u001b[0m`;
}
