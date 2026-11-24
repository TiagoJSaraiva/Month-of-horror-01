# Run

## Propósito
Encadear as noites de uma run, avaliar cada pedido no amanhecer, contar as vidas e encerrar a run na terceira falha.

## Componentes
- `run/run_rules.gd`: `RunRules`, regras puras. Enums `Outcome` (`NONE`, `COMPLETED`, `FREE_PASS`, `FAILED`), `NoteKind` (`INTRO`, `COMPLETED`, `FREE_PASS`, `FIRST_WARNING`, `LAST_WARNING`) e `Pin` (`BLUE`, `YELLOW`, `RED`).
- `run/run_state.gd`: `RunState` (`RefCounted`), estado de uma run: `night_number`, `failures`, `free_pass_used` e `last_outcome`.
- `run/note_lines.gd` + `run/note_lines.tres`: `NoteLines` (Resource), as falas dos clientes, uma por situação.

## Regras
- 3 vidas por run (`RunState.MAX_FAILURES`). Cada pedido não cumprido custa 1 vida, e o jogo segue para a próxima noite. As falhas não precisam ser seguidas; na terceira, a run acaba e a noite não avança.
- Passe livre secreto: na primeira noite em que falta **exatamente 1** peixe, a noite conta como cumprida (`FREE_PASS`) e não custa vida. Só vale uma vez por run.
- Bilhete do início da noite, a partir do resultado da noite anterior:
  - noite 1: abertura, alfinete azul;
  - cumpriu: azul;
  - passe livre: azul, com a fala própria;
  - falhou, com 1 falha somada: amarelo "!";
  - falhou, com 2 falhas somadas: vermelho "!!".
- Se a última noite foi cumprida, o alfinete é azul mesmo com falhas antigas.

## Sinais
Nenhum ainda.

## Testes
- `test/unit/run_rules_test.gd`: avaliação com 0, 1 e 2 peixes faltando, com e sem passe; bilhete e alfinete de cada situação; `NoteLines.text_for`.
- `test/unit/run_state_test.gd`: início, noite cumprida, passe livre único e sem custo, 3 falhas fora de sequência encerram a run, noite não avança no fim e último resultado guardado.
