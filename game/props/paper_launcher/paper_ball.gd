class_name PaperBall
extends RigidBody3D
## Pallina di carta: se colpisce un personaggio lo fa reagire (una volta sola),
## poi rimbalza e sparisce dopo qualche secondo.

@export var radius: float = 0.09
@export var lifetime: float = 4.0
## Forza della reazione del personaggio colpito (0-1).
@export var hit_strength: float = 0.6
@export var color: Color = Color(0.96, 0.96, 0.92)

var _has_hit: bool = false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 1 | 2 | 4
	mass = 0.05
	contact_monitor = true
	max_contacts_reported = 2
	var shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = radius
	shape.shape = sphere_shape
	add_child(shape)
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 8
	sphere.rings = 4
	mesh_instance.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	add_child(mesh_instance)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime, false).timeout.connect(queue_free)


func _on_body_entered(body: Node) -> void:
	if _has_hit:
		return
	var character := body as RubberCharacter
	if character == null:
		return
	_has_hit = true
	var direction: Vector3 = linear_velocity
	direction.y = 0.0
	character.react(RubberBody.REACTION_HIT, direction.normalized(), hit_strength)
