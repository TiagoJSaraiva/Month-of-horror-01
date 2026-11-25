// Confere o ## das funções alteradas e confirma os que continuam corretos (docs/decisoes/*-documentacao-em-toda-funcao.md).
// Uso: node scripts/check-doc-review.mjs [--reviewed "player/player.gd::jump,player/player.gd::land"]
import { checkDocReview } from "./lib/docs.mjs";

const args = process.argv.slice(2);
const reviewed = [];
for (let i = 0; i < args.length; i++) {
    if (args[i] === "--reviewed" && i + 1 < args.length) {
        reviewed.push(args[++i]);
    } else {
        console.log(`Argumento desconhecido: ${args[i]}`);
        process.exit(1);
    }
}

const { ok, lines } = checkDocReview(undefined, reviewed);
lines.forEach((line) => console.log(line));
process.exit(ok ? 0 : 1);
