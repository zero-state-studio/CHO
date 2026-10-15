class_name CollapseButton
extends Interactable
## Pulsante "crollo", sul pavimento: il personaggio ci sale sopra e crolla (stress al massimo), poi
## si rialza. Con gommosità sopra 1 il crollo usa anche il ragdoll.

## Forza della reazione di crollo (0-1).
@export var collapse_strength: float = 1.0


func _on_completed(character: RubberCharacter) -> void:
	character.react(RubberBody.REACTION_COLLAPSE, Vector3.DOWN, collapse_strength)
