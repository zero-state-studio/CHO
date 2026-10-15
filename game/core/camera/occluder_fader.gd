class_name OccluderFader
extends Node
## Rende trasparenti pareti e mobili (gruppo "fade_occluder") quando stanno tra la
## telecamera e il personaggio. Lancia alcuni raggi paralleli alla telecamera
## (proiezione ortogonale) verso piedi, busto e testa del personaggio.

## Altezze dei punti controllati sul personaggio, in metri da terra.
@export var probe_heights: PackedFloat32Array = PackedFloat32Array([0.3, 1.0, 1.6])
## Livelli fisici degli oggetti che possono coprire il personaggio.
@export_flags_3d_physics var occluder_mask: int = 1
## Quanti oggetti al massimo attraversa un raggio.
@export var max_hits_per_ray: int = 4

var camera: Camera3D
var target: Node3D

var _faded: Dictionary[Node, bool] = {}


func _ready() -> void:
	DebugSettings.wall_fade_changed.connect(_on_wall_fade_changed)


func _physics_process(_delta: float) -> void:
	if camera == null or target == null or not DebugSettings.wall_fade_enabled:
		return
	var space: PhysicsDirectSpaceState3D = target.get_world_3d().direct_space_state
	var forward: Vector3 = -camera.global_basis.z
	var ray_length: float = camera.far
	var now_covering: Dictionary[Node, bool] = {}

	for height: float in probe_heights:
		var point: Vector3 = target.global_position + Vector3.UP * height
		var exclude: Array[RID] = []
		for _hit_index: int in max_hits_per_ray:
			var query := PhysicsRayQueryParameters3D.create(
					point - forward * ray_length, point, occluder_mask, exclude)
			var hit: Dictionary = space.intersect_ray(query)
			if hit.is_empty():
				break
			var collider: Object = hit["collider"]
			exclude.append(hit["rid"])
			var node := collider as Node
			if node and node.is_in_group(LevelBlock.FADE_GROUP):
				now_covering[node] = true

	for node: Node in now_covering:
		if not _faded.has(node):
			node.call("set_faded", true)
	for node: Node in _faded:
		if not now_covering.has(node) and is_instance_valid(node):
			node.call("set_faded", false)
	_faded = now_covering


func _on_wall_fade_changed(enabled: bool) -> void:
	if enabled:
		return
	for node: Node in _faded:
		if is_instance_valid(node):
			node.call("set_faded", false)
	_faded.clear()
