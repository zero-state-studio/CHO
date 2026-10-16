@tool
class_name LevelStairs
extends StaticBody3D
## Scala di pochi gradini. Si vedono i gradini, ma la collisione è una rampa liscia:
## il personaggio sale senza incastrarsi e la navigazione la tratta come un pendio.
## L'origine è al centro del primo gradino, a terra; la scala sale verso -Z.

@export_range(1, 10) var step_count: int = 3:
	set(value):
		step_count = value
		_rebuild()
@export var step_height: float = 0.15:
	set(value):
		step_height = value
		_rebuild()
@export var step_depth: float = 0.4:
	set(value):
		step_depth = value
		_rebuild()
@export var width: float = 2.0:
	set(value):
		width = value
		_rebuild()
@export var color: Color = Color(0.7, 0.7, 0.75):
	set(value):
		color = value
		_rebuild()

var _parts: Array[Node3D] = []
var _steps: Array[MeshInstance3D] = []


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		add_to_group(MeshBatcher.BATCHABLE_GROUP)


## Chiamata dal MeshBatcher: i gradini si disegnano insieme ai blocchi uguali.
func batch_meshes(batcher: MeshBatcher) -> void:
	for step: MeshInstance3D in _steps:
		batcher.add(step)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	for part: Node3D in _parts:
		part.queue_free()
	_parts.clear()
	_steps.clear()

	# Stesso cubo e stesso materiale dei LevelBlock, così finiscono nello stesso gruppo.
	var material: StandardMaterial3D = LevelBlock.shared_material(color, null, 1.0)
	for step_index: int in step_count:
		var height: float = step_height * (step_index + 1)
		var step := MeshInstance3D.new()
		step.mesh = LevelBlock.unit_box()
		step.scale = Vector3(width, height, step_depth)
		step.material_override = material
		step.position = Vector3(0.0, height * 0.5, -step_depth * step_index)
		_add_part(step)
		_steps.append(step)

	# Rampa: dal bordo anteriore del primo gradino (a terra) al bordo posteriore
	# dell'ultimo (in cima).
	var total_height: float = step_height * step_count
	var run: float = step_depth * step_count
	var slope_length: float = Vector2(run, total_height).length()
	var ramp_shape := BoxShape3D.new()
	var ramp_thickness: float = 0.1
	ramp_shape.size = Vector3(width, ramp_thickness, slope_length)
	var ramp := CollisionShape3D.new()
	ramp.shape = ramp_shape
	var angle: float = atan2(total_height, run)
	ramp.rotation = Vector3(angle, 0.0, 0.0)
	var start := Vector3(0.0, 0.0, step_depth * 0.5)
	var end := Vector3(0.0, total_height, step_depth * 0.5 - run)
	# Abbassa la rampa di metà spessore lungo la sua normale, così la superficie
	# superiore passa esattamente per i due bordi.
	var normal: Vector3 = ramp.basis.y
	ramp.position = (start + end) * 0.5 - normal * ramp_thickness * 0.5
	_add_part(ramp)


func _add_part(part: Node3D) -> void:
	add_child(part)
	_parts.append(part)
