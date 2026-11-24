class_name RunRules
extends RefCounted
## Regras puras da run: o resultado de cada noite e qual bilhete aparece na mesa.

enum Outcome { NONE, COMPLETED, FREE_PASS, FAILED }
enum NoteKind { INTRO, COMPLETED, FREE_PASS, FIRST_WARNING, LAST_WARNING }
enum Pin { BLUE, YELLOW, RED }


## Avalia o pedido no amanhecer. Faltando exatamente 1 peixe, o passe livre secreto salva a
## noite, se ainda estiver disponível.
static func evaluate_night(missing_fish: int, free_pass_available: bool) -> Outcome:
	if missing_fish <= 0:
		return Outcome.COMPLETED
	if missing_fish == 1 and free_pass_available:
		return Outcome.FREE_PASS
	return Outcome.FAILED


## Bilhete do início da noite, a partir do resultado da noite anterior e das falhas somadas.
static func note_kind(last_outcome: Outcome, failures: int) -> NoteKind:
	match last_outcome:
		Outcome.COMPLETED:
			return NoteKind.COMPLETED
		Outcome.FREE_PASS:
			return NoteKind.FREE_PASS
		Outcome.FAILED:
			return NoteKind.FIRST_WARNING if failures <= 1 else NoteKind.LAST_WARNING
	return NoteKind.INTRO


## O alfinete mostra o resultado da noite anterior: azul quando não houve vida perdida.
static func pin_for(kind: NoteKind) -> Pin:
	match kind:
		NoteKind.FIRST_WARNING:
			return Pin.YELLOW
		NoteKind.LAST_WARNING:
			return Pin.RED
	return Pin.BLUE


## Noites que o jogador sobreviveu. Na morte, a noite em que ele morreu não conta.
static func nights_survived(night_number: int, died: bool) -> int:
	return maxi(night_number - 1, 0) if died else night_number
