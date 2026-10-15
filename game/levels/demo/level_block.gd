@tool
class_name LevelBlock
extends StaticBody3D
## Parallelepipedo statico del livello (pavimento, pareti, scrivanie segnaposto).
## Crea da solo mesh e collisione, così si dimensiona dall'Ispettore. Se `fadeable`
## è attivo diventa trasparente quando copre il personaggio (vedi OccluderFader).

const FADE_GROUP: StringName = &"fade_occluder"

@export var size: Vector3 = Vector3(1.0, 1.0, 1.0):
	set(value):
		size = value
		_rebuild()
@export var color: Color = Color(0.85, 0.85, 0.8):
	set(value):
		color = value
		_rebuild()
@export var fadeable: bool = false
## Opacità quando il blocco copre il personaggio.
@export_range(0.0, 1.0) var faded_alpha: float = 0.2
## Durata della dissolvenza, in secondi.
@export var fade_duration: float = 0.15

var _material: StandardMaterial3D
var _mesh_instance: MeshInstance3D
var _collision_shape: CollisionShape3D
var _fade_tween: Tween
var _is_faded: bool = false


func _ready() -> void:
	_rebuild()
	if fadeable and not Engine.is_editor_hint():
		add_to_group(FADE_GROUP)


func set_faded(faded: bool) -> void:
	if faded == _is_faded or _material == null:
		return
	_is_faded = faded
	if _fade_tween:
		_fade_tween.kill()
	var target_alpha: float = faded_alpha if faded else 1.0
	# La trasparenza costa: la si attiva solo mentre il blocco non è opaco.
	if faded:
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_fade_tween = create_tween()
	_fade_tween.tween_property(_material, "albedo_color:a", target_alpha, fade_duration)
	if not faded:
		_fade_tween.tween_callback(func() -> void:
			_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		add_child(_mesh_instance)
		_collision_shape = CollisionShape3D.new()
		add_child(_collision_shape)
		_material = StandardMaterial3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	_mesh_instance.mesh = box_mesh
	_material.albedo_color = color
	_mesh_instance.material_override = _material
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	_collision_shape.shape = box_shape
