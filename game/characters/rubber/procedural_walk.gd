class_name ProceduralWalk
extends SkeletonModifier3D
## Camminata dondolante procedurale, senza animazioni fatte a mano: gambe e braccia
## a pendolo, bacino che ondeggia e rimbalza, busto che si inclina in avanti con la
## velocità. Gestisce anche il "crollo" stilizzato (busto piegato, ginocchia molli).
## Le ossa hanno rotazione di riposo nulla: le pose sono rotazioni dal riposo.
## Il personaggio guarda verso +Z; il lato sinistro è +X.

## Metri percorsi in un ciclo completo di passi.
@export var stride_length: float = 0.9
@export var leg_swing_degrees: float = 30.0
@export var knee_bend_degrees: float = 40.0
@export var arm_swing_degrees: float = 28.0
## Braccia un po' aperte, così non entrano nel busto.
@export var arm_spread_degrees: float = 9.0
@export var elbow_bend_degrees: float = 18.0
## Rimbalzo verticale del bacino a ogni passo, in metri.
@export var hip_bob: float = 0.035
## Dondolio laterale del bacino (camminata a papera), in gradi.
@export var waddle_degrees: float = 7.0
## Torsione del busto opposta alle gambe, in gradi.
@export var chest_twist_degrees: float = 8.0
## Inclinazione in avanti alla massima velocità, in gradi.
@export var forward_lean_degrees: float = 6.0
## Respiro da fermo: ampiezza in gradi e velocità in cicli al secondo.
@export var idle_breath_degrees: float = 2.0
@export var idle_breath_rate: float = 0.35

@export_group("Crollo")
@export var collapse_spine_degrees: float = 32.0
@export var collapse_head_degrees: float = 28.0
@export var collapse_knee_degrees: float = 35.0
@export var collapse_hip_drop: float = 0.12

## Velocità orizzontale del personaggio, impostata ogni frame da RubberBody.
var planar_speed: float = 0.0
## 0 = fermo, 1 = velocità di camminata piena.
var speed_ratio: float = 0.0
## Moltiplicatore del dondolio, legato alla gommosità (0 rigido, 1 pieno).
var sway_scale: float = 1.0
## 0 = in piedi, 1 = crollato.
var collapse_amount: float = 0.0

var _phase: float = 0.0
var _time: float = 0.0
var _bones: Dictionary[StringName, int] = {}
var _rest_positions: Dictionary[StringName, Vector3] = {}


func _process_modification_with_delta(delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if skeleton == null:
		return
	if _bones.is_empty():
		_cache_bones(skeleton)

	_time += delta
	_phase = fmod(_phase + planar_speed / stride_length * TAU * delta, TAU)
	var walk: float = speed_ratio
	var swing: float = sin(_phase)
	var swing_velocity: float = cos(_phase)
	var sway: float = walk * sway_scale
	var breath: float = sin(_time * TAU * idle_breath_rate) * deg_to_rad(idle_breath_degrees) * (1.0 - walk)

	# Bacino: rimbalzo due volte per ciclo, dondolio laterale e abbassamento nel crollo.
	var bob: float = -hip_bob * absf(swing_velocity) * sway
	var hips_position: Vector3 = _rest_positions[&"Hips"] + Vector3(0.0, bob - collapse_hip_drop * collapse_amount, 0.0)
	skeleton.set_bone_pose_position(_bones[&"Hips"], hips_position)
	_set_rotation(skeleton, &"Hips", Quaternion(Vector3.FORWARD, deg_to_rad(waddle_degrees) * swing * sway))

	# Busto: inclinazione in avanti, respiro, crollo e torsione opposta alle gambe.
	var spine_pitch: float = deg_to_rad(forward_lean_degrees) * walk + breath \
			+ deg_to_rad(collapse_spine_degrees) * collapse_amount
	_set_rotation(skeleton, &"Spine", Quaternion(Vector3.RIGHT, spine_pitch))
	_set_rotation(skeleton, &"Chest", Quaternion(Vector3.UP, deg_to_rad(chest_twist_degrees) * swing * sway))
	var head_pitch: float = deg_to_rad(collapse_head_degrees) * collapse_amount - spine_pitch * 0.5 * (1.0 - collapse_amount)
	_set_rotation(skeleton, &"Head", Quaternion(Vector3.FORWARD, -deg_to_rad(waddle_degrees) * swing * sway * 0.7)
			* Quaternion(Vector3.RIGHT, head_pitch))

	# Gambe: oscillazione opposta; il ginocchio si piega mentre la gamba torna avanti.
	var leg_angle: float = deg_to_rad(leg_swing_degrees) * swing * walk
	var knee: float = deg_to_rad(knee_bend_degrees) * walk
	var collapse_knee: float = deg_to_rad(collapse_knee_degrees) * collapse_amount
	_set_rotation(skeleton, &"LeftUpperLeg", Quaternion(Vector3.RIGHT, -leg_angle - collapse_knee * 0.6))
	_set_rotation(skeleton, &"RightUpperLeg", Quaternion(Vector3.RIGHT, leg_angle - collapse_knee * 0.6))
	_set_rotation(skeleton, &"LeftLowerLeg", Quaternion(Vector3.RIGHT, knee * maxf(0.0, swing_velocity) + collapse_knee))
	_set_rotation(skeleton, &"RightLowerLeg", Quaternion(Vector3.RIGHT, knee * maxf(0.0, -swing_velocity) + collapse_knee))
	_set_rotation(skeleton, &"LeftFoot", Quaternion(Vector3.RIGHT, -collapse_knee * 0.4))
	_set_rotation(skeleton, &"RightFoot", Quaternion(Vector3.RIGHT, -collapse_knee * 0.4))

	# Braccia: opposte alle gambe, un po' aperte, gomiti morbidi; nel crollo penzolano.
	var arm_angle: float = deg_to_rad(arm_swing_degrees) * swing * walk * (1.0 - collapse_amount)
	var spread: float = deg_to_rad(arm_spread_degrees) * (1.0 - collapse_amount * 0.7)
	var elbow: float = -deg_to_rad(elbow_bend_degrees) * (0.4 + 0.6 * walk) * (1.0 - collapse_amount)
	_set_rotation(skeleton, &"LeftUpperArm", Quaternion(Vector3.BACK, spread) * Quaternion(Vector3.RIGHT, arm_angle))
	_set_rotation(skeleton, &"RightUpperArm", Quaternion(Vector3.BACK, -spread) * Quaternion(Vector3.RIGHT, -arm_angle))
	_set_rotation(skeleton, &"LeftLowerArm", Quaternion(Vector3.RIGHT, elbow))
	_set_rotation(skeleton, &"RightLowerArm", Quaternion(Vector3.RIGHT, elbow))


func _cache_bones(skeleton: Skeleton3D) -> void:
	for bone_name: StringName in [&"Hips", &"Spine", &"Chest", &"Head",
			&"LeftUpperLeg", &"RightUpperLeg", &"LeftLowerLeg", &"RightLowerLeg",
			&"LeftFoot", &"RightFoot", &"LeftUpperArm", &"RightUpperArm",
			&"LeftLowerArm", &"RightLowerArm"]:
		var index: int = skeleton.find_bone(bone_name)
		_bones[bone_name] = index
		_rest_positions[bone_name] = skeleton.get_bone_rest(index).origin


func _set_rotation(skeleton: Skeleton3D, bone_name: StringName, rotation_value: Quaternion) -> void:
	skeleton.set_bone_pose_rotation(_bones[bone_name], rotation_value)
