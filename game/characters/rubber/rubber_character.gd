class_name RubberCharacter
extends CharacterBody3D
## Personaggio mosso col punta-e-clicca: va esattamente dove si clicca, seguendo la
## navmesh. Il corpo gommoso (RubberBody) è solo un effetto visivo sopra questo
## movimento e non ne cambia mai il risultato.

signal destination_reached

## Aspetto del personaggio: proporzioni, colori e accessori (in data/characters/).
@export var look: CharacterLook

## Velocità di camminata, in m/s.
@export var walk_speed: float = 3.5
## Accelerazione e frenata, in m/s².
@export var acceleration: float = 18.0
## Velocità con cui si gira verso la direzione di marcia, in radianti al secondo.
@export var turn_speed: float = 12.0
## Spinta data agli oggetti fisici che urta camminando.
@export var push_impulse: float = 0.6

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _has_destination: bool = false

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _body: RubberBody = $RubberBody


func _ready() -> void:
	_body.build(look)


func move_to(destination: Vector3) -> void:
	_agent.target_position = destination
	_has_destination = true


func stop() -> void:
	_has_destination = false
	_agent.target_position = global_position


## Velocità orizzontale attuale: la usano gli effetti visivi (camminata, gommosità).
func get_planar_velocity() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)


## Reazione visiva a un urto o a un crollo (vedi RubberBody.react). Il personaggio
## continua comunque verso la sua destinazione.
func react(kind: StringName, direction: Vector3, strength: float) -> void:
	_body.react(kind, direction, strength)


func get_triangle_count() -> int:
	return _body.get_triangle_count()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var desired := Vector3.ZERO
	if _has_destination:
		if _agent.is_navigation_finished():
			_has_destination = false
			destination_reached.emit()
		else:
			var next_point: Vector3 = _agent.get_next_path_position()
			var to_next := Vector3(next_point.x - global_position.x, 0.0, next_point.z - global_position.z)
			if to_next.length_squared() > 0.0001:
				desired = to_next.normalized() * walk_speed

	var planar := Vector3(velocity.x, 0.0, velocity.z).move_toward(desired, acceleration * delta)
	velocity.x = planar.x
	velocity.z = planar.z

	if planar.length_squared() > 0.01:
		var target_yaw: float = atan2(planar.x, planar.z)
		rotation.y = rotate_toward(rotation.y, target_yaw, turn_speed * delta)

	move_and_slide()
	_push_rigid_bodies()
	_body.update_motion(get_planar_velocity(), is_on_floor(), delta)


func _push_rigid_bodies() -> void:
	for index: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(index)
		var body := collision.get_collider() as RigidBody3D
		if body == null:
			continue
		var direction: Vector3 = -collision.get_normal()
		direction.y = 0.0
		body.apply_central_impulse(direction.normalized() * push_impulse)
