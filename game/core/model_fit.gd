class_name ModelFit
extends RefCounted
## Utilità per i modelli importati (per esempio i .glb di Meshy, che hanno l'origine
## al centro): calcolo dell'ingombro e appoggio a terra.


## Ingombro di tutte le mesh sotto node, nello spazio di reference.
static func bounds_in(node: Node, reference: Node3D) -> AABB:
	var result := AABB()
	var has_any: bool = false
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var to_reference: Transform3D = reference.global_transform.affine_inverse() * mesh_instance.global_transform
		var mesh_bounds: AABB = to_reference * mesh_instance.get_aabb()
		result = mesh_bounds if not has_any else result.merge(mesh_bounds)
		has_any = true
	var own := node as MeshInstance3D
	if own and own.mesh:
		var own_bounds: AABB = reference.global_transform.affine_inverse() * own.global_transform * own.get_aabb()
		result = own_bounds if not has_any else result.merge(own_bounds)
	return result


## Sposta model (già nel suo genitore, già scalato e ruotato) in modo che poggi sul
## piano y = floor_y del genitore e sia centrato su x e z. Va chiamata con il
## modello già nell'albero della scena.
static func ground(model: Node3D, floor_y: float = 0.0) -> void:
	var parent := model.get_parent() as Node3D
	if parent == null:
		return
	var bounds: AABB = bounds_in(model, parent)
	var center: Vector3 = bounds.get_center()
	model.position += Vector3(-center.x, floor_y - bounds.position.y, -center.z)
