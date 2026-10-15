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
## Texture ripetibile (moquette, intonaco...), proiettata nel mondo: si ripete alla
## stessa scala su blocchi di qualunque dimensione. Il colore la tinge.
@export var texture: Texture2D:
	set(value):
		texture = value
		_rebuild()
## Quanti metri copre una ripetizione della texture.
@export var texture_meters: float = 2.0:
	set(value):
		texture_meters = value
		_rebuild()
## Modello da mostrare al posto del parallelepipedo (per esempio un .glb di Meshy).
## La collisione resta la scatola di dimensioni `size`; il modello ha l'origine a terra,
## al centro della scatola.
@export var model_scene: PackedScene:
	set(value):
		model_scene = value
		_rebuild()
@export var model_scale: float = 1.0:
	set(value):
		model_scale = value
		_rebuild()
## Rotazione del modello attorno all'asse verticale, in gradi.
@export var model_yaw_degrees: float = 0.0:
	set(value):
		model_yaw_degrees = value
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
var _model: Node3D
var _model_meshes: Array[GeometryInstance3D] = []


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
	_fade_tween = create_tween()
	if _model:
		# Modello importato: la trasparenza per istanza non tocca i suoi materiali.
		for mesh: GeometryInstance3D in _model_meshes:
			_fade_tween.parallel().tween_property(mesh, "transparency", 1.0 - target_alpha, fade_duration)
		return
	# La trasparenza costa: la si attiva solo mentre il blocco non è opaco.
	if faded:
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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
	_material.albedo_texture = texture
	_material.uv1_triplanar = texture != null
	_material.uv1_world_triplanar = texture != null
	_material.uv1_scale = Vector3.ONE / maxf(texture_meters, 0.01)
	_mesh_instance.material_override = _material
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	_collision_shape.shape = box_shape
	_rebuild_model()


func _rebuild_model() -> void:
	if _model:
		_model.queue_free()
		_model = null
		_model_meshes.clear()
	_mesh_instance.visible = model_scene == null
	if model_scene == null:
		return
	_model = model_scene.instantiate() as Node3D
	_model.scale = Vector3.ONE * model_scale
	_model.rotation.y = deg_to_rad(model_yaw_degrees)
	add_child(_model)
	# Il modello poggia sul fondo della scatola (l'origine del blocco è al centro).
	ModelFit.ground(_model, -size.y * 0.5)
	for node: Node in _model.find_children("*", "GeometryInstance3D", true, false):
		_model_meshes.append(node as GeometryInstance3D)
