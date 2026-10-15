class_name Interactable
extends Area3D
## Oggetto con cui il personaggio interagisce: si clicca, il personaggio va al punto
## di avvicinamento, parte la barra di avanzamento e alla fine succede qualcosa
## (_on_completed). L'area di clic è più grande dell'oggetto, per non sbagliare il
## bersaglio; l'ostacolo fisico (livello "world") entra nella navmesh.
## Il modello si sceglie con model_scene: se manca, si vede un segnaposto.

signal interaction_started(character: RubberCharacter)
signal interaction_finished(character: RubberCharacter)
signal interaction_cancelled(character: RubberCharacter)
signal interaction_denied(character: RubberCharacter)

## Durata dell'azione, in secondi (0 = immediata).
@export var duration: float = 2.0
## Punto dove si mette il personaggio, nello spazio dell'oggetto (davanti = +Z).
@export var approach_offset: Vector3 = Vector3(0.0, 0.0, 1.0)
## Modello dell'oggetto (per esempio un .glb di Meshy). Se manca, segnaposto.
@export var model_scene: PackedScene
## Scala applicata al modello importato.
@export var model_scale: float = 1.0
## Ingombro dell'oggetto: collisione, segnaposto e area di clic.
@export var footprint: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var placeholder_color: Color = Color(0.8, 0.8, 0.85)
## Quanto l'area di clic sporge oltre l'oggetto, per lato.
@export var click_margin: float = 0.35
## Altezza minima dell'area di clic, per gli oggetti bassi.
@export var min_click_height: float = 1.2
## L'oggetto blocca il passaggio (ed entra nella navmesh come ostacolo). Gli oggetti
## bassi su cui si sale, come il pulsante "crollo", non sono solidi.
@export var solid: bool = true

var _model: Node3D
var _model_rest_scale: Vector3 = Vector3.ONE
var _active_character: RubberCharacter
var _elapsed: float = 0.0
var _feedback_tween: Tween


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	monitoring = false
	if solid:
		_build_obstacle()
	_build_click_area()
	_build_model()
	set_process(false)


func get_approach_point() -> Vector3:
	return global_transform * approach_offset


## Effetto visivo del clic: l'oggetto rimbalza, così si vede cosa si è scelto.
func highlight() -> void:
	_bounce(1.12)


## Chiamata dal personaggio quando arriva. Restituisce false se l'azione non si
## può fare (per esempio la scrivania senza una pratica in mano).
func start_interaction(character: RubberCharacter) -> bool:
	if not _can_interact(character):
		_shake()
		interaction_denied.emit(character)
		return false
	_active_character = character
	_elapsed = 0.0
	interaction_started.emit(character)
	if duration <= 0.0:
		_finish()
	else:
		character.show_progress(0.0)
		set_process(true)
	return true


func cancel_interaction(character: RubberCharacter) -> void:
	if character != _active_character:
		return
	set_process(false)
	_active_character = null
	if is_instance_valid(character):
		character.hide_progress()
	interaction_cancelled.emit(character)


func _process(delta: float) -> void:
	if not is_instance_valid(_active_character):
		set_process(false)
		_active_character = null
		return
	_elapsed += delta
	_active_character.show_progress(clampf(_elapsed / duration, 0.0, 1.0))
	if _elapsed >= duration:
		_finish()


func _finish() -> void:
	set_process(false)
	var character: RubberCharacter = _active_character
	_active_character = null
	character.hide_progress()
	character.notify_interaction_ended(self)
	_on_completed(character)
	interaction_finished.emit(character)


## Da ridefinire: l'azione si può fare adesso?
func _can_interact(_character: RubberCharacter) -> bool:
	return true


## Da ridefinire: cosa succede alla fine dell'azione.
func _on_completed(_character: RubberCharacter) -> void:
	pass


func _build_obstacle() -> void:
	var body := StaticBody3D.new()
	body.name = "Obstacle"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = footprint
	shape.shape = box
	shape.position.y = footprint.y * 0.5
	body.add_child(shape)
	add_child(body)


func _build_click_area() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var height: float = maxf(footprint.y, min_click_height)
	box.size = Vector3(footprint.x + click_margin * 2.0, height, footprint.z + click_margin * 2.0)
	shape.shape = box
	shape.position.y = height * 0.5
	add_child(shape)


func _build_model() -> void:
	if model_scene:
		_model = model_scene.instantiate() as Node3D
		_model_rest_scale = Vector3.ONE * model_scale
		_model.scale = _model_rest_scale
	else:
		var mesh_instance := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = footprint
		mesh_instance.mesh = box
		mesh_instance.position.y = footprint.y * 0.5
		var material := StandardMaterial3D.new()
		material.albedo_color = placeholder_color
		mesh_instance.material_override = material
		_model = Node3D.new()
		_model.add_child(mesh_instance)
	_model.name = "Model"
	add_child(_model)


func _bounce(peak: float) -> void:
	if _feedback_tween:
		_feedback_tween.kill()
	_model.scale = _model_rest_scale * peak
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(_model, "scale", _model_rest_scale, 0.25) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## L'oggetto "dice di no": scuote la testa. Segnale visivo, non solo sonoro.
func _shake() -> void:
	if _feedback_tween:
		_feedback_tween.kill()
	_model.scale = _model_rest_scale
	_feedback_tween = create_tween()
	for offset: float in [0.08, -0.08, 0.05, -0.05, 0.0]:
		_feedback_tween.tween_property(_model, "position:x", offset, 0.05)
