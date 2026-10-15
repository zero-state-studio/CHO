class_name RubberBody
extends Node3D
## Corpo del pupazzo gommoso, costruito da codice a partire da un CharacterLook:
## - uno Skeleton3D con i nomi delle ossa del profilo umanoide di Godot;
## - un'unica mesh skinnata fatta di primitive (capsule e sfere), ogni pezzo rigido
##   sul suo osso: articolazioni ben visibili e una sola draw call (più il contorno);
## - camminata procedurale (ProceduralWalk);
## - gommosità regolata da DebugSettings.wobble: da 0 a 1 molle su braccia, testa
##   e accessori e schiacciamento; da 1 a 2 anche ragdoll parziale sulle reazioni.
## È solo un effetto visivo: non cambia mai dove va il personaggio.

const REACTION_HIT: StringName = &"hit"
## Segmenti delle primitive: pochi, per stare nel budget di 1.500-3.000 triangoli.
const LIMB_SEGMENTS: int = 8
const TORSO_SEGMENTS: int = 12
const JOINT_SEGMENTS: int = 6
const REACTION_COLLAPSE: StringName = &"collapse"

## Ossa che il ragdoll parziale simula negli urti: il busto e le braccia. Le gambe
## restano guidate dalla camminata, così il personaggio non cade.
const UPPER_BODY_BONES: Array[StringName] = [&"Spine", &"Chest", &"Head",
		&"LeftUpperArm", &"LeftLowerArm", &"RightUpperArm", &"RightLowerArm"]

## Materiale toon condiviso (colori dai vertici, contorno nel next_pass).
@export var material: Material
## Velocità che corrisponde alla camminata piena, per l'ampiezza dei passi.
@export var full_walk_speed: float = 3.5

@export_group("Molle (gommosità da 0 a 1)")
## Rigidità delle molle quando la gommosità è 0: praticamente ferme.
@export var rigid_stiffness: float = 8.0
@export var arm_stiffness: float = 0.9
@export var arm_drag: float = 0.3
@export var head_stiffness: float = 2.2
@export var head_drag: float = 0.45
@export var accessory_stiffness: float = 0.5
@export var accessory_drag: float = 0.2
@export var accessory_gravity: float = 0.8
## Spinta data alle molle da un urto, moltiplicata per la forza della reazione.
@export var reaction_spring_force: float = 2.5

@export_group("Schiacciamento e allungamento")
## Quanto si schiaccia per ogni m/s² di accelerazione.
@export var squash_per_acceleration: float = 0.012
@export var squash_limit: float = 0.18
@export var squash_spring: float = 160.0
@export var squash_damping: float = 9.0
## Inclinazione del corpo per ogni m/s² di accelerazione, in gradi.
@export var lean_per_acceleration: float = 0.9
@export var lean_limit_degrees: float = 14.0
@export var lean_spring: float = 90.0
@export var lean_damping: float = 8.0
## Spinta data allo schiacciamento e all'inclinazione da un urto.
@export var reaction_squash_kick: float = 2.5
@export var reaction_lean_kick: float = 6.0
@export var landing_squash_kick: float = 0.6

@export_group("Reazioni e ragdoll (gommosità da 1 a 2)")
## Influenza massima del ragdoll con gommosità 2.
@export var ragdoll_peak_influence: float = 0.9
@export var ragdoll_impulse: float = 3.0
@export var hit_hold_seconds: float = 0.35
@export var collapse_hold_seconds: float = 1.4
@export var ragdoll_fade_in_seconds: float = 0.08
@export var ragdoll_fade_out_seconds: float = 0.6
@export var collapse_fade_in_seconds: float = 0.3
@export var collapse_fade_out_seconds: float = 0.6

var look: CharacterLook

