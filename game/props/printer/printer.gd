class_name Printer
extends Interactable
## Stampante: dopo la stampa il personaggio prende una pratica. Solo a mani libere.


func _can_interact(character: RubberCharacter) -> bool:
	return not character.is_carrying_task


func _on_completed(character: RubberCharacter) -> void:
	character.pick_up_task()
