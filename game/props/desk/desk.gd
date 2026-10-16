class_name Desk
extends Interactable
## Scrivania che riceve le pratiche: si consegna solo con una pratica in mano.
## Ogni pratica consegnata si aggiunge alla pila sul piano.

signal task_received(total: int)

## Spessore di ogni pratica nella pila, in metri.
@export var task_thickness: float = 0.03
@export var task_color: Color = Color(0.98, 0.97, 0.9)
## Pratiche oltre le quali la pila non cresce più.
@export var max_pile: int = 12
## Icona che sale sopra la scrivania a pratica consegnata.
@export var task_icon: Texture2D = preload("res://assets/ui/ui_icon_task.png")

var received_tasks: int = 0


func _can_interact(character: RubberCharacter) -> bool:
	return character.is_carrying_task


func _on_completed(character: RubberCharacter) -> void:
	if not character.hand_over_task():
		return
	received_tasks += 1
	if received_tasks <= max_pile:
		_add_to_pile()
	FeedbackPop.spawn_icon(get_parent(), global_position + Vector3.UP * (footprint.y + 0.6), task_icon)
	task_received.emit(received_tasks)


func _add_to_pile() -> void:
	var sheet := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.32, task_thickness, 0.24)
	sheet.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = task_color
	sheet.material_override = material
	sheet.position = Vector3(footprint.x * 0.25, footprint.y + task_thickness * (received_tasks - 0.5), 0.0)
	sheet.rotation.y = randf_range(-0.15, 0.15)
	add_child(sheet)