var _visual: Node3D
var _skeleton: Skeleton3D
var _mesh_instance: MeshInstance3D
var _walk: ProceduralWalk
var _springs: SpringBoneSimulator3D
var _physics: PhysicalBoneSimulator3D
var _physical_bones: Dictionary[StringName, PhysicalBone3D] = {}
var _spring_chains: Array[Dictionary] = []
var _triangle_count: int = 0

var _previous_velocity: Vector3 = Vector3.ZERO
var _was_on_floor: bool = true
var _squash: float = 0.0
var _squash_velocity: float = 0.0
var _lean: Vector2 = Vector2.ZERO
var _lean_velocity: Vector2 = Vector2.ZERO
var _reaction_tween: Tween
var _force_tween: Tween

# Dati di costruzione della mesh, riempiti da _build_mesh().
var _positions := PackedVector3Array()
var _normals := PackedVector3Array()
var _colors := PackedColorArray()
var _bone_indices := PackedInt32Array()
var _bone_weights := PackedFloat32Array()
var _indices := PackedInt32Array()


func _ready() -> void:
	DebugSettings.wobble_changed.connect(_apply_wobble)


## Costruisce scheletro, mesh e simulatori. Va chiamata una volta, prima dell'uso.
func build(character_look: CharacterLook) -> void:
	look = character_look
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)
	_skeleton = Skeleton3D.new()
	_skeleton.name = "Skeleton3D"
	_visual.add_child(_skeleton)
	_build_bones()
	_build_mesh()
	_build_modifiers()
	_apply_wobble(DebugSettings.wobble)


func get_triangle_count() -> int:
	return _triangle_count


## Aggiorna camminata, schiacciamento e inclinazione. La chiama il personaggio a
## ogni frame di fisica, dopo essersi mosso.
func update_motion(planar_velocity: Vector3, on_floor: bool, delta: float) -> void:
	if _walk == null or delta <= 0.0:
		return
	var speed: float = planar_velocity.length()
	_walk.planar_speed = speed
	_walk.speed_ratio = clampf(speed / full_walk_speed, 0.0, 1.0)

	var spring_amount: float = _spring_amount()
	var acceleration: Vector3 = (planar_velocity - _previous_velocity) / delta
	_previous_velocity = planar_velocity

	# Schiacciamento: allungato quando accelera, schiacciato quando frena o atterra.
	var forward: Vector3 = global_basis.z
	var forward_acceleration: float = acceleration.dot(forward)
	var squash_target: float = clampf(forward_acceleration * squash_per_acceleration, -squash_limit, squash_limit)
	if on_floor and not _was_on_floor:
		_squash_velocity -= landing_squash_kick
	_was_on_floor = on_floor
	var squash_force: float = squash_spring * (squash_target - _squash) - squash_damping * _squash_velocity
	_squash_velocity += squash_force * delta
	_squash = clampf(_squash + _squash_velocity * delta, -squash_limit * 2.0, squash_limit * 2.0)

	# Inclinazione: il corpo resta indietro quando parte e va avanti quando frena.
	# L'asse X locale è la sinistra del personaggio (che guarda verso +Z).
	var left: Vector3 = global_basis.x
	var limit: float = deg_to_rad(lean_limit_degrees)
	var lean_target := Vector2(
			clampf(-forward_acceleration * deg_to_rad(lean_per_acceleration), -limit, limit),
			clampf(acceleration.dot(left) * deg_to_rad(lean_per_acceleration), -limit, limit))
	var lean_force: Vector2 = (lean_target - _lean) * lean_spring - _lean_velocity * lean_damping
	_lean_velocity += lean_force * delta
	_lean += _lean_velocity * delta

	var ragdoll_active: bool = _physics != null and _physics.is_simulating_physics()
	var amount: float = 0.0 if ragdoll_active else spring_amount * _wobble_extra()
	var stretch: float = 1.0 + _squash * amount
	var side: float = 1.0 / sqrt(maxf(stretch, 0.1))
	# Solo la mesh si deforma: lo scheletro resta a scala 1, perché le ossa fisiche
	# del ragdoll non supportano scale non uniformi.
	_mesh_instance.scale = Vector3(side, stretch, side)
	_mesh_instance.rotation = Vector3(_lean.x * amount, 0.0, _lean.y * amount)


