class_name IsoCamera
extends Node3D
## Telecamera isometrica ortogonale fissa (niente rotazione), che segue il
## personaggio. Zoom con la rotella (azioni zoom_in e zoom_out) o con i pulsanti
## +/− dell'HUD, che chiamano zoom_in() e zoom_out().

signal zoom_changed(zoom_size: float)

## Inclinazione verso il basso, in gradi.
@export_range(10.0, 80.0) var pitch_degrees: float = 35.0
## Rotazione attorno all'asse verticale, in gradi.
@export var yaw_degrees: float = 45.0
## Distanza della telecamera dal punto seguito: con la proiezione ortogonale non
## cambia l'inquadratura, basta che stia fuori dalle pareti.
@export var distance: float = 40.0
## Altezza visibile in metri: più è piccola, più l'inquadratura è vicina.
@export var zoom_size: float = 14.0
@export var zoom_min: float = 6.0
@export var zoom_max: float = 26.0
@export var zoom_step: float = 2.0
## Quanto in fretta raggiunge il personaggio: più è alto, più è rigida.
@export var follow_sharpness: float = 6.0

var target: Node3D

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	rotation = Vector3(deg_to_rad(-pitch_degrees), deg_to_rad(yaw_degrees), 0.0)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position = Vector3(0.0, 0.0, distance)
	camera.far = distance * 2.5
	set_zoom(zoom_size)
	if target:
		global_position = target.global_position


func set_zoom(size: float) -> void:
	zoom_size = clampf(size, zoom_min, zoom_max)
	camera.size = zoom_size
	zoom_changed.emit(zoom_size)


func zoom_in() -> void:
	set_zoom(zoom_size - zoom_step)


func zoom_out() -> void:
	set_zoom(zoom_size + zoom_step)


## Sposta subito la telecamera sul personaggio, senza inseguimento.
func snap_to_target() -> void:
	if target:
		global_position = target.global_position


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom_in()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("zoom_out"):
		zoom_out()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if target == null:
		return
	var weight: float = 1.0 - exp(-follow_sharpness * delta)
	global_position = global_position.lerp(target.global_position, weight)
