class_name PhysicsProp
extends RigidBody3D
## Oggetto fisico da urtare: scatola, sedia o sedia girevole. Forme di collisione
## semplici create da codice; il modello si cambia con model_scene (per esempio
## un .glb di Meshy) senza toccare la fisica.

enum Kind { BOX, CHAIR, SWIVEL_CHAIR }

## [dimensioni, posizione] delle parti di sedie e sedie girevoli.
const CHAIR_PARTS: Array = [
	[Vector3(0.46, 0.07, 0.46), Vector3(0.0, 0.45, 0.0)],
	[Vector3(0.46, 0.5, 0.06), Vector3(0.0, 0.73, -0.2)],
	[Vector3(0.4, 0.42, 0.4), Vector3(0.0, 0.21, 0.0)],
]
const SWIVEL_PARTS: Array = [
	[Vector3(0.5, 0.08, 0.5), Vector3(0.0, 0.48, 0.0)],
	[Vector3(0.5, 0.55, 0.07), Vector3(0.0, 0.8, -0.22)],
	[Vector3(0.08, 0.4, 0.08), Vector3(0.0, 0.24, 0.0)],
	[Vector3(0.6, 0.05, 0.6), Vector3(0.0, 0.025, 0.0)],
]

@export var kind: Kind = Kind.BOX
## Dimensioni della scatola (solo per Kind.BOX).
@export var box_size: Vector3 = Vector3(0.6, 0.6, 0.6)
@export var color: Color = Color(0.78, 0.62, 0.42)
## Attrito con il pavimento: basso per la sedia girevole, che scivola e gira.
@export_range(0.0, 1.0) var friction: float = 0.8
@export var model_scene: PackedScene
@export var model_scale: float = 1.0



func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2 | 4 | 16
	var physics_material := PhysicsMaterial.new()
	physics_material.friction = friction
	physics_material_override = physics_material
	var parts: Array = _parts()
	for part: Array in parts:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = part[0]
		shape.shape = box
		shape.position = part[1]
		add_child(shape)
	if model_scene:
		var model := model_scene.instantiate() as Node3D
		model.scale = Vector3.ONE * model_scale
		add_child(model)
		ModelFit.ground(model)
	else:
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		for part: Array in parts:
			var mesh_instance := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = part[0]
			mesh_instance.mesh = mesh
			mesh_instance.position = part[1]
			mesh_instance.material_override = material
			add_child(mesh_instance)


func _parts() -> Array:
	match kind:
		Kind.CHAIR:
			return CHAIR_PARTS
		Kind.SWIVEL_CHAIR:
			return SWIVEL_PARTS
	return [[box_size, Vector3(0.0, box_size.y * 0.5, 0.0)]]