## Reazione a un urto o a un crollo. direction è la direzione della spinta, nel
## mondo; strength va da 0 a 1 circa. Non ferma il movimento del personaggio.
func react(kind: StringName, direction: Vector3, strength: float) -> void:
	var wobble: float = DebugSettings.wobble
	if kind == REACTION_COLLAPSE:
		_play_collapse(wobble, strength)
	if wobble <= 0.001:
		return
	var spring_amount: float = _spring_amount()
	_squash_velocity -= reaction_squash_kick * strength * spring_amount
	var local_direction: Vector3 = global_basis.inverse() * direction
	_lean_velocity += Vector2(local_direction.z, -local_direction.x) * reaction_lean_kick * strength * spring_amount
	_push_springs(direction * reaction_spring_force * strength * spring_amount)
	if kind == REACTION_HIT and wobble > 1.0:
		_start_ragdoll(UPPER_BODY_BONES, (wobble - 1.0) * ragdoll_peak_influence * strength,
				direction * ragdoll_impulse * strength, hit_hold_seconds, ragdoll_fade_in_seconds)


# --- Gommosità ---------------------------------------------------------------

func _spring_amount() -> float:
	return clampf(DebugSettings.wobble, 0.0, 1.0)


## Oltre 1 lo schiacciamento cresce ancora un po'.
func _wobble_extra() -> float:
	return 1.0 + clampf(DebugSettings.wobble - 1.0, 0.0, 1.0) * 0.4


func _apply_wobble(wobble: float) -> void:
	if _springs == null:
		return
	var amount: float = clampf(wobble, 0.0, 1.0)
	_springs.active = amount > 0.001
	_springs.influence = amount
	for index: int in _spring_chains.size():
		var chain: Dictionary = _spring_chains[index]
		_springs.set_stiffness(index, lerpf(rigid_stiffness, chain["stiffness"], amount))
		_springs.set_drag(index, chain["drag"])
		_springs.set_gravity(index, chain["gravity"] * amount)
	_walk.sway_scale = lerpf(0.35, 1.0, amount) * _wobble_extra()


func _push_springs(force: Vector3) -> void:
	if _springs == null or not _springs.active:
		return
	if _force_tween:
		_force_tween.kill()
	_springs.external_force = force
	_force_tween = create_tween()
	_force_tween.tween_property(_springs, "external_force", Vector3.ZERO, 0.25)


func _play_collapse(wobble: float, strength: float) -> void:
	if _reaction_tween:
		_reaction_tween.kill()
	# Il crollo stilizzato c'è sempre (anche da rigido): è un'azione, non un effetto.
	_reaction_tween = create_tween()
	_reaction_tween.tween_property(_walk, "collapse_amount", clampf(strength, 0.0, 1.0), collapse_fade_in_seconds)
	_reaction_tween.tween_interval(collapse_hold_seconds)
	_reaction_tween.tween_property(_walk, "collapse_amount", 0.0, collapse_fade_out_seconds)
	if wobble > 1.0:
		var all_bones: Array[StringName] = []
		all_bones.assign(_physical_bones.keys())
		_start_ragdoll(all_bones, (wobble - 1.0) * ragdoll_peak_influence * strength,
				Vector3.DOWN * ragdoll_impulse * 0.5, collapse_hold_seconds, collapse_fade_in_seconds)


