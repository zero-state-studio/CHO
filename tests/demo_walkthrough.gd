extends SceneTree
## Test di attraversamento del livello demo, senza interfaccia: il personaggio
## percorre corridoio, porta, rampa, pedana, gradini e tutte le zone, e ogni tappa
## deve essere raggiunta entro un tempo massimo (cioè senza incastrarsi).
##
## Uso: godot --headless --path . --fixed-fps 60 -s res://tests/demo_walkthrough.gd

const DEMO_SCENE: String = "res://game/levels/demo/demo.tscn"
## Tempo massimo per raggiungere una tappa, in secondi simulati.
const STEP_TIMEOUT: float = 25.0
## Distanza orizzontale entro cui la tappa è raggiunta.
const ARRIVAL_TOLERANCE: float = 0.5

## [nome, punto, altezza minima dei piedi all'arrivo (-1 = non controllare)]
const WAYPOINTS: Array = [
	["corridoio, dentro", Vector3(-15.0, 0.0, -12.0), -1.0],
	["corridoio, uscita", Vector3(-10.6, 0.0, -12.0), -1.0],
	["prima della porta", Vector3(-20.0, 0.0, -9.0), -1.0],
	["dopo la porta", Vector3(-20.0, 0.0, -5.0), -1.0],
	["rampa", Vector3(-16.5, 0.2, -3.5), -1.0],
	["pedana", Vector3(-13.0, 0.45, -3.5), 0.4],
	["giù dai gradini", Vector3(-9.2, 0.0, -3.5), -1.0],
	["zona interazione", Vector3(0.0, 0.0, -8.0), -1.0],
	["zona fisica", Vector3(16.0, 0.0, -8.0), -1.0],
	["zona audio", Vector3(16.0, 0.0, 8.0), -1.0],
	["zona vetrina (corsia libera accanto alla vetrina)", Vector3(-1.0, 0.0, 12.0), -1.0],
	["ritorno al movimento", Vector3(-20.0, 0.0, -3.0), -1.0],
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	change_scene_to_file(DEMO_SCENE)
	# Due frame per caricare la scena, poi attesa della sincronizzazione della navmesh.
	await process_frame
	await process_frame
	await physics_frame
	await physics_frame
	var demo: Node = current_scene
	# Tipo generico: questo script si compila prima degli autoload, quindi non può
	# nominare classi che usano DebugSettings.
	var character: Variant = demo.get("character")
	var failures: int = 0

	for waypoint: Array in WAYPOINTS:
		var label: String = waypoint[0]
		var point: Vector3 = waypoint[1]
		var min_height: float = waypoint[2]
		character.move_to(point)
		var elapsed: float = 0.0
		var reached: bool = false
		while elapsed < STEP_TIMEOUT:
			await physics_frame
			elapsed += 1.0 / Engine.physics_ticks_per_second
			var offset: Vector3 = character.global_position - point
			offset.y = 0.0
			if offset.length() <= ARRIVAL_TOLERANCE and character.get_planar_velocity().length() < 0.1:
				reached = true
				break
		var position: Vector3 = character.global_position
		var height_ok: bool = min_height < 0.0 or position.y >= min_height
		if reached and height_ok:
			print("OK    %-22s in %5.1f s  (%.2f, %.2f, %.2f)" % [label, elapsed, position.x, position.y, position.z])
		else:
			failures += 1
			print("FALLITO %-20s dopo %5.1f s  posizione (%.2f, %.2f, %.2f)" % [label, elapsed, position.x, position.y, position.z])

	print("Risultato: %d tappe fallite su %d" % [failures, WAYPOINTS.size()])
	quit(1 if failures > 0 else 0)
