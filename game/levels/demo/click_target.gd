@tool
class_name ClickTarget
extends StaticBody3D
## Bersaglio rotondo sul pavimento, per provare la precisione del clic.
## Al clic si illumina e il personaggio ci cammina sopra. L'area cliccabile è
## grande quanto il disco: serve proprio a misurare i bersagli piccoli.

signal clicked(target: ClickTarget)

const DISC_HEIGHT: float = 0.04

@export var radius: float = 0.5:
	set(value):
		radius = value
		_rebuild()
@export var idle_color: Color = Color(0.95, 0.75, 0.2):
	set(value):
		idle_color = value
		_rebuild()
@export var lit_color: Color = Color(0.2, 0.9, 0.4)
## Per quanto resta illuminato dopo il clic, in secondi.
@export var lit_duration: float = 1.0

var _material: StandardMaterial3D
var _mesh_instance: MeshInstance3D
var _collision_shape: CollisionShape3D
var _lit_tween: Tween


func _ready() -> void:
	_rebuild()


## Chiamata dal ClickRouter: restituisce il punto dove il personaggio deve andare.
func handle_click() -> Vector3:
	clicked.emit(self)
	if _lit_tween:
		_lit_tween.kill()
	_material.albedo_color = lit_color
	_lit_tween = create_tween()
	_lit_tween.tween_interval(lit_duration)
	_lit_tween.tween_property(_material, "albedo_color", idle_color, 0.3)
	return global_position


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		add_child(_mesh_instance)
		_collision_shape = CollisionShape3D.new()
		add_child(_collision_shape)
		_material = StandardMaterial3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = DISC_HEIGHT
	disc.radial_segments = 24
	disc.rings = 1
	_mesh_instance.mesh = disc
	_mesh_instance.position.y = DISC_HEIGHT * 0.5
	_material.albedo_color = idle_color
	_mesh_instance.material_override = _material
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = DISC_HEIGHT
	_collision_shape.shape = shape
	_collision_shape.position.y = DISC_HEIGHT * 0.5