func _start_ragdoll(bones: Array[StringName], peak_influence: float, impulse: Vector3,
		hold_seconds: float, fade_in_seconds: float) -> void:
	if _physics == null or peak_influence <= 0.0:
		return
	_physics.physical_bones_stop_simulation()
	_physics.influence = 0.0
	_physics.active = true
	_physics.physical_bones_start_simulation(bones)
	for bone_name: StringName in bones:
		if _physical_bones.has(bone_name):
			_physical_bones[bone_name].apply_central_impulse(impulse / bones.size())
	var tween: Tween = create_tween()
	tween.tween_property(_physics, "influence", clampf(peak_influence, 0.0, 1.0), fade_in_seconds)
	tween.tween_interval(hold_seconds)
	tween.tween_property(_physics, "influence", 0.0, ragdoll_fade_out_seconds)
	tween.tween_callback(_stop_ragdoll)


func _stop_ragdoll() -> void:
	_physics.physical_bones_stop_simulation()
	_physics.active = false


# --- Scheletro -----------------------------------------------------------------

func _build_bones() -> void:
	var ankle_height: float = look.leg_radius * 1.1
	var hip_y: float = ankle_height + look.lower_leg_length + look.upper_leg_length + 0.02
	var torso: float = look.torso_height
	var shoulder_x: float = look.torso_radius * 0.5

	_add_bone(&"Hips", &"", Vector3(0.0, hip_y, 0.0))
	_add_bone(&"Spine", &"Hips", Vector3(0.0, torso * 0.3, 0.0))
	_add_bone(&"Chest", &"Spine", Vector3(0.0, torso * 0.35, 0.0))
	_add_bone(&"Neck", &"Chest", Vector3(0.0, torso * 0.35, 0.0))
	_add_bone(&"Head", &"Neck", Vector3(0.0, look.head_radius * 0.15, 0.0))
	for side: float in [1.0, -1.0]:
		var prefix: String = "Left" if side > 0.0 else "Right"
		_add_bone(prefix + "Shoulder", &"Chest", Vector3(shoulder_x * side, torso * 0.2, 0.0))
		_add_bone(prefix + "UpperArm", prefix + "Shoulder",
				Vector3((look.torso_radius - shoulder_x + look.arm_radius * 0.8) * side, 0.0, 0.0))
		_add_bone(prefix + "LowerArm", prefix + "UpperArm", Vector3(0.0, -look.upper_arm_length, 0.0))
		_add_bone(prefix + "Hand", prefix + "LowerArm", Vector3(0.0, -look.lower_arm_length, 0.0))
		_add_bone(prefix + "UpperLeg", &"Hips", Vector3(look.hip_width * side, -0.02, 0.0))
		_add_bone(prefix + "LowerLeg", prefix + "UpperLeg", Vector3(0.0, -look.upper_leg_length, 0.0))
		_add_bone(prefix + "Foot", prefix + "LowerLeg", Vector3(0.0, -look.lower_leg_length, 0.0))

	var front_y: float = torso * 0.12
	# Gli accessori pendono davanti alla pancia, che è il punto più largo del busto.
	var front_z: float = maxf(_torso_front_z(front_y), look.torso_radius) + 0.015
	if look.has_tie:
		_add_bone(&"TieUpper", &"Chest", Vector3(0.0, front_y + 0.04, front_z + 0.01))
		_add_bone(&"TieLower", &"TieUpper", Vector3(0.0, -look.tie_length * 0.5, 0.0))
	if look.has_badge:
		_add_bone(&"Badge", &"Chest", Vector3(0.0, front_y + 0.06, front_z))


func _add_bone(bone_name: StringName, parent_name: StringName, offset: Vector3) -> void:
	var index: int = _skeleton.add_bone(bone_name)
	if parent_name != &"":
		_skeleton.set_bone_parent(index, _skeleton.find_bone(parent_name))
	_skeleton.set_bone_rest(index, Transform3D(Basis.IDENTITY, offset))
	_skeleton.reset_bone_pose(index)


## Profondità del davanti del busto all'altezza y (rispetto all'osso Chest).
func _torso_front_z(y: float) -> float:
	var upper: Dictionary = _upper_torso_shape()
	var radius: float = upper["radius"]
	var cap_center: float = upper["center"] + upper["height"] * 0.5 - radius
	if y <= cap_center:
		return radius
	return sqrt(maxf(radius * radius - pow(y - cap_center, 2.0), 0.0))


