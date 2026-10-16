class_name CoffeeMachine
extends Interactable
## Macchinetta del caffè: alla fine sopra il personaggio compare una tazzina.
## (L'Energia arriverà con il livello Junior.)

signal coffee_served(character: RubberCharacter)

## Icona che sale sopra il personaggio a caffè pronto.
@export var coffee_icon: Texture2D = preload("res://assets/ui/ui_icon_coffee.png")
## Altezza dell'icona sopra i piedi del personaggio, in metri.
@export var icon_height: float = 2.0


func _on_completed(character: RubberCharacter) -> void:
	FeedbackPop.spawn_icon(get_parent(), character.global_position + Vector3.UP * icon_height, coffee_icon)
	coffee_served.emit(character)
