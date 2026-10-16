extends SceneTree
## Test delle interazioni e della fisica del livello demo, senza interfaccia:
## pratica dalla stampante alla scrivania, scrivania che rifiuta a mani vuote,
## caffè annullato da un nuovo clic e poi completato, pulsante "crollo", oggetti
## spinti camminando, palline di carta che colpiscono il personaggio.
##
## Uso: godot --headless --path . --fixed-fps 60 -s res://tests/demo_interactions.gd
##
## Le variabili sono Variant: questo script si compila prima degli autoload, quindi
## non può nominare classi che usano DebugSettings.

const DEMO_SCENE: String = "res://game/levels/demo/demo.tscn"
const INTERACTION_ZONE: String = "NavigationRegion3D/Interaction/"
const PHYSICS_ZONE: String = "NavigationRegion3D/PhysicsZone/"
## Tempo massimo per ogni controllo, in secondi simulati.
const TIMEOUT: float = 20.0

var _demo: Variant
var _character: Variant
var _failures: int = 0
var _coffee_served: int = 0
var _denied: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	change_scene_to_file(DEMO_SCENE)
	await process_frame
	await process_frame
	await physics_frame
	await physics_frame
	_demo = current_scene
	_character = _demo.get("character")
	var printer: Variant = _demo.get_node(INTERACTION_ZONE + "Printer")
	var coffee: Variant = _demo.get_node(INTERACTION_ZONE + "CoffeeMachine")
	var desk: Variant = _demo.get_node(INTERACTION_ZONE + "Desk")
	var collapse_button: Variant = _demo.get_node(PHYSICS_ZONE + "CollapseButton")
	coffee.connect("coffee_served", func(_who: Variant) -> void: _coffee_served += 1)
	desk.connect("interaction_denied", func(_who: Variant) -> void: _denied += 1)

	# 1. Pratica dalla stampante alla scrivania.
	_character.interact_with(printer)
	_check("prende la pratica dalla stampante", await _wait_until(func() -> bool: return _character.is_carrying_task))
	_character.interact_with(desk)
	_check("consegna la pratica alla scrivania", await _wait_until(func() -> bool: return desk.received_tasks == 1))
	_check("non ha più la pratica in mano", not _character.is_carrying_task)

	# 2. A mani vuote la scrivania dice di no.
	_character.move_to(Vector3(2.0, 0.0, -8.0))
	await _wait_until(func() -> bool: return _character.get_planar_velocity().length() < 0.05 and not _character.call("is_busy"), 6.0)
	_character.interact_with(desk)
	_check("la scrivania rifiuta a mani vuote", await _wait_until(func() -> bool: return _denied == 1))
	_check("niente consegna in più", desk.received_tasks == 1)

	# 3. Un nuovo clic annulla il caffè; poi il caffè si completa.
	_character.interact_with(coffee)
	await _wait_until(func() -> bool: return _character.call("is_busy"))
	await _wait_seconds(0.5)
	_character.move_to(Vector3(0.0, 0.0, -10.0))
	await _wait_seconds(2.5)
	_check("il caffè annullato non viene servito", _coffee_served == 0)
	_character.interact_with(coffee)
	_check("il caffè completato viene servito", await _wait_until(func() -> bool: return _coffee_served == 1))

	# 4. Il pulsante crollo fa crollare il personaggio.
	var walk: Variant = _character.get_node("RubberBody/Visual/Skeleton3D/ProceduralWalk")
	_character.interact_with(collapse_button)
	_check("il pulsante crollo fa crollare", await _wait_until(func() -> bool: return walk.collapse_amount > 0.5))
	await _wait_seconds(2.5)

	# 5. Camminando in mezzo alle scatole le sposta e non si incastra.
	var box: Variant = _demo.get_node("PhysicsProps/Box1")
	var box_start: Vector3 = box.global_position
	_character.move_to(Vector3(11.4, 0.0, -14.5))
	var arrived: bool = await _wait_until(func() -> bool:
		return _flat_distance(_character.global_position, Vector3(11.4, 0.0, -14.5)) < 0.6)
	_check("attraversa le scatole senza incastrarsi", arrived)
	_check("le scatole si spostano", box.global_position.distance_to(box_start) > 0.1)

	# 6. Il lanciatore colpisce il personaggio (gommosità 2: anche ragdoll).
	get_root().get_node("DebugSettings").set("wobble", 2.0)
	_character.move_to(Vector3(17.0, 0.0, -8.0))
	var hit_seen: bool = await _wait_until(func() -> bool:
		for node: Node in _demo.find_children("*", "RigidBody3D", true, false):
			if node.get("_has_hit") == true:
				return true
		return false)
	_check("una pallina di carta colpisce il personaggio", hit_seen)

	print("Risultato: %d controlli falliti" % _failures)
	quit(1 if _failures > 0 else 0)


func _check(label: String, passed: bool) -> void:
	if passed:
		print("OK      ", label)
	else:
		_failures += 1
		print("FALLITO ", label, "  posizione ", _character.global_position)


func _wait_until(condition: Callable, timeout: float = TIMEOUT) -> bool:
	var elapsed: float = 0.0
	while elapsed < timeout:
		await physics_frame
		elapsed += 1.0 / Engine.physics_ticks_per_second
		if condition.call():
			return true
	return false


func _wait_seconds(seconds: float) -> void:
	await _wait_until(func() -> bool: return false, seconds)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