## Capsula superiore del busto, attaccata a Chest: raggio, altezza e centro in y.
func _upper_torso_shape() -> Dictionary:
	var radius: float = look.torso_radius * 0.95
	var bottom: float = -look.torso_height * 0.3
	var top: float = look.torso_height * 0.35 + 0.04
	var height: float = maxf(top - bottom, radius * 2.0)
	return {"radius": radius, "height": height, "center": (bottom + top) * 0.5}


# --- Mesh ----------------------------------------------------------------------

func _build_mesh() -> void:
	var gloss: float = look.torso_gloss
	var torso_radius: float = look.torso_radius

	# Busto a fagiolo: capsula bassa sul bacino, capsula alta sul petto.
	var lower_bottom: float = -look.torso_drop
	var lower_top: float = look.torso_height * 0.55
	var lower_height: float = maxf(lower_top - lower_bottom, torso_radius * 2.0)
	_add_capsule(&"Hips", torso_radius, lower_height,
			Transform3D(Basis.IDENTITY, Vector3(0.0, (lower_bottom + lower_top) * 0.5, 0.0)), look.torso_color, gloss,
			TORSO_SEGMENTS, 2)
	var upper: Dictionary = _upper_torso_shape()
	_add_capsule(&"Chest", upper["radius"], upper["height"],
			Transform3D(Basis.IDENTITY, Vector3(0.0, upper["center"], 0.0)), look.torso_color, gloss,
			TORSO_SEGMENTS, 2)

	# Testa tonda, occhi, sorriso e capelli.
	var head_radius: float = look.head_radius
	var head_center := Vector3(0.0, head_radius * 0.95, 0.0)
	_add_sphere(&"Head", head_radius, Transform3D(Basis.IDENTITY, head_center), look.skin_color, 0.0, 14, 7)
	var eye_radius: float = head_radius * 0.13
	for side: float in [1.0, -1.0]:
		var eye_position: Vector3 = head_center + Vector3(head_radius * 0.36 * side, head_radius * 0.12, head_radius * 0.86)
		_add_sphere(&"Head", eye_radius, Transform3D(Basis.IDENTITY.scaled(Vector3(1.0, 1.3, 0.6)), eye_position),
				look.eye_color, 0.0, JOINT_SEGMENTS, 3)
	if look.has_smile:
		# Sorriso fisso: una capsula sdraiata e schiacciata sul davanti della testa.
		var smile_basis: Basis = Basis(Vector3.BACK, PI * 0.5) * Basis.IDENTITY.scaled(Vector3(0.5, 1.0, 0.5))
		_add_capsule(&"Head", head_radius * 0.12, head_radius * 0.9,
				Transform3D(smile_basis, head_center + Vector3(0.0, -head_radius * 0.35, head_radius * 0.9)),
				look.smile_color, 0.0)
	if look.has_hair:
		_add_sphere(&"Head", head_radius * 1.04,
				Transform3D(Basis.IDENTITY.scaled(Vector3(1.0, 0.62, 1.0)), head_center + Vector3(0.0, head_radius * 0.42, -head_radius * 0.12)),
				look.hair_color, 0.0, 12, 4)

	# Braccia e gambe: segmenti arrotondati con giunti sferici ben visibili.
	for side: String in ["Left", "Right"]:
		_add_limb(side + "UpperArm", look.arm_radius, look.upper_arm_length, look.torso_color, gloss)
		_add_sphere(side + "UpperArm", look.arm_radius * 1.15, Transform3D.IDENTITY, look.torso_color, gloss,
				JOINT_SEGMENTS, 3)
		_add_sphere(side + "LowerArm", look.arm_radius * 1.05, Transform3D.IDENTITY, look.torso_color, gloss,
				JOINT_SEGMENTS, 3)
		_add_limb(side + "LowerArm", look.arm_radius * 0.92, look.lower_arm_length, look.torso_color, gloss)
		# Mano a muffola: una sfera schiacciata, senza dita.
		_add_sphere(side + "Hand", look.hand_radius,
				Transform3D(Basis.IDENTITY.scaled(Vector3(0.8, 1.15, 0.9)), Vector3(0.0, -look.hand_radius * 0.9, 0.0)),
				look.skin_color, 0.0, LIMB_SEGMENTS, 4)
		_add_limb(side + "UpperLeg", look.leg_radius * 1.1, look.upper_leg_length, look.leg_color, 0.0)
		_add_sphere(side + "LowerLeg", look.leg_radius * 1.1, Transform3D.IDENTITY, look.leg_color, 0.0,
				JOINT_SEGMENTS, 3)
		_add_limb(side + "LowerLeg", look.leg_radius, look.lower_leg_length, look.leg_color, 0.0)
		var foot_radius: float = look.leg_radius * 1.1
		_add_capsule(side + "Foot", foot_radius, look.foot_length,
				Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3(0.0, 0.0, look.foot_length * 0.25)),
				look.shoe_color, 0.0)

	_add_accessories()
	_commit_mesh()


