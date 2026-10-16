class_name RubberCharacter
extends CharacterBody3D
## Personaggio mosso col punta-e-clicca: va esattamente dove si clicca, seguendo la
## navmesh. Il corpo gommoso (RubberBody) è solo un effetto visivo sopra questo
## movimento e non ne cambia mai il risultato.

signal destination_reached
signal task_picked_up
signal task_delivered

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

## Il personaggio ha in mano una pratica (ne porta una alla volta).
var is_carrying_task: bool = false

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _has_destination: bool = false
var _pending_interactable: Interactable
var _active_interactable: Interactable

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _body: RubberBody = $RubberBody
@onready var _progress_bar: ProgressBar3D = $ProgressBar3D
@onready var _carried_task: Node3D = $CarriedTask


func _ready() -> void:
	_body.build(look)


## Va al punto indicato. Un nuovo comando annulla l'azione in corso.
func move_to(destination: Vector3) -> void:
	_cancel_interaction()
	_pending_interactable = null
	_agent.target_position = destination
	_has_destination = true


## Va all'oggetto e, appena arrivato, ci interagisce.
func interact_with(target: Interactable) -> void:
	move_to(target.get_approach_point())
	_pending_interactable = target


func stop() -> void:
	_cancel_interaction()
	_pending_interactable = null
	_has_destination = false
	_agent.target_position = global_position


func is_busy() -> bool:
	return _active_interactable != null


## Chiamata dall'oggetto quando l'azione finisce da sola.
func notify_interaction_ended(target: Interactable) -> void:
	if _active_interactable == target:
		_active_interactable = null


func show_progress(value: float) -> void:
	_progress_bar.set_progress(value)


func hide_progress() -> void:
	_progress_bar.visible = false


## Prende una pratica, se ha le mani libere.
func pick_up_task() -> bool:
	if is_carrying_task:
		return false
	is_carrying_task = true
	_carried_task.visible = true
	task_picked_up.emit()
	return true


## Consegna la pratica che ha in mano.
func hand_over_task() -> bool:
	if not is_carrying_task:
		return false
	is_carrying_task = false
	_carried_task.visible = false
	task_delivered.emit()
	return true


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
			_start_pending_interaction()
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


func _start_pending_interaction() -> void:
	if _pending_interactable == null:
		return
	var target: Interactable = _pending_interactable
	_pending_interactable = null
	if not is_instance_valid(target):
		return
	var to_target: Vector3 = target.global_position - global_position
	if Vector2(to_target.x, to_target.z).length_squared() > 0.0001:
		rotation.y = atan2(to_target.x, to_target.z)
	_active_interactable = target
	if not target.start_interaction(self):
		_active_interactable = null


func _cancel_interaction() -> void:
	if _active_interactable == null:
		return
	var target: Interactable = _active_interactable
	_active_interactable = null
	if is_instance_valid(target):
		target.cancel_interaction(self)


func _push_rigid_bodies() -> void:
	for index: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(index)
		var body := collision.get_collider() as RigidBody3D
		if body == null:
			continue
		var direction: Vector3 = -collision.get_normal()
		direction.y = 0.0
		body.apply_central_impulse(direction.normalized() * push_impulse)
