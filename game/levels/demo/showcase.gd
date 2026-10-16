class_name Showcase
extends Node3D
## Vetrina del livello demo: mette in fila tutti i personaggi (scene in
## game/characters/, tranne il corpo base) e tutti i modelli di assets/models/, con
## nome e numero di triangoli, per confrontare scala e stile. Si popola da sola
## all'avvio leggendo le cartelle (anche nella build esportata). Ogni oggetto ha un
## ostacolo a forma di scatola, così entra nella navmesh e non lo si attraversa.

## Cartella dei modelli, letta con le sottocartelle.
@export_dir var models_root: String = "res://assets/models"
## Cartella delle scene dei personaggi.
@export_dir var characters_root: String = "res://game/characters"
## Sottocartelle dei personaggi da saltare (il corpo base non è un personaggio).
@export var excluded_character_dirs: PackedStringArray = PackedStringArray(["rubber"])
## Estensioni dei file da mettere in vetrina.
@export var model_extensions: PackedStringArray = PackedStringArray(["glb", "gltf", "tscn", "scn"])
## Spazio libero tra un oggetto e l'altro, in metri.
@export var item_gap: float = 1.0
## Lunghezza massima di una fila, in metri; poi si va a capo.
@export var max_row_length: float = 20.0
## Distanza tra le file, in metri.
@export var row_gap: float = 3.0
## Rotazione degli oggetti, in gradi: 45 li gira verso la telecamera isometrica.
@export var item_yaw_degrees: float = 45.0
## Budget di triangoli (specifiche §6.2).
@export var prop_triangle_budget: int = 1500
@export var character_triangle_budget: int = 3000
@export var label_color: Color = Color(0.1, 0.1, 0.14)
@export var over_budget_color: Color = Color(0.85, 0.1, 0.1)

## Elenco di ciò che è in vetrina: nome, percorso, triangoli, fuori budget.
var entries: Array[Dictionary] = []

var _cursor := Vector2.ZERO
var _row_depth: float = 0.0


func _ready() -> void:
	populate()


func populate() -> void:
	for child: Node in get_children():
		child.queue_free()
	entries.clear()
	_cursor = Vector2.ZERO
	_row_depth = 0.0
	for path: String in _find_files(characters_root, PackedStringArray(["tscn"]), excluded_character_dirs):
		_add_item(path, true)
	_new_row()
	for path: String in _find_files(models_root, model_extensions, PackedStringArray()):
		_add_item(path, false)


## Conta i triangoli di tutte le mesh visibili sotto node (salta per esempio la
## pratica nascosta in mano ai personaggi).
static func count_triangles(node: Node) -> int:
	var node_3d := node as Node3D
	if node_3d and not node_3d.visible:
		return 0
	var total: int = 0
	var mesh_instance := node as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		total += mesh_instance.mesh.get_faces().size() / 3
	for child: Node in node.get_children():
		total += count_triangles(child)
	return total


func _add_item(path: String, is_character: bool) -> void:
	var resource: Resource = load(path)
	var item: Node3D = _instantiate(resource)
	if item == null:
		push_warning("Vetrina: non riesco a mostrare %s" % path)
		return
	var holder := Node3D.new()
	holder.name = path.get_file().get_basename()
	add_child(holder)
	holder.add_child(item)
	item.rotation.y = deg_to_rad(item_yaw_degrees)
	if is_character:
		_freeze_character(item)

	var bounds: AABB = _local_bounds(item, holder)
	var width: float = maxf(bounds.size.x, 0.3)
	var depth: float = maxf(bounds.size.z, 0.3)
	if _cursor.x > 0.0 and _cursor.x + width > max_row_length:
		_new_row()
	# L'oggetto si appoggia a terra, centrato nel suo spazio della fila.
	holder.position = Vector3(_cursor.x + width * 0.5 - bounds.get_center().x, -bounds.position.y,
			_cursor.y - bounds.get_center().z)
	_cursor.x += width + item_gap
	_row_depth = maxf(_row_depth, depth)
	_add_obstacle(holder, bounds)

	var triangles: int = count_triangles(item)
	var budget: int = character_triangle_budget if is_character else prop_triangle_budget
	var over_budget: bool = triangles > budget
	entries.append({"name": holder.name, "path": path, "triangles": triangles, "over_budget": over_budget})
	_add_label(holder, bounds, triangles, over_budget)


func _instantiate(resource: Resource) -> Node3D:
	if resource is PackedScene:
		return (resource as PackedScene).instantiate() as Node3D
	if resource is Mesh:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = resource
		return mesh_instance
	return null


## Un personaggio in vetrina sta fermo e non urta niente: resta solo il corpo
## gommoso, che respira e segue lo slider della gommosità.
func _freeze_character(item: Node3D) -> void:
	var body := item as CollisionObject3D
	if body:
		body.collision_layer = 0
		body.collision_mask = 0
	item.set_physics_process(false)


func _add_obstacle(holder: Node3D, bounds: AABB) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(maxf(bounds.size.x, 0.3), maxf(bounds.size.y, 0.3), maxf(bounds.size.z, 0.3))
	shape.shape = box
	shape.position = bounds.get_center()
	body.add_child(shape)
	holder.add_child(body)


func _add_label(holder: Node3D, bounds: AABB, triangles: int, over_budget: bool) -> void:
	var label := Label3D.new()
	# Il testo è già tradotto qui: il nome del file è un dato, non una chiave.
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var text: String = "%s\n%s" % [holder.name, tr("UI_DEMO_TRIANGLES").format({"count": triangles})]
	if over_budget:
		# Fuori budget: scritto, non solo colorato.
		text += "\n" + tr("UI_DEMO_OVER_BUDGET")
	label.text = text
	label.modulate = over_budget_color if over_budget else label_color
	label.outline_modulate = Color(1.0, 1.0, 1.0)
	label.outline_size = 12
	label.font_size = 40
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(bounds.get_center().x, bounds.end.y + 0.45, bounds.get_center().z)
	holder.add_child(label)


func _new_row() -> void:
	if _cursor.x <= 0.0:
		return
	_cursor = Vector2(0.0, _cursor.y + _row_depth + row_gap)
	_row_depth = 0.0


## Ingombro di tutte le mesh sotto node, nello spazio di reference.
func _local_bounds(node: Node, reference: Node3D) -> AABB:
	var result := AABB()
	var has_any: bool = false
	var mesh_instance := node as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		var to_reference: Transform3D = reference.global_transform.affine_inverse() * mesh_instance.global_transform
		result = to_reference * mesh_instance.get_aabb()
		has_any = true
	for child: Node in node.get_children():
		var child_bounds: AABB = _local_bounds(child, reference)
		if child_bounds.size != Vector3.ZERO:
			result = child_bounds if not has_any else result.merge(child_bounds)
			has_any = true
	return result


## File con le estensioni indicate, cercati anche nelle sottocartelle, in ordine.
func _find_files(root: String, extensions: PackedStringArray, excluded_dirs: PackedStringArray) -> PackedStringArray:
	var found := PackedStringArray()
	if not DirAccess.dir_exists_absolute(root):
		return found
	var names: PackedStringArray = ResourceLoader.list_directory(root)
	names.sort()
	for entry: String in names:
		var path: String = root.path_join(entry.trim_suffix("/"))
		if entry.ends_with("/"):
			if not excluded_dirs.has(entry.trim_suffix("/")):
				found.append_array(_find_files(path, extensions, excluded_dirs))
		elif extensions.has(entry.get_extension().to_lower()):
			found.append(path)
	return found