func _add_accessories() -> void:
	var front_y: float = look.torso_height * 0.12
	var front_z: float = _torso_front_z(front_y) + 0.01
	if look.has_shirt_front:
		_add_box(&"Chest", Vector3(look.tie_width * 1.7, look.torso_height * 0.42, 0.03),
				Transform3D(Basis.IDENTITY, Vector3(0.0, front_y - look.torso_height * 0.08, front_z - 0.01)),
				look.shirt_front_color, 0.0)
	if look.has_tie:
		var segment: float = look.tie_length * 0.5
		_add_sphere(&"TieUpper", look.tie_width * 0.45, Transform3D.IDENTITY, look.tie_color, 0.3, JOINT_SEGMENTS, 3)
		_add_box(&"TieUpper", Vector3(look.tie_width * 0.75, segment, 0.025),
				Transform3D(Basis.IDENTITY, Vector3(0.0, -segment * 0.5, 0.0)), look.tie_color, 0.3)
		_add_box(&"TieLower", Vector3(look.tie_width, segment, 0.025),
				Transform3D(Basis.IDENTITY, Vector3(0.0, -segment * 0.5, 0.0)), look.tie_color, 0.3)
	if look.has_badge:
		_add_box(&"Badge", Vector3(0.008, 0.12, 0.008),
				Transform3D(Basis.IDENTITY, Vector3(0.0, -0.06, 0.0)), look.badge_color, 0.0)
		_add_box(&"Badge", Vector3(0.1, 0.12, 0.012),
				Transform3D(Basis.IDENTITY, Vector3(0.0, -0.16, 0.0)), Color(0.98, 0.98, 0.98), 0.5)
	if look.has_backpack:
		var back_z: float = -look.torso_radius * 0.95 - 0.06
		_add_box(&"Chest", Vector3(look.torso_radius * 1.3, look.torso_height * 0.6, 0.14),
				Transform3D(Basis.IDENTITY, Vector3(0.0, -look.torso_height * 0.05, back_z)), look.backpack_color, 0.0)


func _add_limb(bone_name: StringName, radius: float, length: float, color: Color, gloss: float) -> void:
	# Un po' più corto dell'osso: lo stacco tra i segmenti fa vedere l'articolazione.
	var height: float = maxf(length * 0.92, radius * 2.0)
	_add_capsule(bone_name, radius, height,
			Transform3D(Basis.IDENTITY, Vector3(0.0, -length * 0.5, 0.0)), color, gloss)


func _add_capsule(bone_name: StringName, radius: float, height: float, local: Transform3D,
		color: Color, gloss: float, radial_segments: int = LIMB_SEGMENTS, rings: int = 1) -> void:
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = maxf(height, radius * 2.0)
	capsule.radial_segments = radial_segments
	capsule.rings = rings
	_add_primitive(capsule, bone_name, local, color, gloss)


