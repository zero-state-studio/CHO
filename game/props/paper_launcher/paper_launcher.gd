class_name PaperLauncher
extends StaticBody3D
## Lanciatore di palline di carta: quando il personaggio giocabile (gruppo
## "player") è a portata, gli tira una pallina a parabola a intervalli regolari.

## Altezza della bocca del lanciatore, in metri.
const MUZZLE_HEIGHT: float = 1.0

## Secondi tra un lancio e l'altro.
@export var fire_interval: float = 2.0
## Distanza massima del bersaglio, in metri.
@export var fire_range: float = 11.0
## Durata del volo della pallina, in secondi: decide la parabola.
@export var flight_time: float = 0.75
## Altezza del bersaglio sul personaggio (il busto), in metri.
@export var aim_height: float = 1.1
@export var body_color: Color = Color(0.35, 0.4, 0.5)

var _cooldown: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var size := Vector3(0.6, MUZZLE_HEIGHT, 0.6)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y * 0.5
	add_child(shape)
	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.18
	cylinder.bottom_radius = 0.3
	cylinder.height = size.y
	cylinder.radial_segments = 12
	cylinder.rings = 1
	mesh_instance.mesh = cylinder
	mesh_instance.position.y = size.y * 0.5
	var material := StandardMaterial3D.new()
	material.albedo_color = body_color
	mesh_instance.material_override = material
	add_child(mesh_instance)


func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := get_tree().get_first_node_in_group(&"player") as RubberCharacter
	if target == null:
		return
	var aim_point: Vector3 = target.global_position + Vector3.UP * aim_height \
			+ target.get_planar_velocity() * flight_time
	var muzzle: Vector3 = global_position + Vector3.UP * (MUZZLE_HEIGHT + 0.15)
	if muzzle.distance_to(aim_point) > fire_range:
		return
	_cooldown = fire_interval
	var ball := PaperBall.new()
	get_parent().add_child(ball)
	ball.global_position = muzzle
	# Velocità iniziale per arrivare sul bersaglio in flight_time, con la gravità.
	var velocity: Vector3 = (aim_point - muzzle) / flight_time
	velocity.y += 0.5 * _gravity * flight_time
	ball.linear_velocity = velocity
