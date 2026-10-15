class_name CoffeeMachine
extends Interactable
## Macchinetta del caffè: alla fine sopra il personaggio compare una tazzina.
## (L'Energia arriverà con il livello Junior.)

signal coffee_served(character: RubberCharacter)

## Colore della tazzina che sale sopra il personaggio.
@export var cup_color: Color = Color(0.45, 0.28, 0.15)
## Altezza dell'icona sopra i piedi del personaggio, in metri.
@export var icon_height: float = 2.0


func _on_completed(character: RubberCharacter) -> void:
	var cup := CylinderMesh.new()
	cup.top_radius = 0.12
	cup.bottom_radius = 0.09
	cup.height = 0.18
	cup.radial_segments = 12
	cup.rings = 1
	FeedbackPop.spawn(get_parent(), character.global_position + Vector3.UP * icon_height, cup, cup_color)
	coffee_served.emit(character)
