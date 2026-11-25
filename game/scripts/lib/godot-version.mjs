// Compara a versão do Godot em GODOT_PATH com a registrada em project.godot (decisão 0002).
import { existsSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { projectRoot, run } from "./common.mjs";

/**
 * Devolve { ok, message }. ok é falso quando GODOT_PATH falta, não aponta para um arquivo ou
 * a versão principal difere da do projeto (ex.: 4.8 num projeto 4.7).
 */
export function checkGodotVersion(root = projectRoot) {
    const godot = process.env.GODOT_PATH;
    if (!godot) {
        return {
            ok: false,
            message: "ERRO: GODOT_PATH não definido. Copie .env.example para .env e preencha o caminho do executável do Godot.",
        };
    }
    if (!existsSync(godot) || !statSync(godot).isFile()) {
        return {
            ok: false,
            message: `ERRO: GODOT_PATH ('${godot}') não é um arquivo. Ele deve apontar para o executável do Godot, não para a pasta.`,
        };
    }

    const project = readFileSync(join(root, "project.godot"), "utf8");
    const match = project.match(/config\/features=PackedStringArray\("(\d+\.\d+)"/);
    if (!match) {
        return { ok: true, message: "AVISO: versão do Godot não encontrada em project.godot." };
    }
    const expected = match[1];

    const { output, error } = run(godot, ["--version"], { cwd: root });
    const actual = output.trim().split(/\r?\n/).at(-1)?.trim() ?? "";   // ex.: 4.7.2.stable.steam.abc123
    if (error || actual === "") {
        return { ok: false, message: `ERRO: '${godot} --version' não retornou nada.` };
    }
    if (actual.startsWith(`${expected}.`)) {
        return { ok: true, message: `OK: Godot ${actual} (projeto: ${expected})` };
    }
    return {
        ok: false,
        message: `ERRO: Godot instalado é ${actual}, mas o projeto usa ${expected}. Não abra nem edite o projeto antes de corrigir.`,
    };
}