func _add_sphere(bone_name: StringName, radius: float, local: Transform3D, color: Color, gloss: float,
		radial_segments: int, rings: int) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = radial_segments
	sphere.rings = rings
	_add_primitive(sphere, bone_name, local, color, gloss)


func _add_box(bone_name: StringName, size: Vector3, local: Transform3D, color: Color, gloss: float) -> void:
	var box := BoxMesh.new()
	box.size = size
	_add_primitive(box, bone_name, local, color, gloss)


## Aggiunge una primitiva alla mesh unica, rigida sull'osso indicato. I vertici
## vanno nello spazio dello scheletro a riposo; la skin li riporta sull'osso.
func _add_primitive(primitive: PrimitiveMesh, bone_name: StringName, local: Transform3D,
		color: Color, gloss: float) -> void:
	var bone_index: int = _skeleton.find_bone(bone_name)
	assert(bone_index >= 0, "Osso mancante: %s" % bone_name)
	var to_skeleton: Transform3D = _skeleton.get_bone_global_rest(bone_index) * local
	var normal_basis: Basis = to_skeleton.basis.inverse().transposed()
	var arrays: Array = primitive.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var base: int = _positions.size()
	# Il canale alfa del colore porta la lucentezza (letta dallo shader toon).
	var vertex_color := Color(color.r, color.g, color.b, gloss)
	for vertex_index: int in vertices.size():
		_positions.append(to_skeleton * vertices[vertex_index])
		_normals.append((normal_basis * normals[vertex_index]).normalized())
		_colors.append(vertex_color)
		_bone_indices.append_array([bone_index, 0, 0, 0])
		_bone_weights.append_array([1.0, 0.0, 0.0, 0.0])
	for index: int in indices:
		_indices.append(base + index)


func _commit_mesh() -> void:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _positions
	arrays[Mesh.ARRAY_NORMAL] = _normals
	arrays[Mesh.ARRAY_COLOR] = _colors
	arrays[Mesh.ARRAY_BONES] = _bone_indices
	arrays[Mesh.ARRAY_WEIGHTS] = _bone_weights
	arrays[Mesh.ARRAY_INDEX] = _indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	if material:
		mesh.surface_set_material(0, material)
	_triangle_count = _indices.size() / 3

	var skin := Skin.new()
	for bone_index: int in _skeleton.get_bone_count():
		skin.add_named_bind(_skeleton.get_bone_name(bone_index),
				_skeleton.get_bone_global_rest(bone_index).affine_inverse())

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "Body"
	_mesh_instance.mesh = mesh
	_visual.add_child(_mesh_instance)
	_mesh_instance.skin = skin
	_mesh_instance.skeleton = _mesh_instance.get_path_to(_skeleton)

	_positions = PackedVector3Array()
	_normals = PackedVector3Array()
	_colors = PackedColorArray()
	_bone_indices = PackedInt32Array()
	_bone_weights = PackedFloat32Array()
	_indices = PackedInt32Array()


# --- Modificatori: camminata, molle, ragdoll -----------------------------------------

