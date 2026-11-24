class_name NoteLines
extends Resource
## Falas dos clientes no bilhete da mesa e no fim da run. No MVP há uma fala por situação;
## o pool de falas variadas fica para depois.

@export_multiline var intro: String
@export_multiline var completed: String
@export_multiline var free_pass: String
@export_multiline var first_warning: String
@export_multiline var last_warning: String
@export_multiline var run_over: String
## Fala do fim de run quando o jogador morre.
@export_multiline var death: String


func text_for(kind: RunRules.NoteKind) -> String:
	match kind:
		RunRules.NoteKind.COMPLETED:
			return completed
		RunRules.NoteKind.FREE_PASS:
			return free_pass
		RunRules.NoteKind.FIRST_WARNING:
			return first_warning
		RunRules.NoteKind.LAST_WARNING:
			return last_warning
	return intro
