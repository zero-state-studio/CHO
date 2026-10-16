class_name MeshBatcher
extends Node3D
## Raggruppa in MultiMesh le mesh statiche uguali (stessa mesh, stesso materiale,
## stesse ombre): un gruppo costa una draw call per passata invece di una per
## oggetto. Le mesh originali restano nell'albero, nascoste. Chi deve animarne una
## (dissolvenza di una parete, tasto che pulsa) la stacca con detach(): torna
## visibile da sola e sparisce dal gruppo; con attach() rientra.
##
## Uso: i nodi nel gruppo BATCHABLE_GROUP hanno il metodo batch_meshes(batcher) e
## ci chiamano add(); poi chi possiede il livello chiama build() una volta sola.

const BATCHABLE_GROUP: StringName = &"mesh_batchable"

## Gruppi con meno istanze di così restano mesh separate: non si risparmia nulla.
@export var min_instances: int = 2

var _groups: Dictionary[String, BatchGroup] = {}
var _group_of: Dictionary[MeshInstance3D, BatchGroup] = {}


class BatchGroup:
	var mesh: Mesh
	var material: Material
	var cast_shadow: GeometryInstance3D.ShadowCastingSetting
	var members: Array[MeshInstance3D] = []
	var multimesh: MultiMesh


## Chiede a tutti i nodi raggruppabili sotto root di registrare le loro mesh, poi
## crea le MultiMesh.
func collect(root: Node) -> void:
	for node: Node in root.get_tree().get_nodes_in_group(BATCHABLE_GROUP):
		if root.is_ancestor_of(node):
			node.call("batch_meshes", self)
	build()


## Mette una mesh nella coda del suo gruppo. Le mesh che non si possono
## raggruppare (nascoste, con skin o materiali per superficie) restano come sono.
func add(mesh_instance: MeshInstance3D) -> void:
	if not _can_batch(mesh_instance):
		return
	var key: String = "%d/%d/%d" % [mesh_instance.mesh.get_instance_id(),
			mesh_instance.material_override.get_instance_id() if mesh_instance.material_override else 0,
			mesh_instance.cast_shadow]
	var group: BatchGroup = _groups.get(key)
	if group == null:
		group = BatchGroup.new()
		group.mesh = mesh_instance.mesh
		group.material = mesh_instance.material_override
		group.cast_shadow = mesh_instance.cast_shadow
		_groups[key] = group
	group.members.append(mesh_instance)


## Crea una MultiMesh per ogni gruppo abbastanza grande e nasconde le originali.
func build() -> void:
	for group: BatchGroup in _groups.values():
		if group.multimesh or group.members.size() < min_instances:
			continue
		group.multimesh = MultiMesh.new()
		group.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		group.multimesh.mesh = group.mesh
		group.multimesh.instance_count = group.members.size()
		var multimesh_instance := MultiMeshInstance3D.new()
		multimesh_instance.multimesh = group.multimesh
		multimesh_instance.material_override = group.material
		multimesh_instance.cast_shadow = group.cast_shadow
		add_child(multimesh_instance)
		for index: int in group.members.size():
			var member: MeshInstance3D = group.members[index]
			_group_of[member] = group
			attach(member)


## La mesh torna visibile da sola e il suo posto nel gruppo resta vuoto.
func detach(mesh_instance: MeshInstance3D) -> void:
	var group: BatchGroup = _group_of.get(mesh_instance)
	if group == null:
		return
	var index: int = group.members.find(mesh_instance)
	var hidden := Transform3D(Basis.from_scale(Vector3.ZERO), _local_transform(mesh_instance).origin)
	group.multimesh.set_instance_transform(index, hidden)
	mesh_instance.visible = true


## La mesh rientra nel gruppo, nella posizione che ha adesso, e si nasconde.
func attach(mesh_instance: MeshInstance3D) -> void:
	var group: BatchGroup = _group_of.get(mesh_instance)
	if group == null:
		return
	var index: int = group.members.find(mesh_instance)
	group.multimesh.set_instance_transform(index, _local_transform(mesh_instance))
	mesh_instance.visible = false


func _local_transform(mesh_instance: MeshInstance3D) -> Transform3D:
	return global_transform.affine_inverse() * mesh_instance.global_transform


func _can_batch(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
		return false
	if mesh_instance.skin != null or mesh_instance.material_overlay != null or _group_of.has(mesh_instance):
		return false
	for surface: int in mesh_instance.get_surface_override_material_count():
		if mesh_instance.get_surface_override_material(surface) != null:
			return false
	return true
