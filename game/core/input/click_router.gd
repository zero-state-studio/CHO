class_name ClickRouter
extends Node
## Trasforma il clic (azione "select", un solo puntatore) in un comando per il
## personaggio: su un Interactable ci va e ci interagisce; su un oggetto con
## handle_click() (i bersagli) usa la destinazione che restituisce; sul pavimento
## ci cammina.

signal destination_chosen(point: Vector3)

## Livelli fisici che il clic può colpire: mondo e oggetti interattivi.
@export_flags_3d_physics var click_mask: int = 1 | 8
## Pendenza massima, come componente verticale della normale, per considerare
## "pavimento" la superficie cliccata.
@export_range(0.0, 1.0) var min_floor_normal_y: float = 0.7

var camera: Camera3D
var character: RubberCharacter


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("select"):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or camera == null or character == null:
		return
	var hit: Dictionary = _raycast(mouse_event.position)
	if hit.is_empty():
		return
	var collider: Object = hit["collider"]
	var interactable := collider as Interactable
	if interactable:
		get_viewport().set_input_as_handled()
		interactable.highlight()
		character.interact_with(interactable)
		destination_chosen.emit(interactable.get_approach_point())
		return
	var destination: Variant = null
	if collider.has_method("handle_click"):
		destination = collider.call("handle_click")
	elif (hit["normal"] as Vector3).y >= min_floor_normal_y:
		destination = hit["position"]
	if destination == null:
		return
	get_viewport().set_input_as_handled()
	character.move_to(destination)
	destination_chosen.emit(destination)


func _raycast(screen_point: Vector2) -> Dictionary:
	var origin: Vector3 = camera.project_ray_origin(screen_point)
	var direction: Vector3 = camera.project_ray_normal(screen_point)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * camera.far, click_mask)
	# Le aree di clic degli oggetti interattivi sono Area3D.
	query.collide_with_areas = true
	return camera.get_world_3d().direct_space_state.intersect_ray(query)
