class_name ClickRouter
extends Node
## Trasforma il clic (azione "select", un solo puntatore) in un comando per il
## personaggio. Se colpisce un oggetto con handle_click() lo usa per avere la
## destinazione; se colpisce il pavimento ci manda il personaggio.

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
	var destination: Variant = _resolve_click(mouse_event.position)
	if destination == null:
		return
	get_viewport().set_input_as_handled()
	character.move_to(destination)
	destination_chosen.emit(destination)


func _resolve_click(screen_point: Vector2) -> Variant:
	var origin: Vector3 = camera.project_ray_origin(screen_point)
	var direction: Vector3 = camera.project_ray_normal(screen_point)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * camera.far, click_mask)
	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	var collider: Object = hit["collider"]
	if collider.has_method("handle_click"):
		return collider.call("handle_click")
	var normal: Vector3 = hit["normal"]
	if normal.y >= min_floor_normal_y:
		return hit["position"]
	return null
