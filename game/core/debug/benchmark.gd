class_name Benchmark
extends Node
## Misura delle prestazioni del livello demo, senza nessuno ai comandi. Si attiva
## avviando il gioco con "-- --benchmark" (anche dalla build esportata):
##   "Open Space.app/Contents/MacOS/Open Space" -- --benchmark
## Il personaggio cammina in ogni zona con gommosità 0, 1 e 2; per ogni prova
## stampa fps medi, frame più lento e draw call, salva tutto in
## user://benchmark.txt ed esce. Il vsync è spento, per vedere il margine reale.

const COMMAND_LINE_FLAG: String = "--benchmark"

## Zone da misurare: nome e punto di partenza.
@export var zones: Dictionary[String, Vector3] = {
	"movimento": Vector3(-19.0, 0.0, -10.0),
	"interazione": Vector3(-2.0, 0.0, -10.0),
	"fisica": Vector3(14.0, 0.0, -8.0),
	"vetrina": Vector3(-16.0, 0.0, 9.0),
	"audio": Vector3(10.0, 0.0, 8.0),
}
@export var wobble_values: PackedFloat32Array = PackedFloat32Array([0.0, 1.0, 2.0])
## Il personaggio cammina avanti e indietro di questo tratto durante la prova.
@export var walk_offset: Vector3 = Vector3(4.0, 0.0, 0.0)
## Secondi di assestamento e di misura per ogni prova.
@export var warmup_seconds: float = 1.0
@export var sample_seconds: float = 3.0

var character: RubberCharacter


static func is_requested() -> bool:
	return OS.get_cmdline_user_args().has(COMMAND_LINE_FLAG)


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_run.call_deferred()


func _run() -> void:
	var lines: PackedStringArray = []
	lines.append("Open Space — benchmark del livello demo")
	lines.append("Godot %s, %s, %s, %s" % [Engine.get_version_info()["string"], OS.get_name(),
			OS.get_processor_name(), RenderingServer.get_video_adapter_name()])
	lines.append("Finestra %s, vsync spento" % str(DisplayServer.window_get_size()))
	# Nella build release il pannello si cancella da solo (queue_free): qui può
	# essere ancora in coda, quindi conta come assente.
	var panel: Node = get_tree().root.find_child("DebugPanel", true, false)
	var panel_present: bool = panel != null and not panel.is_queued_for_deletion()
	lines.append("Build di %s, pannello di debug %s" % ["debug" if OS.is_debug_build() else "release",
			"presente" if panel_present else "assente"])
	lines.append("%-12s %-9s %8s %14s %10s" % ["zona", "gommosità", "fps medi", "frame peggiore", "draw call"])
	for zone_name: String in zones:
		for wobble: float in wobble_values:
			DebugSettings.wobble = wobble
			var start: Vector3 = zones[zone_name]
			character.stop()
			character.global_position = start + Vector3.UP * 0.05
			character.move_to(start + walk_offset)
			await _wait_seconds(warmup_seconds)
			var result: Dictionary = await _sample(start)
			lines.append("%-12s %-9.1f %8.1f %11.1f ms %10d" % [zone_name, wobble, result["fps"],
					result["worst_ms"], result["draw_calls"]])
			print(lines[-1])
	var report: String = "\n".join(lines)
	print(report)
	var file := FileAccess.open("user://benchmark.txt", FileAccess.WRITE)
	if file:
		file.store_string(report + "\n")
		print("Salvato in ", ProjectSettings.globalize_path("user://benchmark.txt"))
	get_tree().quit()


func _sample(start: Vector3) -> Dictionary:
	var frames: int = 0
	var worst_usec: int = 0
	var draw_calls_total: int = 0
	var started: int = Time.get_ticks_usec()
	var last: int = started
	var going_out: bool = true
	while Time.get_ticks_usec() - started < int(sample_seconds * 1000000.0):
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		worst_usec = maxi(worst_usec, now - last)
		last = now
		frames += 1
		draw_calls_total += int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		if character.get_planar_velocity().length() < 0.05:
			going_out = not going_out
			character.move_to(start + walk_offset if going_out else start)
	var elapsed_seconds: float = float(Time.get_ticks_usec() - started) / 1000000.0
	return {
		"fps": frames / elapsed_seconds,
		"worst_ms": worst_usec / 1000.0,
		"draw_calls": draw_calls_total / maxi(frames, 1),
	}


func _wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout
