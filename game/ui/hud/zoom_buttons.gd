class_name ZoomButtons
extends HBoxContainer
## Pulsanti + e − per lo zoom: l'alternativa a un dito alla rotella (e, più avanti,
## al pizzico).

signal zoom_in_pressed
signal zoom_out_pressed


func _ready() -> void:
	$ZoomOut.pressed.connect(zoom_out_pressed.emit)
	$ZoomIn.pressed.connect(zoom_in_pressed.emit)
