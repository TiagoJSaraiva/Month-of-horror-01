// Confere a versão do Godot. Roda no hook de início do Claude Code e no fluxo inicio.
// Uso: node scripts/check-godot-version.mjs   (exit 0 = ok; 1 = problema)
import { loadEnv } from "./lib/common.mjs";
import { checkGodotVersion } from "./lib/godot-version.mjs";

loadEnv();
const { ok, message } = checkGodotVersion();
console.log(message);
process.exit(ok ? 0 : 1);
