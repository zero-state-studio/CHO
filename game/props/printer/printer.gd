class_name Printer
extends Interactable
## Stampante: dopo la stampa il personaggio prende una pratica. Solo a mani libere.


func _can_interact(character: RubberCharacter) -> bool:
	return not character.is_carrying_task


## Icona che sale sopra il personaggio quando prende la pratica.
@export var task_icon: Texture2D = preload("res://assets/ui/ui_icon_task.png")
## Altezza dell'icona sopra i piedi del personaggio, in metri.
@export var icon_height: float = 2.0


func _on_completed(character: RubberCharacter) -> void:
	if character.pick_up_task():
		FeedbackPop.spawn_icon(get_parent(), character.global_position + Vector3.UP * icon_height, task_icon)