func _build_modifiers() -> void:
	_walk = ProceduralWalk.new()
	_walk.name = "ProceduralWalk"
	_skeleton.add_child(_walk)

	_springs = SpringBoneSimulator3D.new()
	_springs.name = "SpringBones"
	_skeleton.add_child(_springs)
	for side: String in ["Left", "Right"]:
		_add_spring_chain(side + "UpperArm", side + "Hand", look.hand_radius * 2.0, arm_stiffness, arm_drag, 0.0)
	_add_spring_chain(&"Neck", &"Head", look.head_radius * 1.8, head_stiffness, head_drag, 0.0)
	if look.has_tie:
		_add_spring_chain(&"TieUpper", &"TieLower", look.tie_length * 0.5,
				accessory_stiffness, accessory_drag, accessory_gravity)
	if look.has_badge:
		# Osso singolo: la direzione "dal genitore" punterebbe in avanti, il badge pende in giù.
		_add_spring_chain(&"Badge", &"Badge", 0.16, accessory_stiffness, accessory_drag, accessory_gravity,
				SkeletonModifier3D.BONE_DIRECTION_MINUS_Y)

	_physics = PhysicalBoneSimulator3D.new()
	_physics.name = "PhysicalBones"
	_physics.active = false
	_skeleton.add_child(_physics)
	_add_physical_bone(&"Hips", Vector3(0.0, look.torso_height * 0.3, 0.0), look.torso_radius)
	_add_physical_bone(&"Spine", Vector3(0.0, look.torso_height * 0.35, 0.0), look.torso_radius * 0.9)
	_add_physical_bone(&"Chest", Vector3(0.0, look.torso_height * 0.35, 0.0), look.torso_radius * 0.9)
	_add_physical_bone(&"Head", Vector3(0.0, look.head_radius * 1.9, 0.0), look.head_radius * 0.9)
	for side: String in ["Left", "Right"]:
		_add_physical_bone(side + "UpperArm", Vector3(0.0, -look.upper_arm_length, 0.0), look.arm_radius)
		_add_physical_bone(side + "LowerArm", Vector3(0.0, -look.lower_arm_length - look.hand_radius, 0.0), look.arm_radius)
		_add_physical_bone(side + "UpperLeg", Vector3(0.0, -look.upper_leg_length, 0.0), look.leg_radius)
		_add_physical_bone(side + "LowerLeg", Vector3(0.0, -look.lower_leg_length, 0.0), look.leg_radius)


func _add_spring_chain(root_bone: StringName, end_bone: StringName, end_length: float,
		stiffness: float, drag: float, gravity: float,
		end_direction: SkeletonModifier3D.BoneDirection = SkeletonModifier3D.BONE_DIRECTION_FROM_PARENT) -> void:
	var index: int = _springs.setting_count
	_springs.setting_count = index + 1
	_springs.set_root_bone_name(index, root_bone)
	_springs.set_end_bone_name(index, end_bone)
	_springs.set_extend_end_bone(index, true)
	_springs.set_end_bone_length(index, end_length)
	_springs.set_end_bone_direction(index, end_direction)
	_springs.set_radius(index, 0.02)
	_spring_chains.append({"stiffness": stiffness, "drag": drag, "gravity": gravity})


## Osso fisico per il ragdoll: capsula lungo l'osso, giunto a cono alla sua base.
## Non urta nulla tranne il pavimento e le pareti (livello "world"), così non
## spinge il personaggio né gli oggetti.
func _add_physical_bone(bone_name: StringName, bone_vector: Vector3, radius: float) -> void:
	var half_length: float = bone_vector.length() * 0.5
	var up: Vector3 = Vector3.FORWARD if absf(bone_vector.normalized().dot(Vector3.UP)) > 0.99 else Vector3.UP
	var body_basis := Basis.looking_at(bone_vector, up)
	var body := PhysicalBone3D.new()
	body.name = "Physical" + bone_name
	body.bone_name = bone_name
	body.body_offset = Transform3D(body_basis, body_basis * Vector3(0.0, 0.0, -half_length))
	body.joint_offset = Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, half_length))
	body.joint_type = PhysicalBone3D.JOINT_TYPE_CONE
	body.collision_layer = 0
	body.collision_mask = 1
	body.mass = 1.0
	body.linear_damp = 0.4
	body.angular_damp = 3.0
	var shape := CapsuleShape3D.new()
	shape.radius = radius
	shape.height = maxf(half_length * 2.0, radius * 2.0)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO)
	body.add_child(collision)
	_physics.add_child(body)
	_physical_bones[bone_name] = body
